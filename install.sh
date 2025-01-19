#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

[ -z "$MAILDIR" ] && {
    echo 'MAILDIR env var is not set'
    echo 'Process aborted'
    exit 1
}

DEPORTED_MAIL_DIR="${HOME}/Documents/mail"
NOTMUCH_DIR="${DEPORTED_MAIL_DIR}/.notmuch"
HOOKS_DIR="$NOTMUCH_DIR/hooks"

echo 'Creating hooks directory'
[ -e "$HOOKS_DIR" ] || mkdir -p "$HOOKS_DIR"

[ -e "$MAILDIR" ] && [ ! -L "$MAILDIR" ] && {
    echo "MAILDIR=$MAILDIR exists and is not a symlink"
    echo 'Process aborted'
    exit 1
}

echo 'Linking MAILDIR to deported MAILDIR'
[ -e "$MAILDIR" ] || {
    ln -s "$DEPORTED_MAIL_DIR" "$MAILDIR" || exit 1
}

MAILDIR_DEST=$(readlink "$MAILDIR")

[ "$MAILDIR_DEST" == "$DEPORTED_MAIL_DIR/" ] || {
    echo "$MAILDIR is a symlink to $MAILDIR_DEST, not to $DEPORTED_MAIL_DIR"
    echo 'Process aborted'
    exit 1
}

echo "Creating accounts' mail directories"
ACCOUNTS='ivaldi.me ovya.fr acmontpellier'
for ACCOUNT in $ACCOUNTS; do
    DIR="${MAILDIR}/$ACCOUNT"
    [ -e "$DIR" ] || mkdir -p "$DIR" || exit 1
done

echo 'Symlinking Notmiuch hook'
HOOK_FILES='post-new pre-new'
for HOOK_FILE in $HOOK_FILES; do
    DEST_HOOK_SCRIPT="$HOOKS_DIR/$HOOK_FILE"
    [ -e "$DEST_HOOK_SCRIPT" ] || ln -s "$SCRIPT_DIR/$HOOK_FILE" "$DEST_HOOK_SCRIPT" || exit 1
done

echo 'Linking shell scripts to ~/bin/'
FILES='notmuch-notify.sh notmuch-tag-do.sh notmuch-tag-move.sh'
for FILE in $FILES; do
    DEST_FILE="${HOME}/bin/$FILE"
    [ -e "$DEST_FILE" ] || ln -s "$SCRIPT_DIR/$FILE" "$DEST_FILE" || exit 1
done

echo 'Linking tags configs'
FILES='.notmuch-tagging .notmuch-tagging-ovya .notmuch-tagging-acmontpellier'
for FILE in $FILES; do
    DEST_FILE="${NOTMUCH_DIR}/$FILE"
    [ -e "$DEST_FILE" ] || ln -s "$SCRIPT_DIR/$FILE" "$DEST_FILE" || exit 1
done

echo 'Linking notmuch config file'
FILE='.notmuch-config'
DEST_FILE="${HOME}/$FILE"
[ -e "$DEST_FILE" ] || ln -s "$SCRIPT_DIR/$FILE" "$DEST_FILE" || exit 1

echo 'Linking mbsync/isync config file'
FILE='.isyncrc'
DEST_FILE="${HOME}/$FILE"
[ -e "$DEST_FILE" ] || ln -s "$SCRIPT_DIR/$FILE" "$DEST_FILE" || exit 1
