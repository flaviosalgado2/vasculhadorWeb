*** Settings ***
Library          SeleniumLibrary
Library          OperatingSystem
Resource         ../resources/linkedin_keywords.robot
Resource         ../config/settings.robot

Suite Setup      Carregar Credenciais
Suite Teardown   Fechar Navegador de Forma Segura

*** Variables ***
${MENSAGEM}    oi

*** Test Cases ***
Postar Mensagem no LinkedIn
    [Tags]    linkedin    postagem
    Abrir LinkedIn no Chrome
    Fazer Login no LinkedIn    ${LINKEDIN_EMAIL}    ${LINKEDIN_PASSWORD}
    Criar Nova Postagem    ${MENSAGEM}
    Publicar Postagem
