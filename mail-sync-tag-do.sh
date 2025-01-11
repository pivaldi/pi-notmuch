#!/bin/bash

# Personal tags system of my mailbox.
notmuch tag --input="${HOME}/.notmuch-tagging"

# Personal tags system for the company mailbox.
OVYA_TAGGING_FILE="${HOME}/.notmuch-tagging-ovya"
[ -e  "$OVYA_TAGGING_FILE" ] && notmuch tag --input="$OVYA_TAGGING_FILE"

notmuch tag -new -- tag:new
