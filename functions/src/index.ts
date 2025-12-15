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
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

// Firebase Admin SDK 초기화
initializeApp();

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
    const title = postData.title || "新着お知らせ";
    const body = postData.body || "";

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
      const db = getFirestore();
      const messaging = getMessaging();

      // 해당 성당에 소속된 모든 사용자 조회 (main_parish_id == parishId)
      const usersSnapshot = await db
        .collection("users")
        .where("main_parish_id", "==", parishId)
        .get();

      logger.info(
        `성당 ${parishId}에 소속된 사용자 수: ${usersSnapshot.size}`,
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

      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;

        // 작성자는 알림에서 제외
        if (userId === authorId) {
          continue;
        }

        // FCM 토큰이 있는 사용자만 추가
        if (fcmToken && typeof fcmToken === "string") {
          usersWithToken++;
          messages.push({
            token: fcmToken,
            notification: {
              title: title,
              body: body.length > 100 ? `${body.substring(0, 100)}...` : body,
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
      const db = getFirestore();
      const messaging = getMessaging();

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
