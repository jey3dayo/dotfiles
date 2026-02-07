# Custom Home Manager module for mise configuration
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.mise-config;
  envDetect = import ./mise-env-detect.nix { inherit pkgs lib; };

  # 環境の決定: ユーザー指定 > 自動検出
  environment = if cfg.environment != null then cfg.environment else envDetect.detectEnvironment pkgs;

  # 設定ファイルパスの生成
  configFilePath = envDetect.getConfigPath config.xdg.configHome environment;
in
{
  options.programs.mise-config = {
    enable = lib.mkEnableOption "mise configuration management";

    configDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to the directory containing mise configuration files (*.toml)";
      example = lib.literalExpression "./mise";
    };

    environment = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "ci"
        "pi"
        "default"
      ]);
      default = null;
      description = ''
        Override the environment detection. If null, the environment will be automatically detected.
        - "ci": GitHub Actions or other CI environments
        - "pi": Raspberry Pi (ARM Linux)
        - "default": macOS, WSL2, or standard Linux
      '';
    };

    installTasks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install mise tasks from the tasks/ subdirectory";
    };
  };

  config = lib.mkIf cfg.enable {
    # mise設定ファイルの配置
    xdg.configFile =
      let
        # 基本設定ファイル（常に配置）
        baseFiles = {
          "mise/config.toml".source = "${cfg.configDir}/config.toml";
          "mise/config.default.toml".source = "${cfg.configDir}/config.default.toml";
          "mise/config.pi.toml".source = "${cfg.configDir}/config.pi.toml";
          "mise/config.ci.toml".source = "${cfg.configDir}/config.ci.toml";
        };

        # tasksディレクトリの配置（オプション）
        taskFiles =
          if cfg.installTasks then
            let
              taskDir = "${cfg.configDir}/tasks";
              taskExists = builtins.pathExists taskDir;
            in
            if taskExists then
              {
                "mise/tasks" = {
                  source = taskDir;
                  recursive = true;
                };
              }
            else
              { }
          else
            { };
      in
      baseFiles // taskFiles;

    # 環境変数の設定
    home.sessionVariables = {
      MISE_CONFIG_FILE = configFilePath;
    };

    # ホームディレクトリに.mise ディレクトリを作成
    # （mise自体が初回実行時に作成するが、事前に作成しておく）
    home.activation.createMiseDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.mise
    '';
  };
}
