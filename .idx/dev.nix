{ pkgs, ... }: {
  # Add your Nix packages here
  packages = [
    pkgs.unzip # For unzipping the Android SDK
    pkgs.wget  # For downloading the Android SDK
    pkgs.jdk17 # Use specific Java 17 for Android development
  ];

  # Add environment variables here
  env = {
    GEMINI_API_KEY = "AIzaSyCuTGRqe5qurdhZiFivq2ovv0tGLuaQeaU";
    ANDROID_HOME = "/home/user/android-sdk";
    ANDROID_SDK_ROOT = "/home/user/android-sdk";
    PATH = "$PATH:/home/user/android-sdk/cmdline-tools/latest/bin:/home/user/android-sdk/platform-tools";
  };

  # Set up VS Code extensions
  idx = {
    extensions = [
      "google.gemini"
    ];

    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        # Download and set up the Android SDK
        sdk-setup = ''
          echo "Setting up Android SDK..."
          mkdir -p $HOME/android-sdk/cmdline-tools
          
          # Download Android command line tools
          cd /tmp
          wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
          
          # Extract to correct location
          unzip -q commandlinetools-linux-11076708_latest.zip -d $HOME/android-sdk/cmdline-tools
          mv $HOME/android-sdk/cmdline-tools/cmdline-tools $HOME/android-sdk/cmdline-tools/latest
          
          # Make sure tools are executable
          chmod +x $HOME/android-sdk/cmdline-tools/latest/bin/*
          
          # Accept all licenses (with timeout to prevent hanging)
          echo "Accepting Android SDK licenses..."
          timeout 30s bash -c 'yes | $HOME/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses' || true
          
          # Install required SDK components
          echo "Installing SDK components..."
          $HOME/android-sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;34.0.0" "platforms;android-34" "platform-tools"
          
          echo "Android SDK setup complete!"
        '';
      };
      
      # Runs every time the workspace is (re)started
      onStart = {
        # Verify SDK setup
        sdk-verify = ''
          echo "Verifying Android SDK..."
          if [ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]; then
            echo "Android SDK found at $ANDROID_HOME"
            $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --list_installed | head -10
          else
            echo "Android SDK not found. Please check the setup."
          fi
        '';
      };
    };
  };
}