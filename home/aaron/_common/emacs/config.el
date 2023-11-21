; sample config file

;; GUI
(menu-bar-mode -1)
(tool-bar-mode -1)

(setq use-short-answers t)

(setq ring-bell-function 'ignore)
(setq-default indent-tabs-mode nil)

;; Theme
(load-theme 'modus-vivendi t)

;; Backups
(setq
  ; don't clobber symlinks
  backup-by-copying t 

  ; don't litter my fs tree
  backup-directory-alist '(("." . "~/.saves/"))
  delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

;; Tree sitter
(use-package tree-sitter :ensure t)
(use-package tree-sitter-langs :ensure t)
(use-package tree-sitter-indent :ensure t)

