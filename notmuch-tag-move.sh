#!/bin/bash

## Move $1 to the *relative to $MAILDIR* $2 directory.
function moveTo {
    fromFile="$1"
    toDirectory="${2#/}"           ## Remove first slash if exists.
    toDirectory="${toDirectory%/}" ## Remove last trailing slash if exists.
    toDirectory="${MAILDIR}/${toDirectory}/cur"

    toFile="${fromFile##*/}" ## Filename without directory part.
    toFile="${toFile%%,*}"   ## Remove all after the comma.

    echo "Moving $fromFile to ${toDirectory}/${toFile}"
    mv -f "$fromFile" "${toDirectory}/${toFile}" || exit 1
}

function moveToByFilter {
    filter="$1"
    toDir="$2"

    files="$(notmuch search --exclude=false --output=files -- "$filter")"
    echo "notmuch search --output=files $filter"
    echo -n 'Number of impacted mails is '
    notmuch count --exclude=false -- "$filter"
    echo

    IFS=$'\n'
    for file in $files; do
        moveTo "$file" "$toDir" || exit 1
    done
    unset IFS
}

function delete {
    filter="$1"
    files="$(notmuch search --exclude=false --output=files -- "$filter")"
    echo "Removing emails filtered by '${filter}'."
    echo -n 'Number of impacted mails is '
    notmuch count --exclude=false -- "$filter"
    echo

    IFS=$'\n'
    for file in $files; do
        echo -n "Removing file $file  "
        rm "$file" && echo '[DONE]' || {
            echo '[FAILED]'
        }
    done
    unset IFS
}

## Move/remove the mails of one mailbox according to the tags set by .notmuch-tagging.
## $1 = mailbox directory relative to $MAILDIR, $2 = account tag set by .notmuch-tagging.
function processMailbox {
    dir="$1"
    accountTag="$2"
    scope="tag:${accountTag} AND path:\"${dir}/**\""
    trashDir="${dir}/trash"
    archiveDir="${dir}/archive"
    starredDir="${dir}/starred"

    echo "Processing ${dir} (tag:${accountTag})..."

    echo 'Moving emails tagged expire and older than 90 days to trash'
    moveToByFilter "${scope} AND tag:expire AND (NOT tag:deleted) AND (NOT tag:delete) AND date:..90d AND (NOT folder:\"${trashDir}\")" "$trashDir"

    echo 'Moving archived mails'
    moveToByFilter "${scope} AND tag:archived AND (NOT folder:\"${archiveDir}\")" "$archiveDir"

    echo 'Moving emails tagged delete to trash'
    moveToByFilter "${scope} AND tag:delete AND (NOT folder:\"${trashDir}\")" "$trashDir"

    echo 'Removing emails tagged deleted and older than 30 days'
    delete "${scope} AND tag:deleted AND date:..30d AND folder:\"${trashDir}\""
}

function synchronizeNotmuch {
    echo "Synchronizing notmuch without hook"
    notmuch new --no-hooks
}

# Make sure we have updated paths
synchronizeNotmuch

echo "Moving messages according to notmuch tags"

###{{### Proton mailboxes: move/remove depending on notmuch tags ###
processMailbox 'ivaldi.me' 'ivaldi.me'
processMailbox 'catchall@ivaldi.me' 'ivaldi.me'
processMailbox 'pi@piprim.fr' 'piprim'
processMailbox 'pi@piprime.fr' 'piprim'
processMailbox 'piprim@pm.me' 'piprim'
###}}###

###{{### Moving OVYA.FR mails depending of notmuch tags ###
DIR='ovya.fr'
DIR_TRASH="$DIR/trash"
DIR_ARCHIVE="$DIR/all"

echo 'Processing OVYA.FR...'
echo 'Removing emails tagged expire 90 days old.'
delete "tag:ovya.fr AND tag:expire AND (NOT tag:deleted) AND (NOT tag:delete) AND date:..90d"
# moveExpireToTrash "ovya.fr"

# echo 'Moving archived mails'
# moveToByFilter "tag:ovya.fr AND tag:archived AND (NOT tag:deleted) AND (NOT tag:delete) AND (NOT 'folder:\"${DIR_ARCHIVE}\"')" "$DIR_ARCHIVE"

# echo 'Moving Gmail un-boxed mails to archive'
# moveToByFilter "tag:ovya.fr AND (NOT tag:archived) AND (NOT tag:inbox) AND (NOT tag:deleted) AND (NOT tag:delete) AND 'folder:\"${DIR_INBOX}\"'" "$DIR_ARCHIVE"

# To delete a Gmail message using mbsync, you need to configure Gmail to move
# the message to the "Trash" folder instead of just hiding it. This involves
# adjusting Gmail's settings:
# Go to Gmail settings and under the "Labels"
# section, uncheck "Show in IMAP" for "All Mail". In the "Forwarding and
# POP/IMAP" section, uncheck "Auto-Expunge" for "When I mark a message in IMAP
# as deleted". Also in the "Forwarding and POP/IMAP" section, check "Move the
# message to the Trash" for "When a message is marked as deleted and expunged
# from the last visible IMAP folder". After configuring Gmail, you can delete
# messages in your local mail client, and mbsync will sync the deletion to the
# Gmail "Trash" folder. However, note that messages in the "Trash" folder are
# not permanently deleted and will be automatically removed after 30 days.

# If you want to ensure that messages are permanently deleted, you can use a
# script to delete the files corresponding to the messages in your local maildir
# and then run notmuch new to update the database. This will cause mbsync to
# delete the messages on the server as well.

# echo 'Moving emails tagged with delete to Trash'
# moveToByFilter "tag:ovya.fr AND (NOT tag:archived) AND tag:delete AND (NOT tag:deleted) AND (NOT 'folder:\"$DIR_TRASH\"')" "$DIR_TRASH"

echo 'Removing emails tagged deleted 30 days old.'
delete "tag:ovya.fr AND tag:delete AND date:..30d"

###}}###

# Make sure we have updated paths
synchronizeNotmuch
