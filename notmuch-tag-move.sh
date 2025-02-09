#!/bin/bash

## Move $1 to the *relative to $MAILDIR* $2 directory.
function moveTo {
    fromFile="$1"
    toDirectory="${2#/}"            ## Remove first slash if exists.
    toDirectory="${toDirectory=%/}" ## Remove last trailing slash if exists.
    toDirectory="${MAILDIR}/${toDirectory}/cur"

    toFile="${fromFile##*/}" ## Filename without directory part.
    toFile="${toFile%%,*}"   ## Remove all after the comma.

    echo "Moving $fromFile to ${toDirectory}/${toFile}"
    mv -f "$fromFile" "${toDirectory}/${toFile}" || exit 1
}

function moveToByFiler {
    filter="$1"
    toDir="$2"

    files=$(notmuch search --exclude=false --output=files -- "$filter")
    echo "notmuch search --output=files $filter"
    echo -n 'Number of impacted mails is '
    notmuch count -- "$filter"
    echo

    IFS=$'\n'
    for file in $files; do
        moveTo "$file" "$toDir" || exit 1
    done
    unset IFS
}

function moveExpireToTrash {
    account="$1"
    trashDir="$account/trash"
    echo "Account $account -- Moving emails tagged with expire and older than 90 days to ${trashDir}."
    moveToByFiler "tag:$account AND tag:expire AND (NOT tag:deleted) AND (NOT tag:delete) AND date:-90d" "$trashDir"
}

function delete {
    filter="$1"
    files=$(notmuch search --exclude=false --output=files --format=text0 -- "$filter")
    echo "Removing emails filtered by '${filter}'."
    echo -n 'Number of impacted mails is '
    notmuch count -- "$filter"
    echo
    # notmuch search --exclude=false --output=files --format=text0 -- "$filter" | xargs -r0 rm

    IFS=$'\n'
    for file in $files; do
        echo -n "Removing file $file  "
        rm "$file" && echo '[DONE]' || echo '[FAILED]'
    done
    unset IFS
}

function deleteFromTrash30d {
    account="$1"
    echo "Account $account -- Removing emails tagged deleted from 30 days."
    delete "tag:$account AND tag:deleted AND date:-30d"
}

function synchronizeNotmuch {
    echo "Synchronizing notmuch without hook"
    notmuch new --no-hooks
}

# Make sure we have updated paths
synchronizeNotmuch

echo "Moving messages according to notmuch tags"

###{{### Moving IVALDI.ME mails depending of notmuch tags ###
DIR='ivaldi.me'
# DIR_INBOX="$DIR/inbox"
DIR_TRASH="$DIR/trash"
DIR_ARCHIVE="$DIR/archive"

echo 'Processing IVALDI.ME...'
moveExpireToTrash "ivaldi.me"

echo 'Moving archived mails'
moveToByFiler "tag:ivaldi.me AND tag:archived AND (NOT folder:$DIR_ARCHIVE)" "$DIR_ARCHIVE"

echo 'Moving emails tagged with delete to Trash'
moveToByFiler "tag:delete AN (NOT tag:deleted) AND tag:ivaldi.me AND (NOT folder:$DIR_TRASH)" "$DIR_TRASH"

echo 'Remove mails tagged as deleted 30 days old'
delete "tag:ivaldi.me AND tag:deleted AND date:-30d AND 'folder:\"$DIR_TRASH\"'"

###}}###

###{{### Moving OVYA.FR mails depending of notmuch tags ###
DIR='ovya.fr'
DIR_INBOX="$DIR/inbox"
DIR_TRASH="$DIR/trash"
DIR_ARCHIVE="$DIR/all"

echo 'Processing OVYA.FR...'
moveExpireToTrash "ovya.fr"

echo 'Moving archived mails'
moveToByFiler "tag:ovya.fr AND tag:archived AND (NOT tag:deleted) AND (NOT tag:delete) AND (NOT 'folder:\"${DIR_ARCHIVE}\"')" "$DIR_ARCHIVE"

echo 'Moving Gmail un-boxed mails to archive'
moveToByFiler "tag:ovya.fr AND (NOT tag:archived) AND (NOT tag:inbox) AND (NOT tag:deleted) AND (NOT tag:delete) AND 'folder:\"${DIR_INBOX}\"'" "$DIR_ARCHIVE"

echo 'Moving emails tagged with delete to Trash'
moveToByFiler "tag:ovya.fr AND (NOT tag:archived) AND tag:delete AND (NOT tag:deleted) AND (NOT 'folder:\"$DIR_TRASH\"')" "$DIR_TRASH"

echo 'Removing emails tagged deleted 30 days old.'
delete "tag:ovya.fr AND tag:deleted AND date:-30d AND 'folder:\"$DIR_TRASH\"'"

###}}###

# Make sure we have updated paths
synchronizeNotmuch
