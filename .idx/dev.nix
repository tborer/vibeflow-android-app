{ pkgs, ... }: {
  # This is the main configuration file for your workspace.
  # It's written in the Nix language and specifies all the packages,
  # extensions, and configurations needed for your project.
  packages = [
    # Add android-tools to provide adb and other utilities.
    pkgs.android-tools
    pkgs.unzip
    pkgs.wget
    pkgs.jdk17
    pkgs.imagemagick
  ];

  env = {
    # Set the JAVA_HOME environment variable for Java-based tools.
    JAVA_HOME = "${pkgs.jdk17}";
    GEMINI_API_KEY = "AIzaSyCuTGRqe5qurdhZiFivq2ovv0tGLuaQeaU";
  };

  idx = {
    # A list of VS Code extensions to install from the Open VSX Registry.
    extensions = ["google.gemini"];
    
    workspace = {
      # The onStart hook runs every time you start or restart your workspace.
      onStart = {
        # Make the gradlew script executable.
        gradle-permissions = "chmod +x ./gradlew";
      };
    };
  };
}
