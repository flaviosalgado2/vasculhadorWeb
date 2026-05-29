#!/bin/bash

# Script de instalação rápida para macOS/Linux

echo "🤖 Configurando projeto Robot Framework - LinkedIn Bot"
echo ""

# Verifica se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado. Por favor, instale Python 3.8 ou superior."
    exit 1
fi

echo "✅ Python encontrado: $(python3 --version)"
echo ""

# Cria ambiente virtual
echo "📦 Criando ambiente virtual..."
python3 -m venv venv

# Ativa ambiente virtual
echo "🔄 Ativando ambiente virtual..."
source venv/bin/activate

# Instala dependências
echo "📥 Instalando dependências..."
pip install --upgrade pip
pip install -r requirements.txt

# Cria arquivo .env se não existir
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
    echo ""
    echo "⚠️  IMPORTANTE: Edite o arquivo .env com suas credenciais do LinkedIn!"
    echo "   Use: nano .env  ou  open .env"
fi

echo ""
echo "✨ Instalação concluída!"
echo ""
echo "📚 Próximos passos:"
echo "   1. Edite o arquivo .env com suas credenciais"
echo "   2. Execute: source venv/bin/activate"
echo "   3. Execute: robot tests/linkedin_post.robot"
echo ""
