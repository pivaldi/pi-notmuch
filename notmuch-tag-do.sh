#!/bin/bash

# Tags config for my mailbox
notmuch tag --input="${MAILDIR}/.notmuch/.notmuch-tagging"

# Tags config for the EN mailbox ac-montpellier.fr
notmuch tag --input="${MAILDIR}/.notmuch/.notmuch-tagging-acmontpellier"

# Tags config for the company mailbox ovya.fr
notmuch tag --input="${MAILDIR}/.notmuch/.notmuch-tagging-ovya"

notmuch tag -new -- tag:new
