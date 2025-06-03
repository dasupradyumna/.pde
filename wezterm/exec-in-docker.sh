#!/bin/bash

if [ "$(docker inspect "$1" --format '{{.State.Running}}')" == false ]; then
    xhost +local:root 1>/dev/null
    docker start "$1" 1>/dev/null || { echo -e "\n\e[31mFailed to start $1\e[m"; exit 1; }
fi

docker exec -it "$1" bash
