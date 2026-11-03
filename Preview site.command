#!/bin/bash
cd "$(dirname "$0")"
echo "Starting the ADAPT site preview. Leave this window open while you look at the site."
echo "Close this window to stop the preview."
( sleep 2; open "http://127.0.0.1:1111" ) &
./zola serve
