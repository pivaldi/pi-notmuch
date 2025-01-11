;; -*- no-byte-compile: t; -*-
;;; pi/notmuch/packages.el

;; IMPORTANT: Remember to run doom sync -u after changing recipes for existing packages.
(package! my-package
  :recipe (:local-repo "/usr/local/share/emacs/site-lisp"
           :files ("notmuch*.el" "coolj.el")))

(package! bbdb)
(package! gnus-alias)
