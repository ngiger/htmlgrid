{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.libyaml
    pkgs.shared-mime-info
    pkgs.nixfmt-rfc-style
  ];
  env.FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";

  enterShell = ''
    echo This is the devenv shell for htmlgrid
    git --version
    ruby --version
  '';

  # https://devenv.sh/languages/
  # languages.nix.enable = true;

  languages.ruby.enable = true;
  languages.ruby.version = "3.4";
  # Needed for gem mimemagic

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
