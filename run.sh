#!/bin/bash

echo "Starting Notes App..."

# Check if using SQLite or MySQL
if [ -f ".env.sqlite" ]; then
    echo "Using SQLite version"
    cp .env.sqlite .env
    node app-sqlite.js
else
    echo "Using MySQL version"
    docker-compose up --build
fi