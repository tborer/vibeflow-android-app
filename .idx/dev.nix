{ pkgs, ... }: {
  # Using the unstable channel for more up-to-date packages for Android development.
  channel = "unstable";

  packages = [
    pkgs.gradle
    pkgs.kotlin
    pkgs.jdk17
    # Use android-studio instead of android-sdk (which doesn't exist)
    pkgs.android-studio
    pkgs.android-tools
  ];

  env = {
    # Correctly set JAVA_HOME
    JAVA_HOME = "${pkgs.jdk17}";
    # Correctly set ANDROID_HOME and ANDROID_SDK_ROOT using android-studio
    ANDROID_HOME = "${pkgs.android-studio}/android-sdk";
    ANDROID_SDK_ROOT = "${pkgs.android-studio}/android-sdk";
    # Add Android SDK tools to PATH
    PATH = "${pkgs.android-studio}/android-sdk/cmdline-tools/latest/bin:${pkgs.android-studio}/android-sdk/platform-tools:$PATH";
  };

  idx = {
    extensions = [
      # Corrected Kotlin extension ID
      "fwcd.kotlin"
      # Alternative Android extension
      "vscjava.vscode-android"
    ];

    workspace = {
      onCreate = {
        # Accept Android SDK licenses using the correct sdkmanager path
        accept-licenses = ''
          yes | ${pkgs.android-studio}/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses || true
        '';
        # Install required SDK components INCLUDING NDK
        install-sdk = ''
          ${pkgs.android-studio}/android-sdk/cmdline-tools/latest/bin/sdkmanager \
            "platform-tools" \
            "platforms;android-34" \
            "build-tools;34.0.0" \
            "ndk;25.1.8937393" || true
        '';
        # Setup gradle wrapper
        gradle-wrapper = ''
          cd app && (./gradlew wrapper || gradle wrapper) || true
        '';
      };
      
      onStart = {};
    };
  };
}