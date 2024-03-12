#!/bin/bash

# Directory check
[[ -d kzlog ]] || mkdir kzlog

# Load Discord webhook URL from .env file
if [[ -f .env ]]; then
    export $(cat .env | xargs)
fi

send_discord_notification() {
    if [[ -z "$DISCORD_WEBHOOK_URL" ]]; then
        echo "Discord webhook URL not set. Skipping notification."
        return 0
    fi
    message="$1"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$message\"}" "$DISCORD_WEBHOOK_URL"
}

while true; do
    pidlist=$(ps -ef | grep kuzco | grep -v grep | awk '{print $2}')
    if [[ -n "$pidlist" ]]; then
        echo "$(date "+%Y-%m-%d %H:%M:%S") Kuzco task pids: $(echo ${pidlist[@]} | tr '\n' ' ')"
        for pid in $pidlist; do
            sudo kill -9 $pid
            echo "$(date "+%Y-%m-%d %H:%M:%S") Killing process with PID: $pid"
        done
    fi

    echo "$(date "+%Y-%m-%d %H:%M:%S") Starting..."
    sudo kuzco worker start >> kz-worker.log 2>&1 &
    send_discord_notification "$(date "+%Y-%m-%d %H:%M:%S") Starting..."

    runtime=0
    while true; do
        if [[ `grep -c "TimeoutError: The operation timed out" kz-worker.log` -ne '0' ]]; then
            cp kz-worker.log kzlog/kz-worker-$(date +%Y%m%d%H%M%S).log
            cat /dev/null > kz-worker.log
            error_message="$(date "+%Y-%m-%d %H:%M:%S") TimeoutError, preparing to restart..."
            send_discord_notification "$error_message"
            echo "$error_message"
            break
        elif [[ `grep -c "CUDA error: " kz-worker.log` -ne '0' ]]; then
            sleep 10
            cp kz-worker.log kzlog/kz-worker-$(date +%Y%m%d%H%M%S).log
            cat /dev/null > kz-worker.log
            error_message="$(date "+%Y-%m-%d %H:%M:%S") CUDA error, preparing to restart..."
            send_discord_notification "$error_message"
            echo "$error_message"
            break
        else
            sleep 1
            runtime=$(($runtime+1))
            echo "$(date "+%Y-%m-%d %H:%M:%S") Running for ${runtime}s"
            if [[ "$runtime" -ge '1800' ]]; then
                error_message="$(date "+%Y-%m-%d %H:%M:%S") Restarting scheduledly..."
                send_discord_notification "$error_message"
                echo "$error_message"
                break
            fi
        fi
    done
done
