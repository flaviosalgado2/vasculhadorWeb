*** Settings ***
Documentation    Keywords personalizadas para automação do LinkedIn
Library          SeleniumLibrary
Library          OperatingSystem
Resource         ../config/settings.robot

*** Keywords ***
Abrir LinkedIn no Chrome
    [Documentation]    Abre o LinkedIn com proteções anti-detecção via CDP e interceptação de Shadow DOM

    # Abre uma aba em branco primeiro para poder injetar scripts CDP antes da navegação
    Open Browser    about:blank    Chrome
    
    # Obtém o driver subjacente para usar CDP
    ${driver}=    Evaluate
    ...    robot.libraries.BuiltIn.BuiltIn().get_library_instance('SeleniumLibrary').driver
    ...    modules=robot.libraries.BuiltIn
    
    # Injeta stealth script via CDP (antes de carregar qualquer página)
    ${stealth}=    Set Variable
    ...    Object.defineProperty(navigator, 'webdriver', {get: () => undefined}); Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]}); Object.defineProperty(navigator, 'languages', {get: () => ['pt-BR', 'pt', 'en-US', 'en']}); window.chrome = {app: {isInstalled: false}, runtime: {connect: function() {}, sendMessage: function() {}, onMessage: {addListener: function() {}}}}; const _origQuery = window.navigator.permissions.query; window.navigator.permissions.__proto__.query = (params) => params.name === 'notifications' ? Promise.resolve({state: Notification.permission}) : _origQuery(params);
    Evaluate    $driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {"source": $stealth})    modules=robot.libraries
    
    # Injeta interceptador de Shadow DOMs (também via CDP, para acessar closed shadows depois)
    ${shadow_intercept}=    Set Variable
    ...    window.__openShadowRoots = new Map(); const orig = Element.prototype.attachShadow; Element.prototype.attachShadow = function(init) { const shadow = orig.call(this, init); window.__openShadowRoots.set(this, shadow); return shadow; };
    Evaluate    $driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {"source": $shadow_intercept})    modules=robot.libraries
    
    # Agora navega para o LinkedIn
    Go To    ${LINKEDIN_URL}
    Set Selenium Implicit Wait    10s
    Log    ✅ Chrome aberto com sucesso (modo anti-detecção)

Fazer Login no LinkedIn
    [Documentation]    Realiza o login no LinkedIn com as credenciais fornecidas
    [Arguments]    ${email}    ${password}
    
    Go To    https://www.linkedin.com/login
    Aguardar Com Variação Humana    3    1
    Capture Page Screenshot    01_pagina_login.png
    
    # Verifica se já está logado (sessão ativa)
    ${is_logged}=    Run Keyword And Return Status
    ...    Location Should Contain    /feed
    
    Run Keyword If    ${is_logged}    Log    ℹ️ Usuário já está logado
    ...    ELSE    Executar Login    ${email}    ${password}

Executar Login
    [Documentation]    Preenche os campos de login e submete o formulário
    [Arguments]    ${email}    ${password}
    
    Wait Until Element Is Visible    xpath=(//input[@type='email'])[last()]    timeout=${LONG_TIMEOUT}
    Capture Page Screenshot    02_antes_preencher.png
    
    # Preenche e-mail com digitação humana
    Preencher Campo Com Digitação Humana    xpath=(//input[@type='email'])[last()]    ${email}
    Aguardar Com Variação Humana    0.5    0.5
    
    # Preenche senha com digitação humana
    Preencher Campo Com Digitação Humana    xpath=(//input[@type='password'])[last()]    ${password}
    Aguardar Com Variação Humana    1    0.5
    
    Capture Page Screenshot    03_antes_submit.png
    
    # Submete o form pressionando Enter no campo de senha
    Press Keys    xpath=(//input[@type='password'])[last()]    RETURN
    
    # Aguarda o redirecionamento para o feed
    ${login_ok}=    Run Keyword And Return Status
    ...    Wait Until Location Contains    /feed    timeout=${LONG_TIMEOUT}
    
    Run Keyword If    not ${login_ok}
    ...    Verificar Erro De Login
    
    Aguardar Com Variação Humana    2    1
    Capture Page Screenshot    04_apos_login.png
    Log    ✅ Login realizado com sucesso

Verificar Erro De Login
    [Documentation]    Verifica se apareceu erro de login ou desafio de segurança
    
    Capture Page Screenshot    04_erro_login.png
    ${has_error}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//*[contains(@class, 'alert') or contains(@role, 'alert')]
    Run Keyword If    ${has_error}
    ...    Fail    ⚠️ Erro no login detectado. Verifique credenciais ou se há um CAPTCHA/desafio de segurança.
    ...    ELSE
    ...    Fail    ⚠️ Login não redirecionou para o feed. Verifique se há um CAPTCHA ou verificação de segurança.

Preencher Campo Com Digitação Humana
    [Documentation]    Preenche um campo tecla a tecla com delay aleatório
    [Arguments]    ${locator}    ${texto}
    
    Click Element    ${locator}
    Sleep    0.3s
    ${chars}=    Evaluate    list($texto)
    FOR    ${char}    IN    @{chars}
        Press Keys    ${locator}    ${char}
        ${delay}=    Evaluate    random.uniform(0.05, 0.18)    modules=random
        Sleep    ${delay}
    END

Aguardar Com Variação Humana
    [Documentation]    Aguarda um tempo aleatório para simular ritmo humano
    [Arguments]    ${base_segundos}=2.0    ${variacao}=1.0
    ${espera}=    Evaluate    float($base_segundos) + random.uniform(0, float($variacao))    modules=random
    Sleep    ${espera}

Criar Nova Postagem
    [Documentation]    Cria uma nova postagem no LinkedIn
    [Arguments]    ${mensagem}
    
    Aguardar Com Variação Humana    2    1
    Capture Page Screenshot    05_feed_carregado.png
    
    # Clica no campo "Começar publicação"
    Wait Until Element Is Visible    xpath=//*[normalize-space()='Começar publicação']    timeout=${LONG_TIMEOUT}
    Click Element    xpath=//*[normalize-space()='Começar publicação']
    
    # Aguarda o modal abrir
    Aguardar Com Variação Humana    2    0.5
    Capture Page Screenshot    06_editor_aberto.png
    
    # Digita a mensagem no editor (dentro de Shadow DOM)
    Digitar No Editor Do Post    ${mensagem}
    Aguardar Com Variação Humana    1    0.5
    Capture Page Screenshot    07_mensagem_digitada.png
    Log    ✅ Mensagem digitada: ${mensagem}

Digitar No Editor Do Post
    [Documentation]    Encontra o editor de postagem (dentro de Shadow DOM) e digita a mensagem
    [Arguments]    ${texto}
    
    Sleep    3s
    
    # Encontra o editor via JavaScript percorrendo shadow DOMs interceptados
    ${editor}=    Execute JavaScript
    ...    var roots = window.__openShadowRoots || new Map();
    ...    function searchAllShadows(selector, root) {
    ...        root = root || document;
    ...        var found = Array.from(root.querySelectorAll(selector));
    ...        if (found.length) return found;
    ...        var hosts = root.querySelectorAll('*');
    ...        for (var i = 0; i < hosts.length; i++) {
    ...            var el = hosts[i];
    ...            var sr = roots.get(el) || el.shadowRoot;
    ...            if (sr) {
    ...                var result = searchAllShadows(selector, sr);
    ...                if (result && result.length) return result;
    ...            }
    ...        }
    ...        return [];
    ...    }
    ...    var candidates = searchAllShadows('div.ql-editor[contenteditable="true"]');
    ...    if (!candidates.length) candidates = searchAllShadows('[contenteditable="true"]');
    ...    for (var j = 0; j < candidates.length; j++) {
    ...        var rect = candidates[j].getBoundingClientRect();
    ...        if (rect.height > 50 && rect.width > 100) return candidates[j];
    ...    }
    ...    return candidates[0] || null;
    
    Run Keyword If    $editor is None
    ...    Fail    Não foi possível localizar o editor de postagem do LinkedIn.
    
    # Clica no editor para focar
    Execute JavaScript    arguments[0].focus(); arguments[0].click();    ARGUMENTS    ${editor}
    Sleep    0.5s
    
    # Digita tecla a tecla via JavaScript (simula eventos reais de teclado)
    ${js}=    Catenate
    ...    var el = arguments[0];
    ...    var text = arguments[1];
    ...    for (var i = 0; i < text.length; i++) {
    ...        var char = text[i];
    ...        var code = char.charCodeAt(0);
    ...        el.dispatchEvent(new KeyboardEvent('keydown', {bubbles: true, cancelable: true, key: char, code: 'Key' + char.toUpperCase(), charCode: code, keyCode: code, which: code}));
    ...        el.dispatchEvent(new KeyboardEvent('keypress', {bubbles: true, cancelable: true, key: char, code: 'Key' + char.toUpperCase(), charCode: code, keyCode: code, which: code}));
    ...        el.textContent += char;
    ...        el.dispatchEvent(new Event('input', {bubbles: true}));
    ...        el.dispatchEvent(new KeyboardEvent('keyup', {bubbles: true, cancelable: true, key: char, code: 'Key' + char.toUpperCase(), charCode: code, keyCode: code, which: code}));
    ...    }
    Execute JavaScript    ${js}    ARGUMENTS    ${editor}    ${texto}
    
    # Aguarda o LinkedIn reagir e habilitar o botão Publicar
    Sleep    2s

Publicar Postagem
    [Documentation]    Clica no botão "Publicar" no modal (encontra via TreeWalker de nós de texto)
    
    Aguardar Com Variação Humana    2    0.5
    
    # Encontra o botão "Publicar" via TreeWalker percorrendo text nodes e shadow DOMs
    ${botao}=    Execute JavaScript
    ...    var roots = window.__openShadowRoots || new Map();
    ...    var foundBtn = null;
    ...    function walk(root) {
    ...        var treeWalker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
    ...        var node;
    ...        while ((node = treeWalker.nextNode()) !== null) {
    ...            if (node.nodeValue.trim() === 'Publicar') {
    ...                var parent = node.parentElement;
    ...                while (parent) {
    ...                    if (parent.tagName === 'BUTTON' || parent.tagName === 'A' || parent.getAttribute('role') === 'button') {
    ...                        foundBtn = parent;
    ...                        return;
    ...                    }
    ...                    parent = parent.parentElement;
    ...                }
    ...            }
    ...        }
    ...        var hosts = root.querySelectorAll('*');
    ...        for (var i = 0; i < hosts.length; i++) {
    ...            var el = hosts[i];
    ...            var sr = roots.get(el) || el.shadowRoot;
    ...            if (sr) {
    ...                walk(sr);
    ...                if (foundBtn) return;
    ...            }
    ...        }
    ...    }
    ...    walk(document);
    ...    return foundBtn;
    
    Run Keyword If    $botao is None
    ...    Fail    Não foi possível localizar o botão 'Publicar' no modal do LinkedIn.
    
    Execute JavaScript    arguments[0].click();    ARGUMENTS    ${botao}
    
    Aguardar Com Variação Humana    3    1
    Capture Page Screenshot    08_apos_publicar.png
    Log    ✅ Postagem publicada com sucesso!

Fechar Navegador de Forma Segura
    [Documentation]    Fecha todas as instâncias do navegador
    Close All Browsers
