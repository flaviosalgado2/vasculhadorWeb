*** Settings ***
Library     SeleniumLibrary
Library     OperatingSystem
Resource    ../config/settings.robot

*** Keywords ***
Abrir LinkedIn no Chrome
    Open Browser    about:blank    Chrome
    ${driver}=    Evaluate
    ...    robot.libraries.BuiltIn.BuiltIn().get_library_instance('SeleniumLibrary').driver
    ...    modules=robot.libraries.BuiltIn
    ${stealth}=    Set Variable
    ...    Object.defineProperty(navigator, 'webdriver', {get: () => undefined}); Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]}); Object.defineProperty(navigator, 'languages', {get: () => ['pt-BR', 'pt', 'en-US', 'en']}); window.chrome = {app: {isInstalled: false}, runtime: {connect: function() {}, sendMessage: function() {}, onMessage: {addListener: function() {}}}}; const _origQuery = window.navigator.permissions.query; window.navigator.permissions.__proto__.query = (params) => params.name === 'notifications' ? Promise.resolve({state: Notification.permission}) : _origQuery(params);
    Evaluate    $driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {"source": $stealth})    modules=robot.libraries
    ${shadow_intercept}=    Set Variable
    ...    window.__openShadowRoots = new Map(); const orig = Element.prototype.attachShadow; Element.prototype.attachShadow = function(init) { const shadow = orig.call(this, init); window.__openShadowRoots.set(this, shadow); return shadow; };
    Evaluate    $driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {"source": $shadow_intercept})    modules=robot.libraries
    Go To    ${LINKEDIN_URL}
    Set Selenium Implicit Wait    10s

Fazer Login no LinkedIn
    [Arguments]    ${email}    ${password}
    Go To    https://www.linkedin.com/login
    Aguardar Com Variação Humana    3    1
    ${logado}=    Run Keyword And Return Status    Location Should Contain    /feed
    Return From Keyword If    ${logado}
    Wait Until Element Is Visible    xpath=(//input[@type='email'])[last()]    timeout=${LONG_TIMEOUT}
    Preencher Campo Com Digitação Humana    xpath=(//input[@type='email'])[last()]    ${email}
    Aguardar Com Variação Humana    0.5    0.5
    Preencher Campo Com Digitação Humana    xpath=(//input[@type='password'])[last()]    ${password}
    Aguardar Com Variação Humana    1    0.5
    Press Keys    xpath=(//input[@type='password'])[last()]    RETURN
    ${ok}=    Run Keyword And Return Status    Wait Until Location Contains    /feed    timeout=${LONG_TIMEOUT}
    Run Keyword If    not ${ok}    Fail    Login falhou. Verifique credenciais ou CAPTCHA.
    Aguardar Com Variação Humana    2    1

Preencher Campo Com Digitação Humana
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
    [Arguments]    ${base_segundos}=2.0    ${variacao}=1.0
    ${espera}=    Evaluate    float($base_segundos) + random.uniform(0, float($variacao))    modules=random
    Sleep    ${espera}

Criar Nova Postagem
    [Arguments]    ${mensagem}
    Aguardar Com Variação Humana    2    1
    Wait Until Element Is Visible    xpath=//*[normalize-space()='Começar publicação']    timeout=${LONG_TIMEOUT}
    Click Element    xpath=//*[normalize-space()='Começar publicação']
    Aguardar Com Variação Humana    2    0.5
    Digitar No Editor Do Post    ${mensagem}
    Aguardar Com Variação Humana    1    0.5

Digitar No Editor Do Post
    [Arguments]    ${texto}
    Sleep    3s
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
    Run Keyword If    $editor is None    Fail    Editor de postagem não encontrado.
    Execute JavaScript    arguments[0].focus(); arguments[0].click();    ARGUMENTS    ${editor}
    Sleep    0.5s
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
    Sleep    2s

Publicar Postagem
    Aguardar Com Variação Humana    2    0.5
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
    Run Keyword If    $botao is None    Fail    Botão 'Publicar' não encontrado.
    Execute JavaScript    arguments[0].click();    ARGUMENTS    ${botao}
    Aguardar Com Variação Humana    3    1

Fechar Navegador de Forma Segura
    Close All Browsers
