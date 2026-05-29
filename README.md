# 🤖 LinkedIn Bot - Robot Framework

Automação para criar postagens no LinkedIn usando Robot Framework e Selenium.

## 📋 Pré-requisitos

- Python 3.8 ou superior
- Google Chrome instalado
- Conta no LinkedIn

## 🚀 Instalação

### 1. Clone ou baixe o projeto

```bash
cd vasculhadorWeb
```

### 2. Crie um ambiente virtual (recomendado)

```bash
# No macOS/Linux
python3 -m venv venv
source venv/bin/activate

# No Windows
python -m venv venv
venv\Scripts\activate
```

### 3. Instale as dependências

```bash
pip install -r requirements.txt
```

### 4. Configure suas credenciais

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite o arquivo .env e adicione suas credenciais
# LINKEDIN_EMAIL=seu_email@exemplo.com
# LINKEDIN_PASSWORD=sua_senha
```

## ▶️ Como Usar

### Executar o teste

```bash
# Modo normal (com interface gráfica)
robot tests/linkedin_post.robot

# Modo silencioso (menos logs)
robot --loglevel INFO tests/linkedin_post.robot

# Modo headless (sem abrir navegador)
robot --variable HEADLESS:True tests/linkedin_post.robot
```

### Personalizar a mensagem

Edite o arquivo `tests/linkedin_post.robot` e altere a variável:

```robot
*** Variables ***
${MENSAGEM}    Sua mensagem aqui
```

Ou passe como argumento na linha de comando:

```bash
robot --variable MENSAGEM:"Olá LinkedIn!" tests/linkedin_post.robot
```

## 📁 Estrutura do Projeto

```
vasculhadorWeb/
├── config/
│   └── settings.robot          # Configurações gerais
├── resources/
│   └── linkedin_keywords.robot # Keywords personalizadas
├── tests/
│   └── linkedin_post.robot     # Teste principal
├── .env                        # Credenciais (não commitar!)
├── .env.example               # Exemplo de credenciais
├── .gitignore                 # Arquivos ignorados pelo git
├── requirements.txt           # Dependências Python
└── README.md                  # Este arquivo
```

## 📊 Resultados

Após a execução, três arquivos são gerados:

- `log.html` - Log detalhado da execução
- `report.html` - Relatório visual dos testes
- `output.xml` - Dados em XML para integração

## ⚙️ Funcionalidades

- ✅ Abre o Google Chrome automaticamente
- ✅ Detecta se já está logado
- ✅ Faz login automático no LinkedIn
- ✅ Cria e publica postagens
- ✅ Código limpo e documentado
- ✅ Fácil de personalizar

## 🔒 Segurança

- **Nunca commite o arquivo `.env`** com suas credenciais
- Use sempre o `.gitignore` fornecido
- Considere usar autenticação de dois fatores (pode precisar login manual)

## 🐛 Troubleshooting

### Erro de login
- Verifique suas credenciais no arquivo `.env`
- Se tiver autenticação de dois fatores, faça login manual primeiro

### Chrome não abre
- Certifique-se que o Chrome está instalado
- Rode: `pip install --upgrade webdriver-manager`

### Elementos não encontrados
- O LinkedIn pode mudar a interface
- Ajuste os seletores CSS em `resources/linkedin_keywords.robot`

## 📝 Personalização

### Alterar o navegador

No arquivo `config/settings.robot`:

```robot
${BROWSER}    Firefox    # ou Edge, Safari
```

### Ajustar timeouts

No arquivo `config/settings.robot`:

```robot
${DEFAULT_TIMEOUT}    20s    # aumenta para conexões lentas
```

## 📚 Documentação

- [Robot Framework](https://robotframework.org/)
- [SeleniumLibrary](https://robotframework.org/SeleniumLibrary/)
- [Selenium WebDriver](https://www.selenium.dev/)

## 👨‍💻 Autor

Projeto criado para automação de postagens no LinkedIn.

## 📄 Licença

Livre para uso pessoal e educacional.

---

**⚠️ Aviso**: Use esta automação de forma responsável e de acordo com os Termos de Uso do LinkedIn.
