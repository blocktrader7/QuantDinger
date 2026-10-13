# Como Subir o QuantDinger no Easypanel

Este guia explica passo a passo como realizar o deploy do **QuantDinger** no **Easypanel** em um VPS em nuvem de forma rápida, segura e automatizada.

---

## 🏗️ Visão Geral da Arquitetura no Easypanel

O QuantDinger é uma plataforma quantitativa completa com streaming distribuído de eventos e microserviços:

- **Imagens Pré-compiladas (GHCR)**: O stack utiliza as imagens oficiais do GitHub Container Registry (`ghcr.io/openbyteinc/...`), evitando builds demorados ou estouros de memória/CPU no seu VPS.
- **Roteamento Unificado & SSL**: O Traefik do Easypanel roteia o tráfego HTTP/HTTPS diretamente para os containers `frontend` (Web) e `mobile` (H5).
- **Proxy Interno**: As requisições de API (`/api/...`) feitas pelos clientes web/mobile são repassadas internamente pelo Nginx para o backend (`http://backend:5000`). Você **não precisa** expor a porta 5000 para a internet.
- **Isolamento de Banco e Filas**: PostgreSQL 18, Redis (Cache e Celery) e Apache Kafka 4.3 rodam na rede privada interna (`quantdinger-network`), sem publicar portas no Host e sem risco de conflito com outros apps no seu VPS.

---

## ⚙️ Requisitos do VPS

- **Sistema**: Ubuntu 22.04/24.04 ou Debian 12 com Easypanel instalado.
- **Memória RAM**:
  - Mínimo: 4 vCPU / 8 GB RAM.
  - Recomendado: 8 vCPU / 16 GB RAM (quando executar múltiplos robôs de trading, LLMs e backtests simultâneos).
- **Disco**: Mínimo 40 GB livre.
- **Domínios (DNS)**:
  - Exemplo Web: `trader.seudominio.com` apontando para o IP do seu VPS.
  - Exemplo Mobile: `m.seudominio.com` (opcional) apontando para o IP do seu VPS.

---

## 🚀 Passo a Passo de Instalação no Easypanel

### Método 1: Via Repositório Git (Recomendado)

1. No painel do Easypanel, entre no seu **Projeto** (ou crie um chamado `quantdinger`).
2. Clique em **+ Service** e selecione **Docker Compose**.
3. Defina as configurações do Git:
   - **Repository**: `https://github.com/blocktrader7/QuantDinger` (ou sua URL personalizada).
   - **Branch**: `main`
   - **Compose Path**: `docker-compose.easypanel.yml`

### Método 2: Via Docker Compose Direto (Sem Git)

Se preferir não conectar ao GitHub:
1. No Easypanel, crie um novo serviço do tipo **Docker Compose**.
2. Cole o conteúdo integral do arquivo [`docker-compose.easypanel.yml`](../../docker-compose.easypanel.yml) no editor.

---

### 🔑 Configurar Variáveis de Ambiente (Environment)

1. No Easypanel, acesse a aba **Environment** do serviço Docker Compose.
2. Copie o modelo do arquivo [`easypanel.env.example`](../../easypanel.env.example) e preencha com seus dados:

```ini
# Timezone
TZ=America/Sao_Paulo

# Credenciais de Acesso Inicial
ADMIN_USER=admin
ADMIN_PASSWORD=SuaSenhaForteSegura123!
ADMIN_EMAIL=admin@seudominio.com

# Chaves de Criptografia (Gere com: python3 -c "import secrets; print(secrets.token_hex(32))")
SECRET_KEY=sua_chave_hex_32_bytes_gerada
CREDENTIAL_ENCRYPTION_KEY=sua_outra_chave_hex_32_bytes_gerada

# Banco de Dados Interno
POSTGRES_DB=quantdinger
POSTGRES_USER=quantdinger
POSTGRES_PASSWORD=senha_forte_do_postgres_123

# URLs autorizadas (coloque seus domínios com https://)
FRONTEND_URL=https://trader.seudominio.com,https://m.seudominio.com

# Segurança em Nuvem
ALLOW_LOCAL_DESKTOP_BROKERS=false

# Inteligência Artificial / LLM (OpenRouter gratuito por padrão)
LLM_PROVIDER=openrouter
OPENROUTER_API_KEY=sk-or-v1-seu-token-openrouter-aqui
OPENROUTER_MODEL=nvidia/nemotron-3.5-lightning:free
```

---

### 🌐 Configurar Domínios & SSL Automático

1. No Easypanel, acesse a aba **Domains** do serviço.
2. Adicione os domínios:
   - **Frontend Web**:
     - Domain: `trader.seudominio.com`
     - Service: `frontend`
     - Port: `80`
   - **Frontend Mobile** (opcional):
     - Domain: `m.seudominio.com`
     - Service: `mobile`
     - Port: `80`
3. O Easypanel configurará o proxy reverso Traefik e gerará os certificados SSL (Let's Encrypt) automaticamente.

---

### ▶️ Iniciar o Deploy

1. Clique em **Deploy**.
2. O Easypanel irá:
   - Baixar as imagens pré-compiladas do GHCR.
   - Criar os volumes persistentes (`postgres_data`, `backend_data`, `kafka_data`, etc.).
   - Inicializar o PostgreSQL e executar as migrações automáticas (`migration`).
   - Criar os tópicos do Apache Kafka (`kafka-init`).
   - Inicializar a API, os Workers de trading e os Frontends.
3. Após todos os containers estarem saudáveis (`healthy`), acesse seu domínio `https://trader.seudominio.com`.

---

## 👤 Primeiro Acesso

1. Abra `https://trader.seudominio.com` no navegador.
2. Faça login com o usuário e senha definidos em `ADMIN_USER` e `ADMIN_PASSWORD`.
3. Navegue até o dashboard, verifique os gráficos em tempo real (ex: `BTC/USDT`, ações) e teste o assistente de IA.

---

## 🔗 Sobre a Desassociação do Fork no GitHub

O Easypanel **não faz nenhuma restrição** ao fato do repositório ser um fork ou independente: ele faz o clone e o deploy normalmente em ambos os casos.

Se você deseja desassociar o fork no próprio GitHub para que não apareça o texto *"forked from OpenByteInc/QuantDinger"*:

1. **Método Rápido Oficial (sem perder commits nem histórico)**:
   - Acesse o [GitHub Support](https://support.github.com).
   - No assistente virtual/chat, digite: `detach fork for blocktrader7/QuantDinger`.
   - O bot do GitHub remove o vínculo de fork em segundos mantendo seu repositório 100% intacto como repositório independente.

2. **Remoção Local do Upstream**:
   - O remote `upstream` já foi desassociado localmente (`git remote remove upstream`), mantendo seu repositório apontando apenas para o seu `origin`.
