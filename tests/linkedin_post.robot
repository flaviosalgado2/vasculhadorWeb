*** Settings ***
Documentation    Automação para criar postagem no LinkedIn
...              Este teste abre o Chrome, faz login no LinkedIn e cria uma postagem

Library          SeleniumLibrary
Library          OperatingSystem
Resource         ../resources/linkedin_keywords.robot
Resource         ../config/settings.robot

Suite Setup      Preparar Ambiente de Teste
Suite Teardown   Fechar Navegador de Forma Segura

*** Variables ***
${MENSAGEM}    Boa Noite

*** Test Cases ***
Postar Mensagem no LinkedIn
    [Documentation]    Cria uma postagem simples no LinkedIn
    [Tags]    linkedin    postagem    social-media
    
    Log    🚀 Iniciando automação do LinkedIn
    
    # Passo 1: Abrir LinkedIn
    Abrir LinkedIn no Chrome
    
    # Passo 2: Fazer login
    Fazer Login no LinkedIn    ${LINKEDIN_EMAIL}    ${LINKEDIN_PASSWORD}
    
    # Passo 3: Criar postagem
    Criar Nova Postagem    ${MENSAGEM}
    
    # Passo 4: Publicar
    Publicar Postagem
    
    Log    ✨ Automação concluída com sucesso!

*** Keywords ***
Preparar Ambiente de Teste
    [Documentation]    Configura o ambiente antes de executar os testes
    
    Log    📋 Preparando ambiente de teste
    
    # Carrega as credenciais
    Carregar Credenciais
    
    Log    ✅ Ambiente preparado
