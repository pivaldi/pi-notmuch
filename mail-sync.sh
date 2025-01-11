#!/bin/bash

[ -z "$MAILDIR" ] && {
    echo 'MAILDIR env var is not set.'
    echo 'Process aborted.'
    exit 1
}

ACCOUNTS="ivaldi.me ovya.fr"

for ACCOUNT in $ACCOUNTS; do
    DIR="${MAILDIR}/$ACCOUNT"
    [ -e "$DIR" ] || mkdir -p "$DIR"
done

while true ;do
    ## Move mails depending of previous notmuch tags.
    mail-sync-tag-move.sh

    mbsync --config "${HOME}/.isyncrc" --all || exit 1

    notmuch new --no-hooks

    mail-sync-notify.sh

    ## Tag new mails.
    mail-sync-tag-do.sh

    echo 'Waiting for 120s to sync again. Press [ENTER] to pass over…'
    read -r -t 120
done
