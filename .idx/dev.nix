{ pkgs, ... }: {
  # Using the unstable channel for more up-to-date packages for Android development.
  channel = "unstable";

  packages = [
    pkgs.gradle
    pkgs.kotlin
    pkgs.jdk17
    # Replaced pkgs.android-studio with the more lightweight and appropriate android-sdk
    pkgs.android-sdk
  ];

  env = {
    # Correctly set JAVA_HOME
    JAVA_HOME = "${pkgs.jdk17}";
    # Correctly set ANDROID_HOME and ANDROID_SDK_ROOT
    ANDROID_HOME = "${pkgs.android-sdk}";
    ANDROID_SDK_ROOT = "${pkgs.android-sdk}";
  };

  idx = {
    extensions = [
      # Corrected Kotlin extension ID
      "fwcd.kotlin"
      # Corrected Android extension ID
      "ms-android.android-pack"
    ];

    workspace = {
      onCreate = {
        # Accept Android SDK licenses using the correct sdkmanager path
        accept-licenses = "yes | ${pkgs.android-sdk}/cmdline-tools/latest/bin/sdkmanager --licenses";
        # Install required SDK components
        install-sdk = "${pkgs.android-sdk}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"";
        # Setup gradle wrapper
        gradle-wrapper = "cd app && ./gradlew wrapper || gradle wrapper";
      };
      
      onStart = {
        # The onStart hook is a good place to run dev servers or other tasks that should start with the workspace.
        # For this project, we'll leave it empty for now.
      };
    };
  };
}
