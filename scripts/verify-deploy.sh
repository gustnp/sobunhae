#!/usr/bin/env bash
# 배포 확인 스크립트: 로컬(git) 파일과 실제 배포된 GitHub Pages 페이지를 문자수로 비교.
# GitHub Pages 배포는 몇십 초~몇 분씩 걸릴 때가 있어서, 그냥 시간으로 기다리지 않고
# "진짜 반영됐는지"를 매번 이 스크립트로 확인하는 습관을 들이기 위한 용도.
#
# 사용법:
#   ./scripts/verify-deploy.sh index.html
#   ./scripts/verify-deploy.sh admin.html HEAD~1   # 특정 커밋 기준으로 비교하고 싶을 때
set -euo pipefail

FILE="${1:-index.html}"
REF="${2:-HEAD}"
BASE_URL="https://gustnp.github.io/sobunhae"

if [ "$FILE" = "index.html" ]; then
  URL="${BASE_URL}/"
else
  URL="${BASE_URL}/${FILE}"
fi

EXPECTED=$(git show "${REF}:${FILE}" | wc -m)
LIVE=$(curl -s -H "Cache-Control: no-cache" "$URL" | wc -m)
DIFF=$(( EXPECTED - LIVE ))
DIFF=${DIFF#-}

echo "파일: $FILE (기준 커밋: $REF)"
echo "로컬 문자수: $EXPECTED"
echo "라이브 문자수: $LIVE"

if [ "$DIFF" -le 15 ]; then
  echo "OK — 배포가 반영된 것으로 보여요 (오차 ${DIFF}자 이내, 인코딩 차이 정도)"
  exit 0
else
  echo "MISMATCH — 아직 반영 안 됐거나 다른 내용이 떠있어요. 잠시 후 다시 실행해보세요."
  exit 1
fi
