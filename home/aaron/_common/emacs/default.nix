{ pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-unstable;
      config = ./config.el;
      defaultInitFile = true;
      alwaysEnsure = true;
      extraEmacsPackages = epkgs: with epkgs; [
        (treesit-grammars.with-grammars (grammar: with grammar; [
          tree-sitter-bash
          tree-sitter-c-sharp
          tree-sitter-python
          tree-sitter-rust
        ]))
      ];
    };
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
    socketActivation.enable = true;
  };
}

