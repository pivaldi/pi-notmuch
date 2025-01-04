;;; pi/notmuch/config.el -*- lexical-binding: t; -*-


;; See https://holgerschurig.github.io/en/emacs-notmuch-hello/
(after! notmuch
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
