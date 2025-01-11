#!/bin/bash

# # Come from https://sqrtminusone.xyz/posts/2021-02-27-gmail/
# # A file with last time of sync
# CHECK_FILE="/home/pavel/Mail/.last_check"
# QUERY="tag:unread"
# ALL_QUERY="tag:unread"
# # If the file exists, check also the new messages from the last sync
# if [ -f "$CHECK_FILE" ]; then
#     DATE=$(cat "$CHECK_FILE")
#     QUERY="$QUERY and date:@$DATE.."
# fi

# notmuch new
# NEW_UNREAD=$(notmuch count "$QUERY")
# ALL_UNREAD=$(notmuch count "$ALL_QUERY")

# # I don't really care if there are unread messages for which I've already seen a notification
# if [ $NEW_UNREAD -gt 0 ]; then
#     MAIN_UNREAD=$(notmuch count "tag:unread AND tag:main")
#     PROGIN_UNREAD=$(notmuch count "tag:unread AND tag:progin")
#     read -r -d '' NOTIFICATION <<EOM
# $NEW_UNREAD new messages
# $MAIN_UNREAD thexcloud@gmail.com
# $PROGIN_UNREAD progin6304@gmail.com
# $ALL_UNREAD total
# EOM
#     notify-send "New Mail" "$NOTIFICATION"
# fi

# # Save sync timestamp
# echo "$(date +%s)" > $CHECK_FILE
