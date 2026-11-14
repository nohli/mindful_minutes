#!/usr/bin/env bash
# Run the existing Android test; retain bounded API 24 installation evidence.
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$repo_root/example"

if [ "${1:?API level required}" != 24 ]; then
  exec flutter test integration_test/unsupported_platform_integration_test.dart
fi

diagnostics="${RUNNER_TEMP:?Runner temporary directory required}/mindful-android-install"
mkdir -p "$diagnostics"
serial="emulator-${EMULATOR_PORT:-5554}"

timeout --kill-after=5s 660s adb -s "$serial" logcat -v threadtime > "$diagnostics/logcat.log" 2>&1 &
logcat_pid=$!
stop_logcat() {
  if kill "$logcat_pid" 2>/dev/null; then
    if wait "$logcat_pid"; then :; fi
  fi
  return 0
}
trap stop_logcat EXIT

capture() {
  local name=$1
  shift
  if timeout --kill-after=2s 10s "$@" > "$diagnostics/$name.log" 2>&1; then
    printf '%s: 0\n' "$name" >> "$diagnostics/commands.txt"
  else
    printf '%s: %s\n' "$name" "$?" >> "$diagnostics/commands.txt"
  fi
}

capture devices-before adb devices -l
capture boot-before adb -s "$serial" shell getprop sys.boot_completed
if timeout --kill-after=30s 600s flutter test --verbose integration_test/unsupported_platform_integration_test.dart > "$diagnostics/flutter.log" 2>&1; then
  test_exit=0
else
  test_exit=$?
fi
printf '%s\n' "$test_exit" > "$diagnostics/test-exit.txt"
cat "$diagnostics/flutter.log"

if [ "$test_exit" -ne 0 ]; then
  capture devices-after adb devices -l
  capture processes adb -s "$serial" shell ps
  capture package adb -s "$serial" shell dumpsys package com.mindfulminutes.mindful_minutes_example
  capture logcat-after adb -s "$serial" logcat -d -v threadtime
fi
exit "$test_exit"
