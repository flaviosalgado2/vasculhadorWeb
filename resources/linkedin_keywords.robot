*** Settings ***
Documentation    Keywords personalizadas para automação do LinkedIn
Library          SeleniumLibrary
Library          OperatingSystem
Library          ./LinkedInBrowser.py
Resource         ../config/settings.robot

*** Keywords ***
Abrir LinkedIn no Chrome
    [Documentation]    Abre o LinkedIn usando undetected-chromedriver (bypass de detecção de bots)
    
    Abrir Chrome Anti-Detecção    ${LINKEDIN_URL}
    Set Selenium Implicit Wait    10s
    Log    ✅ Chrome aberto com sucesso (modo anti-detecção)

Fazer Login no LinkedIn
    [Documentation]    Realiza o login no LinkedIn com as credenciais fornecidas
    [Arguments]    ${email}    ${password}
    
    # Vai direto para a página de login
    Go To    https://www.linkedin.com/login
    
    # Aguarda a página carregar completamente
    Aguardar Com Variação Humana    3    1
    Capture Page Screenshot    01_pagina_login.png
    
    # Verifica se já está logado (sessão ativa)
    ${is_logged}=    Run Keyword And Return Status
    ...    Location Should Contain    /feed
    
    Run Keyword If    ${is_logged}    Log    ℹ️ Usuário já está logado
    ...    ELSE    Executar Login    ${email}    ${password}

Executar Login
    [Documentation]    Preenche os campos de login clicando diretamente nos inputs visíveis
    [Arguments]    ${email}    ${password}
    
    # Aguarda o campo de e-mail visível (o LinkedIn tem 2 pares de inputs no DOM;
    # [last()] garante que pegamos o segundo par, que é o visível na tela)
    Wait Until Element Is Visible    xpath=(//input[@type='email'])[last()]    timeout=${LONG_TIMEOUT}
    Capture Page Screenshot    02_antes_preencher.png
    
    # Clica e digita no campo "E-mail ou telefone" (input visível)
    Preencher Campo Com Digitação Humana    xpath=(//input[@type='email'])[last()]    ${email}
    Aguardar Com Variação Humana    0.5    0.5
    
    # Clica e digita no campo "Senha" (input visível)
    Preencher Campo Com Digitação Humana    xpath=(//input[@type='password'])[last()]    ${password}
    Aguardar Com Variação Humana    1    0.5
    
    Capture Page Screenshot    03_antes_submit.png
    
    # Clica no botão "Entrar" visível ([last()] ignora o botão oculto do form duplicado)
    Click Element    xpath=(//button[normalize-space()='Entrar'])[last()]
    
    # Aguarda o redirecionamento para o feed
    Wait Until Location Contains    /feed    timeout=${LONG_TIMEOUT}
    Aguardar Com Variação Humana    2    1
    Capture Page Screenshot    04_apos_login.png
    Log    ✅ Login realizado com sucesso

Ir Para Pagina de Login
    [Documentation]    Navega para a página de login do LinkedIn
    
    Go To    https://www.linkedin.com/login
    Aguardar Com Variação Humana    2    1

Criar Nova Postagem
    [Documentation]    Cria uma nova postagem no LinkedIn
    [Arguments]    ${mensagem}
    
    Aguardar Com Variação Humana    2    1
    Capture Page Screenshot    05_feed_carregado.png
    
    # Clica no campo "Começar publicação" pelo texto exato visível na tela
    Wait Until Element Is Visible    xpath=//*[normalize-space()='Começar publicação']    timeout=${LONG_TIMEOUT}
    Click Element    xpath=//*[normalize-space()='Começar publicação']
    
    # Aguarda o modal abrir e o cursor aparecer no editor
    Aguardar Com Variação Humana    2    0.5
    Capture Page Screenshot    06_editor_aberto.png
    
    # Modal aberto e cursor já piscando — digita direto
    Digitar No Editor Do Post    ${mensagem}
    Aguardar Com Variação Humana    1    0.5
    Capture Page Screenshot    07_mensagem_digitada.png
    Log    ✅ Mensagem digitada: ${mensagem}

Publicar Postagem
    [Documentation]    Clica no botão "Publicar" visível no modal
    
    # Aguarda o botão "Publicar" ficar visível (aparece no canto inferior direito do modal)
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Publicar']    timeout=${LONG_TIMEOUT}
    Aguardar Com Variação Humana    1    0.5
    Click Element    xpath=//button[normalize-space()='Publicar']
    
    Aguardar Com Variação Humana    3    1
    Capture Page Screenshot    08_apos_publicar.png
    Log    ✅ Postagem publicada com sucesso!
