#!/bin/bash
docker-compose up -d --build
echo ""
echo "========================================"
echo "Desktop started!"
echo "========================================"
echo "SSH:     ssh ubuntu@localhost -p 10022"
echo "Web:     https://localhost:16901"
echo "User:    ubuntu"
echo "Password: ubuntu"
echo "========================================"
