#!/bin/bash
echo "Updating containers..."
docker-compose pull
docker-compose up -d