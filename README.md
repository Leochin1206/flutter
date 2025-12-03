# 📱 Projeto Final PPDM - Sistema de Monitoramento de Sensores

## 📋 Pré-requisitos

Para rodar este projeto, você precisará de:

1.  **Flutter SDK** instalado e configurado.
2.  **Python 3.10** ou superior.
3.  **Android Studio** (com Emulador configurado) ou VS Code.
4.  **Permissão de Desenvolvedor** ativa no Windows (para plugins do Flutter).

---

## 🚀 Passo 1: Iniciando o Backend (API)

O backend é responsável por salvar os dados no banco (SQLite) e fornecer as informações para o aplicativo.

1.  Abra o terminal e entre na pasta `backend`:
    ```bash
    cd backend
    ```

2.  Crie e ative o ambiente virtual (Recomendado para isolar as bibliotecas):
    * **No Windows:**
        ```bash
        python -m venv venv
        .\venv\Scripts\activate
        ```

3.  Instale as dependências do projeto:
    ```bash
    pip install -r requirements.txt
    ```

4.  Inicie o servidor:
    O comando abaixo inicia a API liberando o acesso externo (necessário para o Emulador Android acessar via `10.0.2.2`).
    ```bash
    uvicorn main:app --reload
    ```
