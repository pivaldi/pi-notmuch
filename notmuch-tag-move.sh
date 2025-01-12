#!/bin/bash

## Move $1 to the *relative to $MAILDIR* $2 directory.
function moveTo {
    fromFile="$1"
    toDirectory="${2#/}"            ## Remove first slash if exists.
    toDirectory="${toDirectory=%/}" ## Remove last trailing slash if exists.
    toDirectory="${MAILDIR}/${toDirectory}/new"

    toFile="${fromFile##*/}" ## Filename without directory part.
    toFile="${toFile%%,*}"   ## Remove all after the comma.

    echo "Moving $fromFile to ${toDirectory}/${toFile}"
    mv -f "$fromFile" "${toDirectory}/${toFile}" || exit 1
}

function moveToByFiler {
    filter="$1"
    toDir="$2"

    files=$(notmuch search --output=files "$filter" | grep -v archived)
    echo "notmuch search --output=files $filter | grep -v archived"
    echo -n 'Number of impacted mails is '
    notmuch count -- "$filter"
    echo

    IFS=$'\n'
    for file in $files; do
        moveTo "$file" "$toDir" || exit 1
    done
    unset IFS
}

echo "Moving messages according to notmuch tags"

# Make sure we have updated paths
notmuch new --no-hooks

###{{### Moving IVALDI.ME mails depending of notmuch tags ###
DIR='ivaldi.me'
# DIR_INBOX="$DIR/inbox"
DIR_TRASH="$DIR/trash"
DIR_ARCHIVE="$DIR/archive"

echo 'Processing IVALDI.ME...'
echo 'Removing emails tagged with expire and older than 90 days'
notmuch search --output=files --format=text0 tag:ivaldi.me AND tag:expire AND date:-90d | xargs -r0 rm

echo 'Moving emails tagged with delete to Trash'
moveToByFiler "tag:delete AND tag:ivaldi.me AND NOT folder:$DIR_TRASH" "$DIR_TRASH"

## The mails in the Trash directory are tagged as deleted when syncing…
## So after the next sync, they will be deleted.
echo 'Remove mails tagged as deleted'
notmuch search --output=files --format=text0 tag:ivaldi.me AND tag:deleted | xargs -r0 rm

echo 'Moving archived mails'
moveToByFiler "tag:ivaldi.me AND tag:archived AND NOT folder:$DIR_ARCHIVE" "$DIR_ARCHIVE"

###}}###

###{{### Moving OVYA.FR mails depending of notmuch tags ###
DIR='ovya.fr'
DIR_INBOX="$DIR/inbox"
DIR_TRASH="$DIR/trash"
DIR_ARCHIVE="$DIR/all"

echo 'Processing OVYA.FR...'
echo 'Removing emails tagged with expire and older than 90 days.'
notmuch search --output=files --format=text0 tag:ovya.fr AND tag:expire AND date:-90d | xargs -r0 rm

echo 'Moving archived mails'
moveToByFiler "tag:ovya.fr AND tag:archived AND NOT 'folder:\"${DIR_ARCHIVE}\"'" "$DIR_ARCHIVE"
moveToByFiler "tag:ovya.fr AND NOT tag:inbox AND NOT tag:delete AND 'folder:\"${DIR_INBOX}\"'" "$DIR_ARCHIVE"

echo 'Moving emails tagged with delete to Trash'
moveToByFiler "tag:ovya.fr AND tag:delete AND NOT 'folder:\"$DIR_TRASH\"'" "$DIR_TRASH"

## The mails in the Trash directory are tagged as deleted when syncing…
## So after the next sync, they will be deleted.
echo 'Remove mails tagged as deleted'
notmuch search --output=files --format=text0 tag:ovya.fr AND tag:deleted | xargs -r0 rm

###}}###

# Make sure we have updated paths
notmuch new --no-hooks
