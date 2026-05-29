*** Settings ***
Documentation    Keywords personalizadas para automação do LinkedIn
Library          SeleniumLibrary
Library          OperatingSystem
Resource         ../config/settings.robot

*** Keywords ***
Abrir LinkedIn no Chrome
    [Documentation]    Abre o LinkedIn no Google Chrome
    ...                Se o Chrome já estiver aberto, usa a mesma janela
    
    # Configuração do Chrome para reutilizar sessão
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --start-maximized
    
    # Abre o navegador
    Open Browser    ${LINKEDIN_URL}    ${BROWSER}    options=${chrome_options}
    Maximize Browser Window
    Set Selenium Speed    0.5 seconds
    Log    ✅ Chrome aberto com sucesso

Fazer Login no LinkedIn
    [Documentation]    Realiza o login no LinkedIn com as credenciais fornecidas
    [Arguments]    ${email}    ${password}
    
    # Aguarda a página carregar
    Wait Until Element Is Visible    css=.nav__button-secondary    timeout=${DEFAULT_TIMEOUT}
    
    # Verifica se já está logado
    ${is_logged}=    Run Keyword And Return Status
    ...    Page Should Contain Element    css=[data-test-id="feed-tab"]
    
    Run Keyword If    ${is_logged}    Log    ℹ️ Usuário já está logado
    ...    ELSE    Executar Login    ${email}    ${password}

Executar Login
    [Documentation]    Executa o processo de login
    [Arguments]    ${email}    ${password}
    
    # Vai para página de login
    Click Element    css=.nav__button-secondary
    Wait Until Location Contains    /login    timeout=${DEFAULT_TIMEOUT}
    
    # Preenche credenciais
    Wait Until Element Is Visible    id=username    timeout=${DEFAULT_TIMEOUT}
    Input Text    id=username    ${email}
    Input Password    id=password    ${password}
    
    # Clica no botão de login
    Click Button    css=button[type="submit"]
    
    # Aguarda o login completar
    Wait Until Location Contains    /feed    timeout=${LONG_TIMEOUT}
    Log    ✅ Login realizado com sucesso

Criar Nova Postagem
    [Documentation]    Cria uma nova postagem no LinkedIn
    [Arguments]    ${mensagem}
    
    # Aguarda o feed carregar
    Wait Until Element Is Visible    css=.share-box-feed-entry__trigger    timeout=${DEFAULT_TIMEOUT}
    
    # Clica no botão "Começar publicação"
    Click Element    css=.share-box-feed-entry__trigger
    
    # Aguarda o editor de postagem abrir
    Wait Until Element Is Visible    css=.ql-editor    timeout=${DEFAULT_TIMEOUT}
    Sleep    1s
    
    # Digita a mensagem
    Click Element    css=.ql-editor
    Input Text    css=.ql-editor    ${mensagem}
    Log    ✅ Mensagem digitada: ${mensagem}

Publicar Postagem
    [Documentation]    Clica no botão de publicar
    
    # Aguarda o botão estar habilitado
    Wait Until Element Is Enabled    css=button.share-actions__primary-action    timeout=${DEFAULT_TIMEOUT}
    
    # Clica em publicar
    Click Button    css=button.share-actions__primary-action
    
    # Aguarda confirmação
    Sleep    3s
    Log    ✅ Postagem publicada com sucesso!

Fechar Navegador de Forma Segura
    [Documentation]    Fecha o navegador e limpa recursos
    
    Sleep    2s
    Close Browser
    Log    ✅ Navegador fechado
