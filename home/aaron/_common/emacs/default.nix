{ pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
    socketActivation.enable = true;
  };
}

