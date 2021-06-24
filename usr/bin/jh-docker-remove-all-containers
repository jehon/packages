#!/usr/bin/env bash

listing() {
    echo "## Images"
    docker image ls -a
    echo ""

    echo "## Containers"
    docker container ls -a
    echo ""

    echo "## Volumes"
    docker volume ls
    echo ""
}

echo "###########################"
echo "## Before checks"
echo "###########################"
listing

echo "###########################"
echo "## Clean up"
echo "###########################"
docker system prune -a
docker volume prune
echo ""

echo "###########################"
echo "## After checks"
echo "###########################"
listing
