# mise環境検出ロジック
# scripts/setup-mise-env.shの機能をNixで再実装
{
  pkgs,
  lib,
}:

{
  # 環境を検出して文字列を返す: "ci" | "pi" | "default"
  detectEnvironment =
    pkgs:
    let
      # 環境変数の取得（--impureフラグが必要）
      ci = builtins.getEnv "CI";
      githubActions = builtins.getEnv "GITHUB_ACTIONS";
      wslDistro = builtins.getEnv "WSL_DISTRO_NAME";

      # プラットフォーム情報
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
      isAarch64 = pkgs.stdenv.hostPlatform.isAarch64;
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

      # CI環境の検出
      isCI = ci != "" || githubActions != "";

      # WSL2環境の検出
      isWSL = wslDistro != "" || (builtins.pathExists /proc/version && lib.hasInfix "microsoft" (builtins.readFile /proc/version));

      # Raspberry Pi環境の検出（ARMアーキテクチャ + Linuxの組み合わせ）
      # devicetreeファイルは実行時にしか存在しないため、ここではアーキテクチャのみで判定
      isPi = isLinux && isAarch64 && !isWSL && !isCI;
    in
    if isCI then
      "ci"
    else if isPi then
      "pi"
    else
      "default";

  # 環境に応じた設定ファイルパスを生成
  getConfigPath =
    configHome: environment: "${configHome}/mise/config.${environment}.toml";
}
