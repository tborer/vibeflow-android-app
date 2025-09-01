{ pkgs, ... }: {
  # Add your Nix packages here
  packages = [
    pkgs.unzip # For unzipping the Android SDK
    pkgs.wget # For downloading the Android SDK
    pkgs.jdk17 # Use specific Java 17 for Android development
  ];

  # Add environment variables here
  env = {
    # Set JAVA_HOME to the Nix package for Java 17
    JAVA_HOME = "${pkgs.jdk17}";
    GEMINI_API_KEY = "AIzaSyCuTGRqe5qurdhZiFivq2ovv0tGLuaQeaU";
    ANDROID_HOME = "/home/user/android-sdk";
    ANDROID_SDK_ROOT = "/home/user/android-sdk";
    PATH = "$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools";
  };

  # Set up VS Code extensions
  idx = {
    extensions = [
      "google.gemini"
    ];

      # Workspace lifecycle hooks
      workspace = {
        onCreate = {
          # Download and unzip the Android SDK
          install-sdk = ''
            mkdir -p $ANDROID_HOME
            cd $ANDROID_HOME
            wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
            unzip commandlinetools-linux-10406996_latest.zip
            rm commandlinetools-linux-10406996_latest.zip
            mkdir -p $ANDROID_HOME/cmdline-tools/latest
            mv cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/
          '';
          # Accept licenses
          accept-licenses = "yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses";
          # Install platform-tools
          install-platform-tools = ''$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools"'';
        };
        onStart = {
          # Grant execute permissions to gradlew
          gradle-permissions = "chmod +x ./gradlew";
          # Start the app
          start-app = "./gradlew assembleDebug";
        };
      };

      # Previews
      previews = {
        enable = true;
        previews = {
          web = {
            command = ["./gradlew" "assembleDebug"];
            manager = "web";
          };
        };
      };
    };
}