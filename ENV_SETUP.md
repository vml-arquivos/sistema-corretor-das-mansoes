# 🔧 Guia de Configuração de Variáveis de Ambiente

Este guia explica como configurar as variáveis de ambiente do projeto **Corretor das Mansões** para desenvolvimento e produção com **PostgreSQL**.

---

## 📋 Índice

1. [Configuração Rápida](#configuração-rápida)
2. [Variáveis Obrigatórias](#variáveis-obrigatórias)
3. [Variáveis Opcionais](#variáveis-opcionais)
4. [Ambientes Diferentes](#ambientes-diferentes)
5. [Segurança](#segurança)
6. [Troubleshooting](#troubleshooting)

---

## ⚡ Configuração Rápida

### Passo 1: Copiar o template

```bash
cp .env.example .env
```

### Passo 2: Editar o arquivo .env

```bash
# Linux/Mac
nano .env

# Windows
notepad .env
```

### Passo 3: Gerar JWT Secret

```bash
openssl rand -base64 32
```

Copie o resultado e cole no `.env` como valor de `JWT_SECRET`.

### Passo 4: Preencher valores obrigatórios

Veja a seção [Variáveis Obrigatórias](#variáveis-obrigatórias) abaixo.

### Passo 5: Testar

```bash
# Desenvolvimento
pnpm dev

# Produção (Docker)
docker compose up -d
```

---

## 🔑 Variáveis Obrigatórias

### 1. Banco de Dados (PostgreSQL)

#### `DATABASE_URL`
URL completa de conexão com PostgreSQL.

**Formato:**
```
postgresql://usuario:senha@host:porta/database
```

**Exemplos:**

**Desenvolvimento (local):**
```bash
DATABASE_URL=postgresql://corretor:corretorpassword@localhost:5432/corretordasmansoes
```

**Produção (Docker Compose):**
```bash
DATABASE_URL=postgresql://corretor:suasenha@db:5432/corretordasmansoes
```

**Produção (Cloud - AWS RDS, DigitalOcean, etc.):**
```bash
DATABASE_URL=postgresql://corretor:suasenha@db.exemplo.com:5432/corretordasmansoes
```

#### Outras variáveis do PostgreSQL

```bash
POSTGRES_DB=corretordasmansoes        # Nome do banco
POSTGRES_USER=corretor                 # Usuário do banco
POSTGRES_PASSWORD=suasenhaforte        # Senha do banco
POSTGRES_PORT=5432                     # Porta (padrão: 5432)
```

**⚠️ IMPORTANTE:**
- Use senhas fortes em produção (mínimo 16 caracteres)
- Em Docker, o host é `db` (nome do serviço)
- Em desenvolvimento local, o host é `localhost`

---

### 2. Aplicação

```bash
NODE_ENV=production                    # development | production | test
PORT=3000                              # Porta da aplicação
```

---

### 3. Autenticação JWT

#### `JWT_SECRET`
Chave secreta para assinar tokens JWT.

**Como gerar:**
```bash
openssl rand -base64 32
```

**Exemplo:**
```bash
JWT_SECRET=Xk7mP9qR2sT5vW8yZ1aC4dF6gH9jK0lN3oQ6rU8tV1wX4zA7bC0eF3gH6jK9mP2s
```

**⚠️ NUNCA use o valor de exemplo em produção!**

---

### 4. Manus OAuth

```bash
VITE_APP_ID=seu_app_id                 # ID da aplicação Manus
OAUTH_SERVER_URL=https://api.manus.im  # URL do servidor OAuth
VITE_OAUTH_PORTAL_URL=https://auth.manus.im  # URL do portal de login
```

**Como obter:**
1. Acesse https://manus.im
2. Faça login ou crie uma conta
3. Vá para "Painel de Desenvolvedor"
4. Crie uma nova aplicação
5. Copie o "App ID"

---

### 5. Proprietário/Corretor

```bash
OWNER_OPEN_ID=seu_owner_open_id        # OpenID do proprietário
OWNER_NAME=Hernani Muniz               # Nome do corretor
```

---

### 6. Manus Forge API

```bash
# Backend
BUILT_IN_FORGE_API_URL=https://forge.manus.im
BUILT_IN_FORGE_API_KEY=sua_chave_backend

# Frontend
VITE_FRONTEND_FORGE_API_URL=https://forge.manus.im
VITE_FRONTEND_FORGE_API_KEY=sua_chave_frontend
```

**Como obter as chaves:**
1. Acesse https://manus.im
2. Vá para "Painel de API"
3. Gere chaves separadas para Backend e Frontend

---

## 🎨 Variáveis Opcionais

### Analytics

```bash
VITE_ANALYTICS_ENDPOINT=https://analytics.manus.im
VITE_ANALYTICS_WEBSITE_ID=seu_website_id
```

### Informações do Site

```bash
VITE_APP_TITLE=Corretor das Mansões - Hernani Muniz
VITE_APP_LOGO=https://example.com/logo.png
```

### pgAdmin (Desenvolvimento)

```bash
PGADMIN_PORT=8080
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
```

**Para habilitar o pgAdmin:**
```bash
docker compose --profile dev up -d
```

Acesse: http://localhost:8080

---

## 🌍 Ambientes Diferentes

### Desenvolvimento Local

**Arquivo:** `.env`

```bash
# Banco de Dados
DATABASE_URL=postgresql://corretor:dev123@localhost:5432/corretordasmansoes
POSTGRES_DB=corretordasmansoes
POSTGRES_USER=corretor
POSTGRES_PASSWORD=dev123

# Aplicação
NODE_ENV=development
PORT=3000

# JWT (pode ser simples em dev)
JWT_SECRET=dev_secret_key_not_for_production

# Manus (use credenciais de desenvolvimento)
VITE_APP_ID=dev_app_id
OWNER_OPEN_ID=dev_owner_id
OWNER_NAME=Hernani Muniz

# APIs (use chaves de desenvolvimento)
BUILT_IN_FORGE_API_KEY=dev_backend_key
VITE_FRONTEND_FORGE_API_KEY=dev_frontend_key
```

**Iniciar:**
```bash
pnpm dev
```

---

### Produção (Docker Compose)

**Arquivo:** `.env`

```bash
# Banco de Dados (host = db, nome do serviço Docker)
DATABASE_URL=postgresql://corretor:SenhaForte123!@db:5432/corretordasmansoes
POSTGRES_DB=corretordasmansoes
POSTGRES_USER=corretor
POSTGRES_PASSWORD=SenhaForte123!

# Aplicação
NODE_ENV=production
PORT=3000
APP_PORT=3000

# JWT (GERE COM: openssl rand -base64 32)
JWT_SECRET=Xk7mP9qR2sT5vW8yZ1aC4dF6gH9jK0lN3oQ6rU8tV1wX4zA7bC0eF3gH6jK9mP2s

# Manus (use credenciais de produção)
VITE_APP_ID=prod_app_id
OAUTH_SERVER_URL=https://api.manus.im
VITE_OAUTH_PORTAL_URL=https://auth.manus.im
OWNER_OPEN_ID=prod_owner_id
OWNER_NAME=Hernani Muniz

# APIs (use chaves de produção)
BUILT_IN_FORGE_API_URL=https://forge.manus.im
BUILT_IN_FORGE_API_KEY=prod_backend_key
VITE_FRONTEND_FORGE_API_URL=https://forge.manus.im
VITE_FRONTEND_FORGE_API_KEY=prod_frontend_key

# Analytics
VITE_ANALYTICS_ENDPOINT=https://analytics.manus.im
VITE_ANALYTICS_WEBSITE_ID=prod_website_id

# Site
VITE_APP_TITLE=Corretor das Mansões - Hernani Muniz
VITE_APP_LOGO=https://corretordasmansoes.com.br/logo.png
```

**Iniciar:**
```bash
docker compose up -d
```

---

## 🔒 Segurança

### ✅ Boas Práticas

1. **NUNCA commite o arquivo `.env`**
   - Já está no `.gitignore`
   - Verifique antes de cada commit

2. **Use senhas fortes**
   - Mínimo 16 caracteres
   - Misture letras, números e símbolos

3. **Gere JWT_SECRET único**
   ```bash
   openssl rand -base64 32
   ```

4. **Separe ambientes**
   - Credenciais diferentes para dev/prod
   - Chaves de API diferentes

5. **Use secrets managers em produção**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Azure Key Vault

6. **Rotacione credenciais regularmente**
   - Troque senhas a cada 90 dias

### ❌ Nunca Faça

- ❌ Commitar `.env` no Git
- ❌ Compartilhar `.env` por email/chat
- ❌ Usar senhas padrão em produção
- ❌ Reutilizar senhas entre ambientes
- ❌ Usar `JWT_SECRET` simples em produção

---

## 🔍 Troubleshooting

### Erro: "Cannot connect to database"

**Causa:** DATABASE_URL incorreta ou banco não está rodando.

**Solução:**
```bash
# Verificar se o PostgreSQL está rodando
docker compose ps

# Verificar logs do banco
docker compose logs db

# Testar conexão manualmente
psql "postgresql://corretor:senha@localhost:5432/corretordasmansoes"
```

### Erro: "JWT_SECRET is required"

**Causa:** JWT_SECRET não está definido no `.env`.

**Solução:**
```bash
# Gerar novo secret
openssl rand -base64 32

# Adicionar ao .env
echo "JWT_SECRET=resultado_do_comando_acima" >> .env
```

### Erro: "VITE_APP_ID is not defined"

**Causa:** Variáveis VITE_ não estão sendo carregadas.

**Solução:**
```bash
# Reiniciar o servidor de desenvolvimento
pnpm dev

# Em produção, rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Erro: "Port 3000 is already in use"

**Causa:** Outra aplicação está usando a porta 3000.

**Solução:**
```bash
# Trocar porta no .env
PORT=3001

# Ou matar processo na porta 3000
lsof -ti:3000 | xargs kill -9
```

---

## 📚 Referências

- [Documentação completa de variáveis](./ENV_VARIABLES.md)
- [Guia de deploy em VPS](./DEPLOY_VPS.md)
- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)
- [Manus Platform](https://manus.im)

---

## ✅ Checklist de Configuração

- [ ] Copiei `.env.example` para `.env`
- [ ] Configurei `DATABASE_URL` com PostgreSQL
- [ ] Gerei `JWT_SECRET` com `openssl rand -base64 32`
- [ ] Obtive credenciais Manus (App ID, Owner ID)
- [ ] Obtive chaves de API (Backend e Frontend)
- [ ] Configurei `NODE_ENV` corretamente
- [ ] Testei a aplicação (`pnpm dev` ou `docker compose up`)
- [ ] Verifiquei que `.env` NÃO está no Git
- [ ] Guardei backup do `.env` em local seguro

---

**Última atualização:** 01/12/2025  
**Versão do PostgreSQL:** 16  
**Versão do Node:** 22
