#!/bin/bash

# 프로젝트 정보
PROJECT_ID="credo-ceda9"

echo "=== 프로젝트 번호 확인 ==="
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)" 2>/dev/null)

if [ -z "$PROJECT_NUMBER" ]; then
  echo "❌ 프로젝트 번호를 자동으로 확인할 수 없습니다."
  echo "Google Cloud Console에서 프로젝트 번호를 확인하세요:"
  echo "https://console.cloud.google.com/iam-admin/settings?project=$PROJECT_ID"
  echo ""
  read -p "프로젝트 번호를 수동으로 입력하세요: " PROJECT_NUMBER
else
  echo "✅ 프로젝트 번호: $PROJECT_NUMBER"
fi

echo ""
echo "=== Cloud Functions 기본 서비스 계정 확인 ==="
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
APPSPOT_SA="${PROJECT_ID}@appspot.gserviceaccount.com"

echo "Compute Engine 서비스 계정: $COMPUTE_SA"
echo "App Engine 서비스 계정: $APPSPOT_SA"

echo ""
echo "=== FCM API 권한 부여 ==="

# Compute Engine 서비스 계정에 권한 부여
echo "1. Compute Engine 서비스 계정에 권한 부여 중..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$COMPUTE_SA" \
  --role="roles/firebasecloudmessaging.admin" \
  --condition=None 2>&1

if [ $? -eq 0 ]; then
  echo "✅ Compute Engine 서비스 계정 권한 부여 완료"
else
  echo "⚠️  Compute Engine 서비스 계정 권한 부여 실패 (이미 권한이 있을 수 있습니다)"
fi

# App Engine 서비스 계정에 권한 부여
echo ""
echo "2. App Engine 서비스 계정에 권한 부여 중..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$APPSPOT_SA" \
  --role="roles/firebasecloudmessaging.admin" \
  --condition=None 2>&1

if [ $? -eq 0 ]; then
  echo "✅ App Engine 서비스 계정 권한 부여 완료"
else
  echo "⚠️  App Engine 서비스 계정 권한 부여 실패 (이미 권한이 있을 수 있습니다)"
fi

echo ""
echo "=== 권한 확인 ==="
echo "Compute Engine 서비스 계정 권한:"
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:$COMPUTE_SA" \
  --format="table(bindings.role)" 2>/dev/null | grep -i firebase || echo "권한 없음"

echo ""
echo "App Engine 서비스 계정 권한:"
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:$APPSPOT_SA" \
  --format="table(bindings.role)" 2>/dev/null | grep -i firebase || echo "권한 없음"

echo ""
echo "=== 완료 ==="
echo "권한 부여가 완료되었습니다. Cloud Functions를 재배포한 후 테스트해보세요:"
echo "  cd functions && npm run build && firebase deploy --only functions:sendTestNotification"

