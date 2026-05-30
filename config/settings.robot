*** Settings ***
Documentation    Configurações gerais do projeto
Library          OperatingSystem

*** Variables ***
# URLs
${LINKEDIN_URL}         https://www.linkedin.com
${LINKEDIN_LOGIN_URL}   https://www.linkedin.com/login

# Timeouts
${DEFAULT_TIMEOUT}      15s
${LONG_TIMEOUT}         30s

# Navegador
${BROWSER}              Chrome
${HEADLESS}             False

*** Keywords ***
Carregar Credenciais
    [Documentation]    Carrega as credenciais do arquivo .env
    ${EMAIL}=    Get Environment Variable    LINKEDIN_EMAIL    default=
    ${PASSWORD}=    Get Environment Variable    LINKEDIN_PASSWORD    default=
    
    Run Keyword If    '${EMAIL}' == '' or '${PASSWORD}' == ''
    ...    Fail    ⚠️ Configure suas credenciais no arquivo .env
    
    Set Suite Variable    ${LINKEDIN_EMAIL}    ${EMAIL}
    Set Suite Variable    ${LINKEDIN_PASSWORD}    ${PASSWORD}
    
    RETURN    ${EMAIL}    ${PASSWORD}
