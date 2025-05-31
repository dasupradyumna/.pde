#!/bin/bash

if [ "$(docker inspect "$1" --format '{{.State.Running}}')" == false ]; then
    docker start "$1"
fi

docker exec -it "$1" bash
