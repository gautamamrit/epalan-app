#!/bin/sh
# Usage:
#   ./run.sh dev          → flutter run (local dev)
#   ./run.sh tst          → flutter run (test API)
#   ./run.sh tst build    → flutter build apk (test)
#   ./run.sh prod build   → flutter build appbundle (production)

FLAVOR=${1:-dev}
ACTION=${2:-run}

case "$ACTION" in
  run)
    flutter run --flavor "$FLAVOR" --dart-define=FLAVOR="$FLAVOR"
    ;;
  build)
    if [ "$FLAVOR" = "prod" ]; then
      flutter build appbundle --flavor "$FLAVOR" --dart-define=FLAVOR="$FLAVOR"
    else
      flutter build apk --flavor "$FLAVOR" --dart-define=FLAVOR="$FLAVOR"
    fi
    ;;
  *)
    echo "Usage: ./run.sh [dev|tst|prod] [run|build]"
    ;;
esac
