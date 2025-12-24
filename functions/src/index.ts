/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import * as fs from "fs";
import * as path from "path";

// Firebase Admin SDK 초기화
// 서비스 계정 키 파일을 안전하게 로드하고 검증
let adminApp: admin.app.App;
interface ServiceAccountInfo {
  clientEmail: string;
  projectId: string;
  keyPath: string;
}
let serviceAccountInfo: ServiceAccountInfo | null = null;

try {
  const serviceAccountKeyPath = path.join(
    __dirname,
    "..",
    "serviceAccountKey.json"
  );

  logger.info(`서비스 계정 키 파일 경로: ${serviceAccountKeyPath}`);

  // 파일 존재 여부 확인
  if (!fs.existsSync(serviceAccountKeyPath)) {
    logger.error(
      `서비스 계정 키 파일이 없습니다: ${serviceAccountKeyPath}`
    );
    throw new Error(
      `서비스 계정 키 파일을 찾을 수 없습니다: ${serviceAccountKeyPath}`
    );
  }

  // 파일 읽기
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let serviceAccount: any;
  try {
    const serviceAccountData = fs.readFileSync(serviceAccountKeyPath, "utf8");
    serviceAccount = JSON.parse(serviceAccountData);
    logger.info("서비스 계정 키 파일 로드 성공");
  } catch (readError) {
    logger.error(`서비스 계정 키 파일 읽기 실패: ${readError}`);
    throw new Error(
      `서비스 계정 키 파일을 읽을 수 없습니다: ${readError}`
    );
  }

  // 서비스 계정 키 유효성 검증
  if (!serviceAccount.private_key) {
    logger.error("서비스 계정 키에 private_key가 없습니다.");
    throw new Error("서비스 계정 키에 private_key 필드가 없습니다.");
  }

  if (!serviceAccount.client_email) {
    logger.error("서비스 계정 키에 client_email이 없습니다.");
    throw new Error("서비스 계정 키에 client_email 필드가 없습니다.");
  }

  if (!serviceAccount.project_id) {
    logger.error("서비스 계정 키에 project_id가 없습니다.");
    throw new Error("서비스 계정 키에 project_id 필드가 없습니다.");
  }

  // 서비스 계정 정보 저장 (나중에 로깅용)
  serviceAccountInfo = {
    clientEmail: serviceAccount.client_email,
    projectId: serviceAccount.project_id,
    keyPath: serviceAccountKeyPath,
  };

  logger.info(
    "서비스 계정 키 검증 완료: " +
    `client_email=${serviceAccount.client_email}, ` +
    `project_id=${serviceAccount.project_id}, ` +
    `private_key 존재=${!!serviceAccount.private_key}`
  );

  // Firebase Admin SDK 초기화
  try {
    adminApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: "credo-ceda9",
    });
    logger.info("✅ Firebase Admin SDK 초기화 완료 (serviceAccountKey)");
  } catch (initError) {
    logger.error(`Firebase Admin SDK 초기화 실패: ${initError}`);
    throw initError;
  }
} catch (error) {
  logger.error(`❌ Firebase Admin SDK 초기화 중 치명적 에러: ${error}`);
  logger.error(`에러 타입: ${typeof error}`);
  const errorMsg = error instanceof Error ? error.message : String(error);
  logger.error(`에러 메시지: ${errorMsg}`);
  const errorStack = error instanceof Error ? error.stack : "N/A";
  logger.error(`에러 스택: ${errorStack}`);

  // 이미 초기화된 경우 재초기화 시도
  try {
    adminApp = admin.app();
    logger.info("기존 Firebase Admin SDK 인스턴스 사용");
  } catch (retryError) {
    logger.error(`기존 인스턴스 가져오기 실패: ${retryError}`);
    throw error; // 원래 에러를 다시 던짐
  }
}

// Slack Webhook URL (환경 변수에서 로드)
// Firebase Console 또는 .env 파일에서 SLACK_WEBHOOK_URL 설정 필요
const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL || "";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

/**
 * 신고 문서 생성 시 Slack으로 알림 전송
 */
export const onReportCreated = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const reportData = event.data?.data();
    if (!reportData) {
      logger.error("신고 데이터가 없습니다.");
      return;
    }

    const reportId = event.params.reportId;
    const targetType = reportData.targetType || "unknown";
    const targetId = reportData.targetId || "unknown";
    const reason = reportData.reason || "未指定";
    const reporterId = reportData.reporterId || "unknown";
    const createdAt = reportData.createdAt ?
      new Date(reportData.createdAt.toMillis()).toISOString() :
      new Date().toISOString();

    // Slack Webhook URL 사용
    const webhookUrl = SLACK_WEBHOOK_URL;

    // 신고 타입에 따른 한글/일본어 표시
    const targetTypeDisplay = targetType === "post" ?
      "게시글" :
      targetType === "comment" ?
        "댓글" :
        targetType === "user" ?
          "사용자" :
          targetType;

    // Slack 메시지 포맷팅
    const slackMessage = {
      text: "🚨 새로운 신고가 접수되었습니다",
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "🚨 새로운 신고가 접수되었습니다",
            emoji: true,
          },
        },
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: `*신고 ID:*\n${reportId}`,
            },
            {
              type: "mrkdwn",
              text: `*신고 유형:*\n${targetTypeDisplay}`,
            },
            {
              type: "mrkdwn",
              text: `*대상 ID:*\n${targetId}`,
            },
            {
              type: "mrkdwn",
              text: `*신고 사유:*\n${reason}`,
            },
            {
              type: "mrkdwn",
              text: `*신고자 ID:*\n${reporterId}`,
            },
            {
              type: "mrkdwn",
              text: `*신고 시간:*\n${createdAt}`,
            },
          ],
        },
      ],
    };

    try {
      const response = await fetch(webhookUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(slackMessage),
      });

      if (!response.ok) {
        logger.error(
          `Slack 알림 전송 실패: ${response.status} ${response.statusText}`,
        );
      } else {
        logger.info(`✅ 신고 알림이 Slack으로 전송되었습니다: ${reportId}`);
      }
    } catch (error) {
      logger.error(`Slack 알림 전송 중 오류 발생: ${error}`);
    }

    // 게시글 신고인 경우, 신고 개수 확인 후 자동 숨김 처리
    if (targetType === "post") {
      try {
        const db = getFirestore();
        const reportsSnapshot = await db
          .collection("reports")
          .where("targetType", "==", "post")
          .where("targetId", "==", targetId)
          .get();

        const reportCount = reportsSnapshot.size;
        const HIDE_THRESHOLD = 3; // 신고 3개 이상이면 숨김

        logger.info(
          `게시글 ${targetId}의 신고 개수: ${reportCount}`,
        );

        if (reportCount >= HIDE_THRESHOLD) {
          const postRef = db.collection("posts").doc(targetId);
          const postDoc = await postRef.get();

          if (postDoc.exists) {
            const postData = postDoc.data();
            const currentStatus = postData?.status || "published";

            // 이미 숨겨진 상태가 아니면 숨김 처리
            if (currentStatus === "published") {
              await postRef.update({
                status: "hidden",
                updatedAt: new Date(),
              });
              logger.info(
                `✅ 게시글 ${targetId}가 자동으로 숨김 처리되었습니다 (신고 ${reportCount}개)`,
              );
            } else {
              logger.info(
                `게시글 ${targetId}는 이미 ${currentStatus} 상태입니다.`,
              );
            }
          } else {
            logger.warn(`게시글 ${targetId}를 찾을 수 없습니다.`);
          }
        }
      } catch (error) {
        logger.error(
          `게시글 숨김 처리 중 오류 발생: ${error}`,
        );
      }
    }
  },
);

/**
 * 게시글 생성 시 소속 유저에게 푸시 알림 전송
 * 공지글(type == "official" && category == "notice")인 경우에만 알림 전송
 */
export const onPostCreated = onDocumentCreated(
  "posts/{postId}",
  async (event) => {
    const postData = event.data?.data();
    if (!postData) {
      logger.error("게시글 데이터가 없습니다.");
      return;
    }

    const postId = event.params.postId;
    const type = postData.type || "normal";
    const category = postData.category || "community";
    const parishId = postData.parishId;
    const authorId = postData.authorId;
    const title = postData.title || "새로운 공지";

    logger.info(
      `게시글 생성 이벤트: postId=${postId}, type=${type}, ` +
      `category=${category}, parishId=${parishId}, authorId=${authorId}`,
    );

    // 공지글인지 확인 (type == "official" && category == "notice")
    if (type !== "official" || category !== "notice") {
      logger.info(
        `게시글 ${postId}는 공지글이 아닙니다 (type: ${type}, category: ${category})`,
      );
      return;
    }

    // parishId가 없으면 알림 전송 불가
    if (!parishId) {
      logger.warn(`게시글 ${postId}에 parishId가 없습니다.`);
      return;
    }

    try {
      const db = getFirestore(adminApp);
      const messaging = getMessaging(adminApp);

      // 해당 성당에 소속된 사용자 조회 (main_parish_id == parishId)
      const mainParishUsersSnapshot = await db
        .collection("users")
        .where("main_parish_id", "==", parishId)
        .get();

      // 자주 가는 교회에 등록한 사용자 조회 (favorite_parish_ids contains parishId)
      const favoriteParishUsersSnapshot = await db
        .collection("users")
        .where("favorite_parish_ids", "array-contains", parishId)
        .get();

      // 중복 제거를 위해 Map 사용
      const userDocsMap = new Map<string, FirebaseFirestore.DocumentSnapshot>();
      for (const doc of mainParishUsersSnapshot.docs) {
        userDocsMap.set(doc.id, doc);
      }
      for (const doc of favoriteParishUsersSnapshot.docs) {
        if (!userDocsMap.has(doc.id)) {
          userDocsMap.set(doc.id, doc);
        }
      }

      logger.info(
        `성당 ${parishId} 관련 사용자 수: 소속=${mainParishUsersSnapshot.size}, ` +
        `즐겨찾기=${favoriteParishUsersSnapshot.size}, 총=${userDocsMap.size}`,
      );

      // FCM 토큰이 있는 사용자 수 확인
      let usersWithToken = 0;
      let usersWithoutToken = 0;

      // FCM 토큰이 있는 사용자만 필터링 (작성자 제외)
      const messages: Array<{
        token: string;
        notification: {title: string; body: string};
        data: {postId: string; parishId: string; type: string};
      }> = [];

      for (const userDoc of userDocsMap.values()) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        if (!userData) continue;
        const fcmToken = userData.fcmToken;

        // 작성자는 알림에서 제외
        if (userId === authorId) {
          continue;
        }

        // 알림 설정 확인
        let shouldSendNotification = true;
        try {
          const settingsDoc = await db
            .collection("users")
            .doc(userId)
            .collection("notificationSettings")
            .doc("settings")
            .get();

          if (settingsDoc.exists) {
            const settings = settingsDoc.data();
            // 전체 알림이 꺼져 있으면 전송하지 않음
            if (settings?.enabled === false) {
              shouldSendNotification = false;
            } else if (settings?.notices === false) {
              // 공지사항 알림이 꺼져 있으면 전송하지 않음
              shouldSendNotification = false;
            } else if (
              settings?.quietHoursStart !== undefined &&
              settings?.quietHoursEnd !== undefined
            ) {
              // 조용한 시간 확인 (현재 시간이 조용한 시간대인지 확인)
              const now = new Date();
              const currentHour = now.getHours();
              const quietStart = settings.quietHoursStart as number;
              const quietEnd = settings.quietHoursEnd as number;

              // 조용한 시간대 체크 (예: 22시 ~ 7시)
              if (quietStart > quietEnd) {
                // 자정을 넘어가는 경우 (예: 22시 ~ 7시)
                if (currentHour >= quietStart || currentHour < quietEnd) {
                  shouldSendNotification = false;
                }
              } else {
                // 같은 날 범위 (예: 10시 ~ 22시)
                if (currentHour >= quietStart && currentHour < quietEnd) {
                  shouldSendNotification = false;
                }
              }
            }
          }
        } catch (error) {
          logger.warn(
            `사용자 ${userId}의 알림 설정 확인 실패: ${error}`,
          );
          // 설정 확인 실패 시 기본적으로 알림 전송 (기존 동작 유지)
        }

        // FCM 토큰이 있고 알림 설정이 허용된 사용자만 추가
        if (
          fcmToken &&
          typeof fcmToken === "string" &&
          shouldSendNotification
        ) {
          usersWithToken++;
          messages.push({
            token: fcmToken,
            notification: {
              title: "📢 새로운 공지",
              body: `${title} - 새로운 공지가 등록되었습니다.`,
            },
            data: {
              postId: postId,
              parishId: parishId,
              type: "official_notice",
            },
          });
        } else {
          usersWithoutToken++;
        }
      }

      logger.info(
        `FCM 토큰 통계: 토큰 있음 ${usersWithToken}명, ` +
        `토큰 없음 ${usersWithoutToken}명`,
      );

      logger.info(`전송할 알림 개수: ${messages.length}`);

      // 알림 전송 (최대 500개씩 배치로 전송)
      if (messages.length > 0) {
        const BATCH_SIZE = 500;
        for (let i = 0; i < messages.length; i += BATCH_SIZE) {
          const batch = messages.slice(i, i + BATCH_SIZE);
          try {
            const response = await messaging.sendEach(batch);
            logger.info(
              `✅ 알림 전송 완료: 성공 ${response.successCount}개, ` +
              `실패 ${response.failureCount}개`,
            );
            if (response.failureCount > 0) {
              logger.warn(
                "일부 알림 전송 실패: " +
                `${response.responses
                  .filter((r) => !r.success)
                  .map((r) => r.error?.message)
                  .join(", ")}`,
              );
            }
          } catch (error) {
            logger.error(`알림 배치 전송 중 오류 발생: ${error}`);
          }
        }
      } else {
        logger.info("전송할 알림이 없습니다 (FCM 토큰이 있는 사용자가 없음)");
      }
    } catch (error) {
      logger.error(`공지글 알림 전송 중 오류 발생: ${error}`);
    }
  },
);

/**
 * 댓글 생성 시 게시글 작성자에게 푸시 알림 전송
 * (댓글 작성자 자신에게는 알림을 보내지 않음)
 */
export const onCommentCreated = onDocumentCreated(
  "comments/{commentId}",
  async (event) => {
    const commentData = event.data?.data();
    if (!commentData) {
      logger.error("댓글 데이터가 없습니다.");
      return;
    }

    const commentId = event.params.commentId;
    const postId = commentData.postId;
    const commentAuthorId = commentData.authorId;
    const commentAuthorName = commentData.authorName || "ユーザー";
    const commentContent = commentData.content || "";

    logger.info(
      `댓글 생성 이벤트: commentId=${commentId}, postId=${postId}, ` +
      `commentAuthorId=${commentAuthorId}`,
    );

    if (!postId) {
      logger.warn(`댓글 ${commentId}에 postId가 없습니다.`);
      return;
    }

    try {
      const db = getFirestore(adminApp);
      const messaging = getMessaging(adminApp);

      // 게시글 정보 가져오기
      const postDoc = await db.collection("posts").doc(postId).get();
      if (!postDoc.exists) {
        logger.warn(`게시글 ${postId}를 찾을 수 없습니다.`);
        return;
      }

      const postData = postDoc.data();
      if (!postData) {
        logger.warn(`게시글 ${postId}의 데이터가 없습니다.`);
        return;
      }

      const postAuthorId = postData.authorId;
      const postParishId = postData.parishId || "";

      // 댓글 작성자는 알림에서 제외
      if (postAuthorId === commentAuthorId) {
        logger.info(
          `댓글 작성자(${commentAuthorId})가 게시글 작성자와 동일합니다. 알림을 전송하지 않습니다.`,
        );
        return;
      }

      logger.info(
        `게시글 정보: postId=${postId}, postAuthorId=${postAuthorId}, ` +
        `postParishId=${postParishId}`,
      );

      // 댓글 작성자가 게시글 작성자와 같으면 알림 전송하지 않음
      if (commentAuthorId === postAuthorId) {
        logger.info(
          `댓글 작성자(${commentAuthorId})가 게시글 작성자와 동일하므로 ` +
          "알림을 전송하지 않습니다.",
        );
        return;
      }

      // 게시글 작성자 정보 가져오기
      const postAuthorDoc = await db
        .collection("users")
        .doc(postAuthorId)
        .get();
      if (!postAuthorDoc.exists) {
        logger.warn(`게시글 작성자 ${postAuthorId}를 찾을 수 없습니다.`);
        return;
      }

      const postAuthorData = postAuthorDoc.data();
      const fcmToken = postAuthorData?.fcmToken;

      logger.info(
        `게시글 작성자 정보: userId=${postAuthorId}, ` +
        `fcmToken 존재 여부=${!!fcmToken}`,
      );

      // FCM 토큰이 없으면 알림 전송 불가
      if (!fcmToken || typeof fcmToken !== "string") {
        logger.warn(
          `게시글 작성자 ${postAuthorId}의 FCM 토큰이 없습니다. ` +
          "알림을 전송할 수 없습니다.",
        );
        return;
      }

      // 알림 설정 확인
      let shouldSendNotification = true;
      try {
        const settingsDoc = await db
          .collection("users")
          .doc(postAuthorId)
          .collection("notificationSettings")
          .doc("settings")
          .get();

        if (settingsDoc.exists) {
          const settings = settingsDoc.data();
          // 전체 알림이 꺼져 있으면 전송하지 않음
          if (settings?.enabled === false) {
            shouldSendNotification = false;
          } else if (settings?.comments === false) {
            // 댓글 알림이 꺼져 있으면 전송하지 않음
            shouldSendNotification = false;
          } else if (
            settings?.quietHoursStart !== undefined &&
            settings?.quietHoursEnd !== undefined
          ) {
            // 조용한 시간 확인
            const now = new Date();
            const currentHour = now.getHours();
            const quietStart = settings.quietHoursStart as number;
            const quietEnd = settings.quietHoursEnd as number;

            // 조용한 시간대 체크
            if (quietStart > quietEnd) {
              // 자정을 넘어가는 경우
              if (currentHour >= quietStart || currentHour < quietEnd) {
                shouldSendNotification = false;
              }
            } else {
              // 같은 날 범위
              if (currentHour >= quietStart && currentHour < quietEnd) {
                shouldSendNotification = false;
              }
            }
          }
        }
      } catch (error) {
        logger.warn(
          `게시글 작성자 ${postAuthorId}의 알림 설정 확인 실패: ${error}`,
        );
        // 설정 확인 실패 시 기본적으로 알림 전송 (기존 동작 유지)
      }

      // 알림 설정이 허용되지 않으면 전송하지 않음
      if (!shouldSendNotification) {
        logger.info(
          `게시글 작성자 ${postAuthorId}의 알림 설정에 의해 알림 전송이 차단되었습니다.`,
        );
        return;
      }

      // 알림 메시지 생성
      const notificationTitle = "新しいコメント";
      const notificationBody =
        `${commentAuthorName}: ${commentContent.length > 50 ?
          `${commentContent.substring(0, 50)}...` :
          commentContent}`;

      try {
        const message = {
          token: fcmToken,
          notification: {
            title: notificationTitle,
            body: notificationBody,
          },
          data: {
            postId: postId,
            parishId: postParishId,
            type: "comment",
            commentId: commentId,
          },
        };

        const response = await messaging.send(message);
        logger.info(
          `✅ 댓글 알림 전송 완료: 게시글 ${postId}, ` +
          `댓글 ${commentId}, 메시지 ID: ${response}`,
        );
      } catch (error) {
        logger.error(
          `댓글 알림 전송 중 오류 발생: ${error}`,
        );
      }
    } catch (error) {
      logger.error(`댓글 알림 전송 중 오류 발생: ${error}`);
    }
  },
);

/**
 * FCM 테스트 알림 전송 (HTTP 호출 가능)
 * 클라이언트에서 자신에게 테스트 알림을 보낼 수 있음
 */
export const sendTestNotification = onCall(
  {
    cors: true,
  },
  async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
      const errorDetails: Record<string, unknown> = {
        errorMessage: "인증이 필요합니다.",
        errorType: "unauthenticated",
        stage: "authentication_check",
        hasAuth: !!request.auth,
      };
      logger.error(`에러 상세 정보: ${JSON.stringify(errorDetails)}`);
      throw new HttpsError("unauthenticated", "인증이 필요합니다.", errorDetails);
    }

    logger.info(`FCM 테스트 알림 요청: userId=${userId}`);
    logger.info(`요청 시간: ${new Date().toISOString()}`);

    try {
      // adminApp 확인
      if (!adminApp) {
        logger.error("adminApp이 초기화되지 않았습니다.");
        const errorDetails: Record<string, unknown> = {
          errorMessage: "adminApp이 초기화되지 않았습니다.",
          errorType: "initialization_error",
          stage: "adminApp_check",
        };
        logger.error(`에러 상세 정보: ${JSON.stringify(errorDetails)}`);
        throw new HttpsError(
          "internal",
          "FCM 서비스가 초기화되지 않았습니다. 잠시 후 다시 시도해주세요.",
          errorDetails,
        );
      }
      logger.info("adminApp 확인 완료");
      logger.info(`adminApp 이름: ${adminApp.name}`);
      const projectId = adminApp.options.projectId;
      logger.info(`adminApp 옵션 projectId: ${projectId}`);

      // 서비스 계정 정보 확인 (가능한 경우)
      try {
        const credential = adminApp.options.credential;
        if (credential) {
          logger.info("서비스 계정 credential 존재 확인됨");
          // credential 타입 확인
          logger.info(`Credential 타입: ${credential.constructor.name}`);
        } else {
          logger.warn(
            "⚠️ 서비스 계정 credential이 없습니다. " +
            "FCM API 호출이 실패할 수 있습니다."
          );
        }
      } catch (credCheckError) {
        logger.warn(
          `서비스 계정 credential 확인 중 에러: ${credCheckError}`
        );
      }

      // 서비스 계정 키 파일 정보 확인 (초기화 시 로드한 정보)
      if (serviceAccountInfo) {
        logger.info("서비스 계정 키 파일 정보:");
        logger.info(`  - 파일 경로: ${serviceAccountInfo.keyPath}`);
        logger.info(`  - client_email: ${serviceAccountInfo.clientEmail}`);
        logger.info(`  - project_id: ${serviceAccountInfo.projectId}`);
        const keyPathExists = fs.existsSync(serviceAccountInfo.keyPath);
        logger.info(`  - 파일 존재 여부: ${keyPathExists}`);

        // 프로젝트 ID 일치 확인
        if (serviceAccountInfo.projectId !== "credo-ceda9") {
          logger.warn(
            `⚠️ 서비스 계정 키의 project_id(${serviceAccountInfo.projectId})가 ` +
            "프로젝트 ID(credo-ceda9)와 일치하지 않습니다!"
          );
        }
      } else {
        logger.warn("서비스 계정 키 파일 정보를 가져올 수 없습니다.");
      }

      const db = getFirestore(adminApp);
      logger.info("Firestore 인스턴스 가져오기 완료");

      // 사용자 정보 가져오기
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        logger.error(`사용자 문서가 존재하지 않음: userId=${userId}`);
        const errorDetails: Record<string, unknown> = {
          errorMessage: `사용자 문서가 존재하지 않음: userId=${userId}`,
          errorType: "not_found",
          stage: "user_document_fetch",
          userId: userId,
        };
        logger.error(`에러 상세 정보: ${JSON.stringify(errorDetails)}`);
        throw new HttpsError("not-found", "사용자를 찾을 수 없습니다.", errorDetails);
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;

      logger.info(`사용자 FCM 토큰 확인: ${fcmToken ? "존재함" : "없음"}`);
      if (fcmToken) {
        logger.info(
          `FCM 토큰 길이: ${fcmToken.length}, ` +
          `시작: ${fcmToken.substring(0, 20)}...`,
        );
      }

      if (!fcmToken || typeof fcmToken !== "string" || fcmToken.trim() === "") {
        logger.error("FCM 토큰이 유효하지 않음");
        const errorDetails: Record<string, unknown> = {
          errorMessage: "FCM 토큰이 유효하지 않음",
          errorType: "invalid_token",
          stage: "token_validation",
          userId: userId,
          tokenExists: !!fcmToken,
          tokenType: typeof fcmToken,
          tokenLength: fcmToken ? fcmToken.length : 0,
        };
        logger.error(`에러 상세 정보: ${JSON.stringify(errorDetails)}`);
        throw new HttpsError(
          "failed-precondition",
          "FCM 토큰이 없습니다. 알림 권한을 확인해주세요.",
          errorDetails,
        );
      }

      // Firebase Admin Messaging 초기화
      // 명시적으로 앱 인스턴스 전달
      let messaging;
      try {
        logger.info("Firebase Admin Messaging 초기화 시도...");
        messaging = getMessaging(adminApp);
        logger.info("Firebase Admin Messaging 초기화 성공");
      } catch (messagingError) {
        const messagingErrorMessage =
          messagingError instanceof Error ?
            messagingError.message :
            String(messagingError);
        logger.error(
          `Firebase Admin Messaging 초기화 실패: ${messagingErrorMessage}`,
        );
        logger.error(
          `Messaging 에러 타입: ${typeof messagingError}`,
        );
        const errorStack = messagingError instanceof Error ?
          messagingError.stack :
          "N/A";
        logger.error(`Messaging 에러 스택: ${errorStack}`);
        const errorName = messagingError instanceof Error ?
          messagingError.name :
          "Unknown";
        // errorDetails는 JSON 직렬화 가능한 값만 포함 (stack 제외)
        const errorDetails: Record<string, unknown> = {
          errorMessage: messagingErrorMessage,
          errorName: errorName,
          errorType: typeof messagingError,
          stage: "messaging_initialization",
        };
        logger.error(`에러 상세 정보: ${JSON.stringify(errorDetails)}`);
        throw new HttpsError(
          "internal",
          "FCM 서비스 초기화에 실패했습니다. 잠시 후 다시 시도해주세요.",
          errorDetails,
        );
      }

      // 테스트 알림 메시지 생성
      const message = {
        token: fcmToken,
        notification: {
          title: "테스트 알림",
          body: "FCM 알림이 정상적으로 작동합니다!",
        },
        data: {
          type: "test",
          timestamp: new Date().toISOString(),
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      logger.info(
        `FCM 메시지 전송 시도: token=${fcmToken.substring(0, 20)}...`,
      );
      logger.info(`메시지 구조: ${JSON.stringify({
        token: fcmToken.substring(0, 20) + "...",
        notification: message.notification,
        hasApns: !!message.apns,
      })}`);

      let response: string;
      try {
        logger.info("messaging.send() 호출 시작...");
        response = await messaging.send(message);
        logger.info(
          `✅ 테스트 알림 전송 완료: userId=${userId}, messageId=${response}`,
        );
      } catch (sendError) {
        logger.error("messaging.send() 호출 실패");
        const sendErrorMessage = sendError instanceof Error ?
          sendError.message :
          String(sendError);
        logger.error(`🔴 FCM 메시지 전송 실패: ${sendErrorMessage}`);
        logger.error(`FCM 에러 타입: ${typeof sendError}`);
        const sendErrorStack =
          sendError instanceof Error ? sendError.stack : "N/A";
        logger.error(`FCM 에러 스택: ${sendErrorStack}`);

        // FCM 관련 에러 처리
        if (sendError instanceof Error) {
          // Firebase Admin SDK 에러에서 추가 정보 추출
          // details는 JSON으로 직렬화 가능한 객체여야 하므로
          // stack 같은 큰 문자열은 제외하고 필수 정보만 포함
          const errorDetails: Record<string, unknown> = {
            errorMessage: sendErrorMessage,
            errorName: sendError.name,
            errorType: typeof sendError,
          };

          // Firebase Admin SDK 에러 객체의 모든 속성 확인
          const errorAny = sendError as unknown as Record<string, unknown>;

          // 에러 객체의 모든 키 로깅
          const errorKeys = Object.keys(errorAny).join(", ");
          logger.error(`에러 객체 키 목록: ${errorKeys}`);

          // code (FCM 에러 코드) - 가장 중요!
          if (errorAny.code) {
            const code = String(errorAny.code);
            errorDetails.code = code;
            logger.error(
              `🔴 FCM 에러 코드 (code): ${code} - ` +
              "이 코드가 원인 그 자체입니다!"
            );
          } else {
            logger.warn("에러 객체에 code 속성이 없습니다.");
          }

          // httpErrorCode (HTTP 에러 코드) - 매우 중요!
          if (errorAny.httpErrorCode) {
            const httpErrorCode = Number(errorAny.httpErrorCode);
            errorDetails.httpErrorCode = httpErrorCode;
            logger.error(
              `🔴 HTTP 에러 코드 (httpErrorCode): ${httpErrorCode} - ` +
              "이 코드가 원인 그 자체입니다!"
            );
          } else {
            logger.warn("에러 객체에 httpErrorCode 속성이 없습니다.");
          }

          // errorInfo 객체 처리 (직렬화 가능한 값만 추출)
          if (errorAny.errorInfo && typeof errorAny.errorInfo === "object") {
            try {
              const errorInfo = errorAny.errorInfo as Record<string, unknown>;
              const errorInfoDetails: Record<string, unknown> = {};
              if (errorInfo.code && typeof errorInfo.code === "string") {
                errorInfoDetails.code = errorInfo.code;
              }
              if (errorInfo.message && typeof errorInfo.message === "string") {
                errorInfoDetails.message = errorInfo.message;
              }
              if (Object.keys(errorInfoDetails).length > 0) {
                errorDetails.errorInfo = errorInfoDetails;
              }
            } catch {
              // errorInfo 처리 실패 시 제외
            }
          }

          // statusCode (HTTP 상태 코드, 다른 이름일 수 있음)
          if (errorAny.statusCode) {
            logger.error(`HTTP 상태 코드 (statusCode): ${errorAny.statusCode}`);
            errorDetails.statusCode = Number(errorAny.statusCode);
          }

          // status (HTTP 상태)
          if (errorAny.status) {
            logger.error(`HTTP 상태 (status): ${errorAny.status}`);
            errorDetails.status = errorAny.status;
          }

          // response (응답 객체가 있는 경우)
          if (errorAny.response) {
            logger.error(`응답 객체 존재: ${typeof errorAny.response}`);
            try {
              const responseStr = JSON.stringify(errorAny.response);
              logger.error(
                `응답 내용: ${responseStr.substring(0, 500)}...`
              );
            } catch {
              logger.error("응답 객체 직렬화 실패");
            }
          }

          // details는 JSON 직렬화 가능한 객체만 포함
          if (errorAny.details && typeof errorAny.details === "object") {
            try {
              // 직렬화 가능한 값만 추출
              const details = errorAny.details as Record<string, unknown>;
              const serializableDetails: Record<string, unknown> = {};
              for (const [key, value] of Object.entries(details)) {
                if (
                  typeof value === "string" ||
                  typeof value === "number" ||
                  typeof value === "boolean" ||
                  value === null
                ) {
                  serializableDetails[key] = value;
                } else if (typeof value === "object" && value !== null) {
                  try {
                    // 중첩 객체도 직렬화 시도
                    JSON.stringify(value);
                    serializableDetails[key] = value;
                  } catch {
                    // 직렬화 실패 시 제외
                  }
                }
              }
              if (Object.keys(serializableDetails).length > 0) {
                errorDetails.originalDetails = serializableDetails;
                const originalDetailsStr = JSON.stringify(serializableDetails);
                logger.error(
                  `🔴 원본 에러 상세 (originalDetails): ${originalDetailsStr} - ` +
                  "이 정보가 원인 그 자체입니다!"
                );
              }
            } catch {
              logger.error("originalDetails 직렬화 실패");
            }
          } else {
            logger.warn(
              "에러 객체에 details 속성이 없거나 객체가 아닙니다."
            );
          }

          // 에러 객체의 모든 속성 로깅 (디버깅용)
          logger.error("=== 에러 객체 전체 속성 ===");
          Object.keys(errorAny).forEach((key) => {
            try {
              const value = errorAny[key];
              const isSimpleType =
                typeof value === "string" ||
                typeof value === "number" ||
                typeof value === "boolean";
              if (isSimpleType) {
                logger.error(`  ${key}: ${value}`);
              } else if (value === null || value === undefined) {
                logger.error(`  ${key}: ${value}`);
              } else {
                logger.error(`  ${key}: [${typeof value}]`);
              }
            } catch {
              logger.error(`  ${key}: [읽기 실패]`);
            }
          });

          // 인증 문제 (가장 흔한 경우)
          if (
            sendErrorMessage.includes("authentication credential") ||
            sendErrorMessage.includes("missing required authentication") ||
            sendErrorMessage.includes("OAuth 2 access token")
          ) {
            logger.error(
              "FCM API 인증 실패. Firebase 프로젝트 설정을 확인하세요.",
            );
            // errorDetails 직렬화 검증
            try {
              JSON.stringify(errorDetails);
              logger.error(`에러 상세 정보: ${JSON.stringify(errorDetails)}`);
              throw new HttpsError(
                "internal",
                "FCM 서비스 인증에 실패했습니다. 관리자에게 문의해주세요.",
                errorDetails,
              );
            } catch (serializeError) {
              // 직렬화 실패 시 최소한의 정보만 포함
              logger.error(
                `errorDetails 직렬화 실패: ${serializeError}, ` +
                "최소 정보만 포함합니다."
              );
              const minimalDetails: Record<string, unknown> = {
                errorMessage: sendErrorMessage,
                code: errorDetails.code || "unknown",
                stage: "messaging_send_auth_error",
              };
              throw new HttpsError(
                "internal",
                "FCM 서비스 인증에 실패했습니다. 관리자에게 문의해주세요.",
                minimalDetails,
              );
            }
          }
          // 토큰이 유효하지 않은 경우
          if (
            sendErrorMessage.includes("invalid") ||
            sendErrorMessage.includes("registration-token")
          ) {
            throw new HttpsError(
              "failed-precondition",
              "FCM 토큰이 유효하지 않습니다. 앱을 재시작해주세요.",
              errorDetails,
            );
          }
          // 권한 문제
          if (
            sendErrorMessage.includes("permission") ||
            sendErrorMessage.includes("unauthorized")
          ) {
            throw new HttpsError(
              "permission-denied",
              "FCM 메시지 전송 권한이 없습니다.",
              errorDetails,
            );
          }

          // 알 수 없는 에러도 details 포함
          const errorDetailsStr = JSON.stringify(errorDetails);
          logger.error(`FCM 알 수 없는 에러 상세 정보: ${errorDetailsStr}`);
          throw new HttpsError(
            "internal",
            `FCM 메시지 전송 실패: ${sendErrorMessage}`,
            errorDetails,
          );
        }

        // 그 외의 FCM 에러는 errorDetails와 함께 전달
        const fallbackErrorDetails: Record<string, unknown> = {
          errorMessage: sendErrorMessage,
          errorType: typeof sendError,
          stage: "messaging_send_unknown_error",
        };
        const fallbackDetailsStr = JSON.stringify(fallbackErrorDetails);
        logger.error(`FCM 알 수 없는 에러 타입 상세 정보: ${fallbackDetailsStr}`);
        throw new HttpsError(
          "internal",
          `FCM 메시지 전송 실패: ${sendErrorMessage}`,
          fallbackErrorDetails,
        );
      }

      return {
        success: true,
        messageId: response,
        message: "테스트 알림이 전송되었습니다.",
      };
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      logger.error(`❌ 테스트 알림 전송 실패: ${errorMessage}`);
      logger.error(`에러 타입: ${typeof error}`);
      logger.error(`에러 이름: ${error instanceof Error ? error.name : "N/A"}`);
      logger.error(`에러 스택: ${error instanceof Error ? error.stack : "N/A"}`);

      // 에러 객체의 모든 속성 로깅
      if (error instanceof Error) {
        const errorProps = JSON.stringify(Object.getOwnPropertyNames(error));
        logger.error(`에러 속성: ${errorProps}`);
      }

      // HttpsError가 이미 던져진 경우 그대로 전달
      if (error instanceof HttpsError) {
        logger.info(
          `HttpsError 재전달: code=${error.code}, ` +
          `message=${error.message}, ` +
          `details 존재 여부: ${error.details ? "있음" : "없음"}`,
        );
        // details가 없으면 추가
        if (!error.details) {
          logger.warn("⚠️ HttpsError에 details가 없습니다. 추가합니다.");
          const errorDetails: Record<string, unknown> = {
            errorMessage: error.message,
            errorCode: error.code,
            errorType: "HttpsError_without_details",
            stage: "error_rethrow",
          };
          // 기존 HttpsError를 details와 함께 새로 던지기
          throw new HttpsError(
            error.code,
            error.message,
            errorDetails
          );
        }
        throw error;
      }

      // 그 외의 경우 INTERNAL 에러로 변환
      const internalMessage = `테스트 알림 전송 실패: ${errorMessage}`;
      logger.error(`INTERNAL 에러로 변환: ${internalMessage}`);

      // 에러 상세 정보 수집
      // details는 JSON으로 직렬화 가능한 객체여야 하므로
      // stack 같은 큰 문자열은 제외하고 필수 정보만 포함
      const errorDetails: Record<string, unknown> = {
        errorMessage: errorMessage,
        errorType: typeof error,
      };

      if (error instanceof Error) {
        errorDetails.errorName = error.name;
        // stack은 너무 크므로 제외
        const errorAny = error as unknown as Record<string, unknown>;
        if (errorAny.code) {
          errorDetails.code = String(errorAny.code);
        }
        if (errorAny.httpErrorCode) {
          errorDetails.httpErrorCode = Number(errorAny.httpErrorCode);
        }
        // details는 JSON 직렬화 가능한 객체만 포함
        if (errorAny.details && typeof errorAny.details === "object") {
          try {
            errorDetails.originalDetails = JSON.parse(
              JSON.stringify(errorAny.details)
            );
          } catch {
            // 직렬화 실패 시 제외
          }
        }
      }

      const errorDetailsStr = JSON.stringify(errorDetails);
      logger.error(`에러 상세 정보: ${errorDetailsStr}`);
      logger.error(
        `🔴 최종 에러 상세 정보 (클라이언트로 전달): ${errorDetailsStr}`
      );
      throw new HttpsError("internal", internalMessage, errorDetails);
    }
  },
);

/**
 * 알림 유형별 테스트 알림 전송 (실제 Firestore 문서 생성)
 * 클라이언트에서 특정 유형의 테스트 알림을 보낼 수 있음
 * 지원 유형: test, official_notice, comment
 *
 * - test: FCM 직접 전송 (기존 방식)
 * - official_notice: 실제 공지글 생성 → onPostCreated 트리거
 * - comment: 테스트 게시글에 댓글 생성 → onCommentCreated 트리거
 */
export const sendTypedTestNotification = onCall(
  {
    cors: true,
  },
  async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
      throw new HttpsError("unauthenticated", "인증이 필요합니다.");
    }

    // 알림 유형 가져오기 (기본값: test)
    const notificationType = request.data?.type || "test";
    logger.info(
      `알림 유형별 테스트 요청: userId=${userId}, type=${notificationType}`
    );

    // 지원되는 알림 유형 확인
    const supportedTypes = ["test", "official_notice", "comment"];
    if (!supportedTypes.includes(notificationType)) {
      throw new HttpsError(
        "invalid-argument",
        `지원하지 않는 알림 유형입니다: ${notificationType}. ` +
        `지원 유형: ${supportedTypes.join(", ")}`
      );
    }

    try {
      if (!adminApp) {
        throw new HttpsError(
          "internal",
          "FCM 서비스가 초기화되지 않았습니다."
        );
      }

      const db = getFirestore(adminApp);
      const messaging = getMessaging(adminApp);

      // 사용자 정보 가져오기
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new HttpsError("not-found", "사용자를 찾을 수 없습니다.");
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;
      const userName = userData?.displayName || userData?.name || "사용자";
      const parishId = userData?.main_parish_id;

      if (!fcmToken || typeof fcmToken !== "string" || fcmToken.trim() === "") {
        throw new HttpsError(
          "failed-precondition",
          "FCM 토큰이 없습니다. 알림 권한을 확인해주세요."
        );
      }

      // 알림 유형별 처리
      switch (notificationType) {
      case "official_notice": {
        // 공지글 테스트: 실제 공지글 생성 → onPostCreated 트리거
        if (!parishId) {
          throw new HttpsError(
            "failed-precondition",
            "소속 성당이 없습니다. 프로필에서 성당을 설정해주세요."
          );
        }

        logger.info(`공지글 테스트 생성: parishId=${parishId}`);

        // 시스템 계정으로 공지글 생성 (사용자가 알림을 받을 수 있도록)
        const testPostRef = await db.collection("posts").add({
          title: "[테스트] 알림 테스트 공지",
          body: "이것은 알림 테스트를 위한 공지글입니다. " +
            "정상적으로 알림을 받으셨다면 이 게시글은 삭제하셔도 됩니다.",
          type: "official",
          category: "notice",
          parishId: parishId,
          authorId: "system_test", // 시스템 계정으로 생성
          authorName: "시스템 테스트",
          status: "published",
          isTest: true,
          createdAt: new Date(),
          updatedAt: new Date(),
          viewCount: 0,
          likeCount: 0,
          commentCount: 0,
        });

        logger.info(
          `✅ 테스트 공지글 생성 완료: postId=${testPostRef.id}, ` +
          `parishId=${parishId}`
        );

        // 테스트 게시글 5분 후 자동 삭제 예약
        setTimeout(async () => {
          try {
            await testPostRef.delete();
            logger.info(`테스트 공지글 자동 삭제: postId=${testPostRef.id}`);
          } catch (e) {
            logger.warn(`테스트 공지글 삭제 실패: ${e}`);
          }
        }, 5 * 60 * 1000); // 5분

        return {
          success: true,
          type: notificationType,
          postId: testPostRef.id,
          message: "공지글 테스트가 생성되었습니다. " +
            "onPostCreated 트리거가 실행되어 알림이 전송됩니다. " +
            "(5분 후 자동 삭제)",
        };
      }

      case "comment": {
        // 댓글 테스트: 사용자의 테스트 게시글에 댓글 생성 → onCommentCreated 트리거
        logger.info(`댓글 테스트 생성: userId=${userId}`);

        // 사용자의 테스트용 게시글 찾기 또는 생성
        let testPostId: string;
        const existingTestPost = await db.collection("posts")
          .where("authorId", "==", userId)
          .where("isTest", "==", true)
          .where("category", "==", "test_for_comment")
          .limit(1)
          .get();

        if (existingTestPost.empty) {
          // 사용자 소유의 테스트 게시글 생성
          const newTestPost = await db.collection("posts").add({
            title: "[시스템] 댓글 알림 테스트용 게시글",
            body: "이 게시글은 댓글 알림 테스트를 위해 자동 생성되었습니다.",
            type: "normal",
            category: "test_for_comment",
            parishId: parishId || "test_parish",
            authorId: userId, // 사용자가 작성자
            authorName: userName,
            status: "hidden", // 숨김 처리
            isTest: true,
            createdAt: new Date(),
            updatedAt: new Date(),
            viewCount: 0,
            likeCount: 0,
            commentCount: 0,
          });
          testPostId = newTestPost.id;
          logger.info(`테스트용 게시글 생성: postId=${testPostId}`);
        } else {
          testPostId = existingTestPost.docs[0].id;
          logger.info(`기존 테스트용 게시글 사용: postId=${testPostId}`);
        }

        // 시스템 계정으로 댓글 생성 (사용자가 알림을 받을 수 있도록)
        const testCommentRef = await db.collection("comments").add({
          postId: testPostId,
          content: "🔔 이것은 댓글 알림 테스트입니다. " +
            "정상적으로 알림을 받으셨다면 성공입니다!",
          authorId: "system_test", // 시스템 계정으로 작성
          authorName: "알림 테스트 봇",
          isTest: true,
          createdAt: new Date(),
          updatedAt: new Date(),
          likeCount: 0,
        });

        logger.info(
          `✅ 테스트 댓글 생성 완료: commentId=${testCommentRef.id}, ` +
          `postId=${testPostId}`
        );

        // 테스트 댓글 5분 후 자동 삭제 예약
        setTimeout(async () => {
          try {
            await testCommentRef.delete();
            logger.info(`테스트 댓글 자동 삭제: commentId=${testCommentRef.id}`);
          } catch (e) {
            logger.warn(`테스트 댓글 삭제 실패: ${e}`);
          }
        }, 5 * 60 * 1000); // 5분

        return {
          success: true,
          type: notificationType,
          postId: testPostId,
          commentId: testCommentRef.id,
          message: "댓글 테스트가 생성되었습니다. " +
            "onCommentCreated 트리거가 실행되어 알림이 전송됩니다. " +
            "(5분 후 자동 삭제)",
        };
      }

      case "test":
      default: {
        // 기본 테스트: 실제 프로덕션 로직과 동일하게 알림 설정 확인 후 FCM 전송
        logger.info(`기본 테스트 알림: userId=${userId}`);

        // 알림 설정 확인 (실제 프로덕션 로직과 동일)
        let shouldSendNotification = true;
        try {
          const settingsDoc = await db
            .collection("users")
            .doc(userId)
            .collection("notificationSettings")
            .doc("settings")
            .get();

          if (settingsDoc.exists) {
            const settings = settingsDoc.data();
            // 전체 알림이 꺼져 있으면 전송하지 않음
            if (settings?.enabled === false) {
              shouldSendNotification = false;
              logger.info(
                `사용자 ${userId}의 전체 알림이 꺼져 있어 테스트 알림을 전송하지 않습니다.`
              );
            } else if (
              settings?.quietHoursEnabled === true &&
              settings?.quietHoursStart !== undefined &&
              settings?.quietHoursEnd !== undefined
            ) {
              // 조용한 시간 확인
              const now = new Date();
              const currentHour = now.getHours();
              const quietStart = settings.quietHoursStart as number;
              const quietEnd = settings.quietHoursEnd as number;

              // 조용한 시간대 체크
              if (quietStart > quietEnd) {
                // 자정을 넘어가는 경우 (예: 22시 ~ 7시)
                if (currentHour >= quietStart || currentHour < quietEnd) {
                  shouldSendNotification = false;
                  logger.info(
                    `사용자 ${userId}의 조용한 시간대(${quietStart}시~${quietEnd}시)에 ` +
                    `테스트 알림을 전송하지 않습니다. (현재: ${currentHour}시)`
                  );
                }
              } else {
                // 같은 날 범위 (예: 10시 ~ 22시)
                if (currentHour >= quietStart && currentHour < quietEnd) {
                  shouldSendNotification = false;
                  logger.info(
                    `사용자 ${userId}의 조용한 시간대(${quietStart}시~${quietEnd}시)에 ` +
                    `테스트 알림을 전송하지 않습니다. (현재: ${currentHour}시)`
                  );
                }
              }
            }
          }
        } catch (error) {
          logger.warn(
            `사용자 ${userId}의 알림 설정 확인 실패: ${error}. ` +
            "기본적으로 알림을 전송합니다."
          );
          // 설정 확인 실패 시 기본적으로 알림 전송 (테스트 목적)
        }

        // 알림 설정이 허용되지 않으면 전송하지 않음
        if (!shouldSendNotification) {
          return {
            success: false,
            type: notificationType,
            message:
              "알림 설정에 의해 테스트 알림 전송이 차단되었습니다. " +
              "알림 설정에서 전체 알림을 켜거나 조용한 시간을 확인해주세요.",
          };
        }

        // FCM 직접 전송
        const message = {
          token: fcmToken,
          notification: {
            title: "🔔 [테스트] 기본 알림",
            body: "FCM 기본 알림이 정상적으로 작동합니다!",
          },
          data: {
            type: "test",
            timestamp: new Date().toISOString(),
            isTest: "true",
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
          android: {
            priority: "high" as const,
            notification: {
              sound: "default",
              priority: "high" as const,
            },
          },
        };

        logger.info(
          `FCM 직접 전송: type=${notificationType}, ` +
          `token=${fcmToken.substring(0, 20)}...`
        );

        const response = await messaging.send(message);
        logger.info(
          `✅ 기본 테스트 알림 전송 완료: userId=${userId}, ` +
          `messageId=${response}`
        );

        return {
          success: true,
          messageId: response,
          type: notificationType,
          message: "기본 테스트 알림이 전송되었습니다.",
        };
      }
      }
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      logger.error(
        `❌ 알림 유형별 테스트 전송 실패: type=${notificationType}, ` +
        `error=${errorMessage}`
      );

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        `테스트 알림 전송 실패: ${errorMessage}`
      );
    }
  }
);

/**
 * 채팅 메시지 생성 시 알림 전송
 * conversations/{conversationId}/messages/{messageId}
 */
export const onChatMessageCreated = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("메시지 데이터가 없습니다.");
      return;
    }

    const messageData = snapshot.data();
    const conversationId = event.params.conversationId;
    const messageId = event.params.messageId;

    logger.info(
      `🔔 채팅 메시지 알림 처리 시작: conversationId=${conversationId}, ` +
      `messageId=${messageId}`
    );

    // 시스템 메시지는 알림 전송하지 않음
    if (messageData.senderId === "system" || messageData.type === "system") {
      logger.info("시스템 메시지는 알림을 전송하지 않습니다.");
      return;
    }

    const senderId = messageData.senderId;
    const content = messageData.content || "";
    const hasImages = messageData.imageUrls && messageData.imageUrls.length > 0;

    try {
      const firestore = getFirestore();
      const messaging = getMessaging();

      // 1. 대화방 정보 가져오기
      const conversationDoc = await firestore
        .collection("conversations")
        .doc(conversationId)
        .get();

      if (!conversationDoc.exists) {
        logger.warn(`대화방을 찾을 수 없습니다: ${conversationId}`);
        return;
      }

      const conversationData = conversationDoc.data();
      if (!conversationData) {
        logger.warn("대화방 데이터가 없습니다.");
        return;
      }

      const participants: string[] = conversationData.participants || [];
      const conversationType = conversationData.type || "direct";
      const groupName = conversationData.name;

      // 2. 발신자 정보 가져오기
      const senderDoc = await firestore
        .collection("users")
        .doc(senderId)
        .get();
      const senderData = senderDoc.data();
      const senderNickname = senderData?.nickname || "알 수 없음";

      // 3. 수신자 목록 (발신자 제외)
      const recipients = participants.filter((id: string) => id !== senderId);
      logger.info(`알림 수신자: ${recipients.length}명`);

      if (recipients.length === 0) {
        logger.info("알림 수신자가 없습니다.");
        return;
      }

      // 4. 알림 내용 구성
      let notificationTitle = senderNickname;
      if (conversationType === "group" && groupName) {
        notificationTitle = `${groupName} - ${senderNickname}`;
      }

      let notificationBody = content;
      if (hasImages && !content) {
        notificationBody = "📷 사진을 보냈습니다.";
      } else if (hasImages) {
        notificationBody = `📷 ${content}`;
      }

      // 5. 각 수신자에게 알림 전송
      const sendPromises = recipients.map(async (recipientId: string) => {
        try {
          // 수신자의 FCM 토큰 가져오기
          const recipientDoc = await firestore
            .collection("users")
            .doc(recipientId)
            .get();

          if (!recipientDoc.exists) {
            logger.warn(`수신자를 찾을 수 없습니다: ${recipientId}`);
            return;
          }

          const recipientData = recipientDoc.data();
          const fcmToken = recipientData?.fcmToken;

          if (!fcmToken) {
            logger.warn(
              `수신자의 FCM 토큰이 없습니다: ${recipientId}`
            );
            return;
          }

          // 수신자의 알림 설정 확인
          const settingsDoc = await firestore
            .collection("notification_settings")
            .doc(recipientId)
            .get();

          const settingsData = settingsDoc.data();
          // 전체 알림 비활성화 또는 채팅 알림 비활성화 시 전송하지 않음
          if (settingsData) {
            if (settingsData.enabled === false) {
              logger.info(
                `알림 비활성화 (전체): ${recipientId}`
              );
              return;
            }
            if (settingsData.chatMessages === false) {
              logger.info(
                `알림 비활성화 (채팅): ${recipientId}`
              );
              return;
            }

            // 조용한 시간 확인
            if (settingsData.quietHoursEnabled === true) {
              const now = new Date();
              const currentHour = now.getHours();
              const start = settingsData.quietHoursStart ?? 22;
              const end = settingsData.quietHoursEnd ?? 7;

              // 조용한 시간 범위 체크
              const isQuietTime = start < end ?
                (currentHour >= start && currentHour < end) :
                (currentHour >= start || currentHour < end);

              if (isQuietTime) {
                logger.info(
                  `조용한 시간 (${start}~${end}): ${recipientId}`
                );
                return;
              }
            }
          }

          // 알림 전송
          const message = {
            token: fcmToken,
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
            data: {
              type: "chat_message",
              conversationId: conversationId,
              messageId: messageId,
              senderId: senderId,
              senderNickname: senderNickname,
            },
            apns: {
              payload: {
                aps: {
                  alert: {
                    title: notificationTitle,
                    body: notificationBody,
                  },
                  sound: "default",
                  badge: 1,
                },
              },
            },
            android: {
              priority: "high" as const,
              notification: {
                sound: "default",
                channelId: "chat_messages",
                priority: "high" as const,
              },
            },
          };

          const response = await messaging.send(message);
          logger.info(
            `✅ 채팅 알림 전송 완료: recipientId=${recipientId}, ` +
            `messageId=${response}`
          );
        } catch (error) {
          const errorMessage =
            error instanceof Error ? error.message : String(error);
          logger.error(
            `❌ 채팅 알림 전송 실패: recipientId=${recipientId}, ` +
            `error=${errorMessage}`
          );
        }
      });

      await Promise.all(sendPromises);
      logger.info(
        `🔔 채팅 알림 처리 완료: conversationId=${conversationId}`
      );
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      logger.error(`채팅 알림 처리 실패: ${errorMessage}`);
    }
  }
);
