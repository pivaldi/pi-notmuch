;;; pi/notmuch/config.el -*- lexical-binding: t; -*-

(after! (:and pimacs/notmuch notmuch)
  (setq
   notmuch-saved-searches nil
   pi-notmuch-saved-searches
   `(
     ( :name "Inbox"
             :query "tag:inbox"
             :sort-order newest-first
             :search-type tree
             :key ,(kbd "i"))
     ( :name "Unread Inbox"
             :query "tag:unread and tag:inbox"
             :sort-order newest-first
             :search-type tree
             :key ,(kbd "u"))
     ( :name "Unread"
             :query "tag:unread"
             :sort-order newest-first
             :search-type tree
             :key ,(kbd "U"))
     ( :name "All"
             :query "*"
             :sort-order newest-first
             :search-type tree
             :key ,(kbd "a"))
     ( :name "Archived"
             :query "tag:archived"
             :sort-order newest-first
             :search-type tree
             :key ,(kbd "A"))
     ( :name "Important"
             :query "tag:important"
             :sort-order newest-first
             :search-type tree
             :key ,(kbd "I"))
     ( :name "Starred"
             :query "tag:flagged"
             :sort-order newest-first
             :search-type tree
             :key ,(kbd "s"))
     ))

  (pimacs-notmuch-accounts-saved-searches-set
   `((:account (:name "IVALDI.ME" :query "tag:ivaldi.me" :key-prefix "i")
      :searches ,pi-notmuch-saved-searches)
     (:account (:name "OVYA.FR" :query "tag:ovya.fr" :key-prefix "o")
      :searches
      ,(append
        pi-notmuch-saved-searches
        `(( :name "Redmine"
            :query "tag:redmine"
            :sort-order newest-first
            :search-type tree
            :key ,(kbd "r"))
          ( :name "Admin"
                  :query "tag:admin"
                  :sort-order newest-first
                  :search-type tree
                  :key ,(kbd "d"))
          ( :name "Cron"
                  :query "tag:cron"
                  :sort-order newest-first
                  :search-type tree
                  :key ,(kbd "c"))
          ( :name "Igal/Stanley"
                  :query "tag:igal or tag:stanley"
                  :sort-order newest-first
                  :search-type tree
                  :key ,(kbd "/")))
        ))))

  (setq notmuch-tag-formats (append notmuch-tag-formats
                                    '(("ivaldi.me" (notmuch-apply-face tag 'notmuch-tag-added) "π"))))


  ;; Cosmetic face attributs.
  (set-face-attribute 'notmuch-tree-match-tree-face nil :foreground "black")
  (set-face-attribute 'notmuch-tree-no-match-tree-face nil :foreground "black")
  (set-face-attribute 'notmuch-search-unread-face nil :foreground "grey85")
  (set-face-attribute 'notmuch-search-subject nil :foreground "grey70")

  ;;;; BBDB and Notmuch configuration
  (use-package! bbdb
    :defer nil
    :config
    (setq bbdb-complete-mail-allow-cycling t
          bbdb-file "/home/pi/.emacs.d/.bbdb"
          ;; What do we do when invoking bbdb interactively
          bbdb-mua-update-interactive-p '(query . create)
          ;; Make sure we look at every address in a message and not only the
          ;; first one
          bbdb-message-all-addresses t
          ;; If non-nil, display an auto-updated BBDB window while using a MUA.
          ;; If ’horiz, stack the window horizontally if there is room.
          ;; If this is nil, BBDB is updated silently.
          bbdb-mua-pop-up nil
          )

    ;; ;; Commented because this does not work as is.
    ;; ;; I use notmuch-address instead. See futher.
    ;; (bbdb-initialize 'notmuch 'message)
    ;; (bbdb-mua-auto-update-init 'notmuch 'message)

    (map!
     :map notmuch-message-mode-map
     :desc "Complete the user name or mail before point. #pi" "M-<SPC>" #'bbdb-complete-mail)
    ;; (defalias 'notmuch-address-expand-name 'bbdb-complete-mail)
    )

  ;; In conjonction with BBDB binded to M-SPC, I use
  ;; https://github.com/aperezdc/notmuch-addrlookup-c as default mail completion command.
  ;; See https://notmuchmail.org/emacstips/#index12h2
  (require 'notmuch-address)
  (setq notmuch-address-command "/usr/local/bin/notmuch-addrlookup")
  (notmuch-address-message-insinuate)

  ;;;; gnus-alias and Notmuch configuration
  (autoload 'gnus-alias-determine-identity "gnus-alias" "" t)
  (add-hook 'message-setup-hook 'gnus-alias-determine-identity)
  ;; Don't prompt for the From: address when composing or forwarding a message.
  ;; I use gnus-alias-select-identity instead
  (setq notmuch-always-prompt-for-sender nil)
  (map!
   :map notmuch-message-mode-map
   :desc "" "C-c g" #'gnus-alias-select-identity)

  (after! gnus-alias
    :defer t
    :config
    (setq gnus-alias-allow-forward-as-reply t
          gnus-alias-overlay-identities nil
          gnus-alias-unknown-identity-rule 'continue
          )
    )
  )

(provide 'pi/notmuch)
;; config.el ends here.

;; Local variables:
;; coding: utf-8
;; eval: (rename-buffer "pi/notmuch/config.el")
;; End:
