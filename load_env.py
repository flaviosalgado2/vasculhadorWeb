"""
Script auxiliar para carregar variáveis de ambiente do arquivo .env
"""
import os
from pathlib import Path
from dotenv import load_dotenv

def carregar_credenciais():
    """Carrega as credenciais do arquivo .env"""
    
    # Encontra o arquivo .env
    env_path = Path('.') / '.env'
    
    if not env_path.exists():
        print("⚠️  Arquivo .env não encontrado!")
        print("   Copie o .env.example e configure suas credenciais:")
        print("   cp .env.example .env")
        return False
    
    # Carrega as variáveis
    load_dotenv(env_path)
    
    # Verifica se as credenciais foram configuradas
    email = os.getenv('LINKEDIN_EMAIL', '')
    password = os.getenv('LINKEDIN_PASSWORD', '')
    
    if not email or not password or 'exemplo.com' in email:
        print("⚠️  Configure suas credenciais no arquivo .env!")
        print(f"   Email atual: {email}")
        return False
    
    print(f"✅ Credenciais carregadas para: {email}")
    return True

if __name__ == '__main__':
    carregar_credenciais()
