"""
Biblioteca customizada que usa o Chrome DevTools Protocol (CDP) para injetar
scripts stealth *antes* que qualquer JavaScript da página seja executado.
Essa abordagem é compatível com Python 3.12+ (sem distutils) e é mais eficaz
que executar JavaScript depois do carregamento da página.
"""
import time
import random
import stat
import os
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager


# Script injetado via CDP em cada nova página, antes do JS da página.
_STEALTH_SCRIPT = """
Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]});
Object.defineProperty(navigator, 'languages', {get: () => ['pt-BR', 'pt', 'en-US', 'en']});
window.chrome = {
    app: {isInstalled: false},
    runtime: {connect: function() {}, sendMessage: function() {}, onMessage: {addListener: function() {}}},
};
const _origQuery = window.navigator.permissions.query;
window.navigator.permissions.__proto__.query = (params) =>
    params.name === 'notifications'
        ? Promise.resolve({state: Notification.permission})
        : _origQuery(params);
"""


class LinkedInBrowser:
    """Abre o Chrome com proteções anti-detecção via CDP."""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    @keyword("Abrir Chrome Anti-Detecção")
    def abrir_chrome_anti_deteccao(self, url="https://www.linkedin.com"):
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--disable-notifications")
        options.add_argument("--lang=pt-BR,pt")
        options.add_argument("--no-sandbox")
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        options.add_experimental_option("useAutomationExtension", False)

        driver_path = self._get_driver_path()
        service = Service(driver_path)
        driver = webdriver.Chrome(service=service, options=options)

        driver.execute_cdp_cmd(
            "Page.addScriptToEvaluateOnNewDocument",
            {"source": _STEALTH_SCRIPT}
        )

        driver.get(url)

        sl = BuiltIn().get_library_instance('SeleniumLibrary')
        sl._drivers.register(driver, alias=None)

        return driver

    @keyword("Preencher Campo Com Digitação Humana")
    def preencher_campo_com_digitacao_humana(self, locator, texto):
        """Preenche um campo via locator, tecla a tecla com delay aleatório."""
        sl = BuiltIn().get_library_instance('SeleniumLibrary')
        element = sl.find_element(locator)
        element.click()
        time.sleep(0.3)
        for char in texto:
            element.send_keys(char)
            time.sleep(random.uniform(0.05, 0.18))

    @keyword("Digitar No Editor Do Post")
    def digitar_no_editor_do_post(self, texto):
        """
        O modal já abre com o cursor piscando no editor.
        Apenas pega o elemento focado e digita — sem clicar em nada.
        """
        sl = BuiltIn().get_library_instance('SeleniumLibrary')
        driver = sl.driver

        # Aguarda o foco estabilizar após abertura do modal
        time.sleep(0.5)

        # Pega o elemento que está com foco (onde o cursor está piscando)
        active = driver.switch_to.active_element

        # Digita tecla a tecla no elemento ativo
        for char in texto:
            active.send_keys(char)
            time.sleep(random.uniform(0.05, 0.15))

    @keyword("Preencher Por Label")
    def preencher_por_label(self, label_text, texto):
        """
        Clica na <label> visível com o texto informado (ex: 'E-mail ou telefone',
        'Senha'). O browser foca o input associado via atributo 'for'. Depois
        digita no elemento ativo — exatamente como um usuário real faria.
        Resolve o problema do LinkedIn ter inputs duplicados no DOM onde o
        seletor CSS sempre pega o invisível (primeiro da lista).
        """
        sl = BuiltIn().get_library_instance('SeleniumLibrary')
        driver = sl.driver

        # Encontra a label visível com esse texto exato
        labels = driver.find_elements(By.XPATH, f"//label[normalize-space()='{label_text}']")
        label_clicada = None
        for label in labels:
            if label.is_displayed():
                label.click()
                label_clicada = label
                break

        if label_clicada is None:
            raise AssertionError(f"Label visível com texto '{label_text}' não encontrada na página")

        time.sleep(0.3)

        # O click na label focou o input associado — digita no elemento ativo
        active = driver.switch_to.active_element
        for char in texto:
            active.send_keys(char)
            time.sleep(random.uniform(0.05, 0.18))

    @keyword("Aguardar Com Variação Humana")
    def aguardar_com_variacao_humana(self, base_segundos=2.0, variacao=1.0):
        """Aguarda tempo aleatório para simular ritmo humano."""
        espera = float(base_segundos) + random.uniform(0, float(variacao))
        time.sleep(espera)

    def _get_driver_path(self):
        path = ChromeDriverManager().install()
        if "THIRD_PARTY_NOTICES" in os.path.basename(path) or not os.access(path, os.X_OK):
            directory = os.path.dirname(path)
            for f in os.listdir(directory):
                full = os.path.join(directory, f)
                if f == "chromedriver" and os.path.isfile(full):
                    path = full
                    break
        if os.path.exists(path):
            os.chmod(path, os.stat(path).st_mode | stat.S_IEXEC)
        return path
import time
import random
import stat
import os
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager


# Script injetado via CDP em cada nova página, antes do JS da página.
# Remove todas as marcas que o LinkedIn (e outros sistemas anti-bot) usam
# para fingerprint de automação Selenium.
_STEALTH_SCRIPT = """
// Remove a flag navigator.webdriver (principal sinal de automação)
Object.defineProperty(navigator, 'webdriver', {get: () => undefined});

// Simula plugins reais (browsers reais têm plugins; headless/selenium não)
Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]});

// Idiomas realistas
Object.defineProperty(navigator, 'languages', {
    get: () => ['pt-BR', 'pt', 'en-US', 'en']
});

// Simula o objeto window.chrome que browsers reais expõem
window.chrome = {
    app: {isInstalled: false},
    runtime: {
        connect: function() {},
        sendMessage: function() {},
        onMessage: {addListener: function() {}},
    },
};

// Corrige a detecção via Notification.permission
const _origQuery = window.navigator.permissions.query;
window.navigator.permissions.__proto__.query = (params) =>
    params.name === 'notifications'
        ? Promise.resolve({state: Notification.permission})
        : _origQuery(params);
"""


class LinkedInBrowser:
    """Abre o Chrome com proteções anti-detecção via CDP."""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    # ------------------------------------------------------------------ #
    # Browser                                                              #
    # ------------------------------------------------------------------ #

    @keyword("Abrir Chrome Anti-Detecção")
    def abrir_chrome_anti_deteccao(self, url="https://www.linkedin.com"):
        """
        Cria um WebDriver Chrome com:
        - excludeSwitches: ['enable-automation']  → remove o banner de automação
        - useAutomationExtension: False           → desativa extensão de automação
        - --disable-blink-features=AutomationControlled
        - CDP addScriptToEvaluateOnNewDocument    → injeta stealth JS antes de cada página

        Registra o driver na SeleniumLibrary para que todos os keywords nativos
        (Wait Until Element Is Visible, Click Element, etc.) continuem funcionando.
        """
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--disable-notifications")
        options.add_argument("--lang=pt-BR,pt")
        options.add_argument("--no-sandbox")
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        options.add_experimental_option("useAutomationExtension", False)

        driver_path = self._get_driver_path()
        service = Service(driver_path)
        driver = webdriver.Chrome(service=service, options=options)

        # Injeta stealth em TODAS as novas páginas (roda antes do JS da página)
        driver.execute_cdp_cmd(
            "Page.addScriptToEvaluateOnNewDocument",
            {"source": _STEALTH_SCRIPT}
        )

        driver.get(url)

        # Registra na SeleniumLibrary para que os keywords nativos funcionem
        sl = BuiltIn().get_library_instance('SeleniumLibrary')
        sl._drivers.register(driver, alias=None)

        return driver

    # ------------------------------------------------------------------ #
    # Helpers                                                              #
    # ------------------------------------------------------------------ #

    @keyword("Preencher Campo Com Digitação Humana")
    def preencher_campo_com_digitacao_humana(self, locator, texto):
        """
        Preenche um campo tecla a tecla com delay aleatório entre caracteres.
        Muito mais difícil de detectar do que injetar valores via JavaScript.
        """
        sl = BuiltIn().get_library_instance('SeleniumLibrary')
        element = sl.find_element(locator)
        element.click()
        time.sleep(0.3)
        for char in texto:
            element.send_keys(char)
            time.sleep(random.uniform(0.05, 0.18))

    @keyword("Aguardar Com Variação Humana")
    def aguardar_com_variacao_humana(self, base_segundos=2.0, variacao=1.0):
        """Aguarda um tempo aleatório para simular ritmo humano."""
        espera = float(base_segundos) + random.uniform(0, float(variacao))
        time.sleep(espera)

    # ------------------------------------------------------------------ #
    # Interno                                                              #
    # ------------------------------------------------------------------ #

    def _get_driver_path(self):
        """Obtém o chromedriver via webdriver-manager e garante permissão de execução."""
        path = ChromeDriverManager().install()

        # webdriver-manager às vezes retorna THIRD_PARTY_NOTICES.chromedriver
        # (que termina em "chromedriver" mas não é o binário executável).
        # Verifica pelo nome explícito e pela ausência de permissão de execução.
        if "THIRD_PARTY_NOTICES" in os.path.basename(path) or not os.access(path, os.X_OK):
            directory = os.path.dirname(path)
            for f in os.listdir(directory):
                full = os.path.join(directory, f)
                if f == "chromedriver" and os.path.isfile(full):
                    path = full
                    break

        if os.path.exists(path):
            os.chmod(path, os.stat(path).st_mode | stat.S_IEXEC)

        return path

