*** Settings ***
Library    OperatingSystem

*** Variables ***
${LINKEDIN_URL}       https://www.linkedin.com
${DEFAULT_TIMEOUT}    15s
${LONG_TIMEOUT}       30s

*** Keywords ***
Carregar Credenciais
    ${EMAIL}=       Get Environment Variable    LINKEDIN_EMAIL    default=
    ${PASSWORD}=    Get Environment Variable    LINKEDIN_PASSWORD    default=
    Should Not Be Empty    ${EMAIL}      Configure LINKEDIN_EMAIL no arquivo .env
    Should Not Be Empty    ${PASSWORD}    Configure LINKEDIN_PASSWORD no arquivo .env
    Set Suite Variable    ${LINKEDIN_EMAIL}    ${EMAIL}
    Set Suite Variable    ${LINKEDIN_PASSWORD}    ${PASSWORD}
