# Setup

    cd php
    ./gen-proto.sh

## Run locally

    php -c . leak-simple.php

## Run with docker

    docker build -t proto-php .
    docker run --rm -v "$(pwd):/app" -w /app proto-php php -c . leak-simple.php
