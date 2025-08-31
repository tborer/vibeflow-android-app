
{ pkgs, ... }: {
  # Add your Nix packages here
  packages = [
    pkgs.unzip # For unzipping the Android SDK
  ];

  # Add environment variables here
  env = {
    GEMINI_API_KEY = "AIzaSyCuTGRqe5qurdhZiFivq2ovv0tGLuaQeaU";
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
          mkdir -p $HOME/android-sdk
          wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
          unzip -q commandlinetools-linux-11076708_latest.zip -d $HOME/android-sdk/cmdline-tools
          mv $HOME/android-sdk/cmdline-tools/cmdline-tools $HOME/android-sdk/cmdline-tools/latest
          # Accept all licenses
          yes | $HOME/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses
          $HOME/android-sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;34.0.0" "platforms;android-34"
        '';
      };

      # Runs every time the workspace is (re)started
      onStart = {
        # Set Android environment variables
        android-env = ''
          export ANDROID_HOME=$HOME/android-sdk
          export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0
        '';
      };
    };
  };
}
