#!/bin/bash
[ -d "venv" ] && source venv/bin/activate
[ ! -f .env ] && echo "Arquivo .env nao encontrado. Execute: cp .env.example .env" && exit 1
export $(cat .env | grep -v '^#' | xargs)
robot tests/linkedin_post.robot
