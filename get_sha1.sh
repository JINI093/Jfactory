#!/bin/bash

# SHA-1 인증서 지문 확인 스크립트

echo "🔍 SHA-1 인증서 지문 확인 중..."

# Debug keystore 경로
KEYSTORE_PATH="$HOME/.android/debug.keystore"

# Java 경로 확인
JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)

if [ -z "$JAVA_HOME" ]; then
    echo "❌ Java가 설치되어 있지 않습니다."
    echo ""
    echo "Java를 설치하려면 다음 명령어를 실행하세요:"
    echo "  brew install openjdk@11"
    echo ""
    echo "또는 Android Studio의 내장 Java를 사용하세요:"
    echo "  Android Studio → File → Project Structure → SDK Location"
    echo "  JDK Location 경로를 확인하고 아래 명령어를 실행하세요"
    exit 1
fi

# keytool 경로
KEYTOOL="$JAVA_HOME/bin/keytool"

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Debug keystore를 찾을 수 없습니다: $KEYSTORE_PATH"
    echo ""
    echo "Debug keystore를 생성하려면 Android Studio에서 앱을 한 번 빌드하세요."
    exit 1
fi

echo "✅ Debug keystore 발견: $KEYSTORE_PATH"
echo ""
echo "SHA-1 인증서 지문:"
echo "----------------------------------------"

$KEYTOOL -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 2 "SHA1:"

echo ""
echo "----------------------------------------"
echo ""
echo "위의 SHA1: 뒤의 값을 복사하여 Firebase Console에 등록하세요."

