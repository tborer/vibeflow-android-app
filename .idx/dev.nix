{ pkgs, ... }: {
  packages = [
    pkgs.unzip
    pkgs.wget
    pkgs.jdk17
  ];

  env = {
    JAVA_HOME = "${pkgs.jdk17}";
    GEMINI_API_KEY = "AIzaSyCuTGRqe5qurdhZiFivq2ovv0tGLuaQeaU";
    # Use relative paths or environment variables instead of hardcoded /home/user
    ANDROID_HOME = "$HOME/android-sdk";
    ANDROID_SDK_ROOT = "$HOME/android-sdk";
    PATH = "$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools";
  };

  idx = {
    extensions = ["google.gemini"];
    
    workspace = {
      onCreate = {
        install-sdk = ''
          mkdir -p "$ANDROID_HOME"
          cd "$ANDROID_HOME"
          if [ ! -f "commandlinetools-linux-10406996_latest.zip" ]; then
            wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
          fi
          if [ ! -d "cmdline-tools/latest" ]; then
            unzip -o commandlinetools-linux-10406996_latest.zip
            rm -f commandlinetools-linux-10406996_latest.zip
            mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
            mv cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/"
            rmdir cmdline-tools
          fi
        '';
        accept-licenses = ''yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses'';
        install-platform-tools = ''"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools"'';
      };
      onStart = {
        gradle-permissions = "chmod +x ./gradlew";
      };
    };
  };
}