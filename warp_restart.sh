#!/bin/bash

function restart_warp() {
    warp-cli disconnect
    warp-cli delete
    warp-cli register
    warp-cli connect

    result=$(curl -s -x socks5://127.0.0.1:40000 chat.openai.com/cdn-cgi/trace)
    echo "$result" | grep -E 'warp=on|warp=plus' > /dev/null

    if [ $? -eq 0 ]; then
        echo "Warp-cli restarted successfully!"
    else
        echo "Warp-cli restart failed."
    fi
}

while true; do
    restart_warp
    sleep 86400 # Sleep for 24 hours
done
