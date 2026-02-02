#!/bin/bash
docker compose up -d --build
echo ""
echo "========================================"
echo "Desktop started!"
echo "========================================"
echo "Web:     http://localhost:13000"
echo "User:    abc (default)"
echo "Password: ubuntu"
echo "========================================"
