#!/bin/bash
command -v python3 &> /dev/null || { echo "Python 3 nao encontrado."; exit 1; }
python3 -m venv venv
source venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements.txt
[ ! -f .env ] && cp .env.example .env && echo "Edite o .env com suas credenciais do LinkedIn."
echo "Pronto. Execute: source venv/bin/activate && robot tests/linkedin_post.robot"
