;;; pi/notmuch/config.el -*- lexical-binding: t; -*-


;; See https://holgerschurig.github.io/en/emacs-notmuch-hello/
(after! notmuch
  (setq
   notmuch-saved-searches
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
     ))

  (setq pimacs-notmuch-accounts-saved-searches
        `((:account (:name "IVALDI.ME" :query "tag:ivaldi.me" :key ,(kbd "i"))
           :searches ,notmuch-saved-searches)
          (:account (:name "OVYA.FR" :query "tag:ovya.fr" :key ,(kbd "C-o"))
           :searches
           ,(append
             notmuch-saved-searches
             `(( :name "Redmine"
                 :query "tag:redmine"
                 :sort-order newest-first
                 :search-type tree
                 :key ,(kbd "r"))
               ( :name "Admin"
                       :query "tag:admin"
                       :sort-order newest-first
                       :search-type tree
                       :key ,(kbd "A"))
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

  (set-face-attribute 'notmuch-tree-match-tree-face nil :foreground "black")
  (set-face-attribute 'notmuch-search-unread-face nil :foreground "grey85")
  (set-face-attribute 'notmuch-search-subject nil :foreground "grey70")

  (autoload 'gnus-alias-determine-identity "gnus-alias" "" t)
  (add-hook 'message-setup-hook 'gnus-alias-determine-identity)
  )

(after! gnus-alias
  (setq gnus-alias-allow-forward-as-reply t
        gnus-alias-overlay-identities nil
        gnus-alias-unknown-identity-rule 'continue)
  )

(provide 'pi/notmuch)
;; config.el ends here.

;; Local variables:
;; coding: utf-8
;; eval: (rename-buffer "pi/notmuch/config.el")
;; End:
