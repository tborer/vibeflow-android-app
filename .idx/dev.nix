{ pkgs, ... }: {
  packages = [
    pkgs.unzip
    pkgs.wget
    pkgs.jdk17
  ];

  env = {
    JAVA_HOME = "${pkgs.jdk17}";
    GEMINI_API_KEY = "AIzaSyCuTGRqe5qurdhZiFivq2ovv0tGLuaQeaU";
  };

  idx = {
    extensions = ["google.gemini"];
    
    workspace = {
      onCreate = {
        install-sdk = ''
          # Use workspace-relative path instead of $HOME
          ANDROID_HOME="$(pwd)/android-sdk"
          mkdir -p "$ANDROID_HOME"
          cd "$ANDROID_HOME"
          
          if [ ! -f "commandlinetools-linux-10406996_latest.zip" ]; then
            wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
          fi
          
          if [ ! -d "cmdline-tools/latest" ]; then
            unzip -o commandlinetools-linux-10406996_latest.zip
            rm -f commandlinetools-linux-10406996_latest.zip
            mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
            mv cmdline-tools/* "$ANDROID_HOME/cmdline-tools/latest/" 2>/dev/null || true
            rmdir cmdline-tools 2>/dev/null || true
          fi
          
          # Set up environment for subsequent commands
          export ANDROID_HOME="$ANDROID_HOME"
          export ANDROID_SDK_ROOT="$ANDROID_HOME"
          export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
          
          # Accept licenses
          yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses || true
          
          # Install platform tools
          "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" || true
        '';
      };
      
      onStart = {
        setup-android-env = ''
          export ANDROID_HOME="$(pwd)/android-sdk"
          export ANDROID_SDK_ROOT="$ANDROID_HOME"
          export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
        '';
        gradle-permissions = "chmod +x ./gradlew";
      };
    };
  };
}