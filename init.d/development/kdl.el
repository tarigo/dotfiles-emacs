;;; kdl.el --- KDL: конфиги zellij и прочие *.kdl -*- lexical-binding: t -*-

;; При первом открытии .kdl-файла режим сам предложит установить
;; tree-sitter-грамматику (kdl-install-tree-sitter-grammar).
(use-package kdl-mode
  :mode "\\.kdl\\'")

(provide 'development/kdl)
;;; kdl.el ends here
