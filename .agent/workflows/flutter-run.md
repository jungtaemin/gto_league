---
description: Flutter 앱을 Android 에뮬레이터에서 실행하는 방법
---

# Flutter Run on Android Emulator

## Prerequisites
- Android Studio에서 에뮬레이터가 실행 중이어야 합니다.
- Flutter SDK 경로: `C:\flutter_sdk\bin\flutter.bat`
- JAVA_HOME: `C:\Program Files\Android\Android Studio\jbr`

## Steps

// turbo-all

1. 먼저 기존 flutter 프로세스가 있으면 종료합니다 (선택):
```
cmd /c "taskkill /F /IM dart.exe 2>nul & taskkill /F /IM flutter.bat 2>nul"
```

2. Flutter 앱을 에뮬레이터에서 실행합니다:
```
cmd /c "set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr&& C:\flutter_sdk\bin\flutter.bat run -d emulator-5554"
```
작업 디렉토리: `c:\Users\jtm02\Desktop\antigravity\allinfold\holdem_allin_fold`

## Hot Restart
이미 실행 중인 터미널에 `R` (대문자)을 입력하면 Hot Restart가 됩니다.
소문자 `r`을 입력하면 Hot Reload가 됩니다.

## Notes
- `JAVA_HOME` 환경 변수를 직접 설정해야 Gradle 빌드가 정상 작동합니다.
- 에뮬레이터 ID는 `emulator-5554`입니다. (다를 경우 `flutter devices`로 확인)
