# 🚀 Guia de Deploy em VPS - Corretor das Mansões

Este guia detalha o processo completo de deploy da aplicação em uma VPS usando Docker e Docker Compose com PostgreSQL.

---

## 📋 Pré-requisitos

### Na sua VPS:
- Ubuntu 20.04+ ou Debian 11+ (recomendado)
- Docker 20.10+ instalado
- Docker Compose 2.0+ instalado
- Mínimo 2GB RAM
- Mínimo 20GB de espaço em disco
- Porta 80 e 443 liberadas no firewall

---

## 🔧 Passo 1: Preparar a VPS

### 1.1. Conectar à VPS

```bash
ssh root@seu-servidor.com
# ou
ssh usuario@seu-servidor.com
```

### 1.2. Atualizar o sistema

```bash
sudo apt update && sudo apt upgrade -y
```

### 1.3. Instalar Docker

```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Adicionar usuário ao grupo docker (opcional)
sudo usermod -aG docker $USER

# Verificar instalação
docker --version
```

### 1.4. Instalar Docker Compose

```bash
# Docker Compose v2 (plugin)
sudo apt install docker-compose-plugin -y

# Verificar instalação
docker compose version
```

### 1.5. Instalar Git

```bash
sudo apt install git -y
```

---

## 📦 Passo 2: Clonar o Repositório

```bash
# Navegar para o diretório desejado
cd /opt

# Clonar o repositório
sudo git clone https://github.com/seu-usuario/sistema-corretor-das-mansoes.git

# Entrar no diretório
cd sistema-corretor-das-mansoes

# Dar permissões adequadas
sudo chown -R $USER:$USER .
```

---

## ⚙️ Passo 3: Configurar Variáveis de Ambiente

### 3.1. Copiar arquivo de exemplo

```bash
cp .env.example .env
```

### 3.2. Editar o arquivo .env

```bash
nano .env
```

### 3.3. Configurar valores obrigatórios

**IMPORTANTE:** Preencha TODOS os valores abaixo:

```bash
# Banco de Dados
DATABASE_URL=postgresql://corretor:SENHA_FORTE_AQUI@db:5432/corretordasmansoes
POSTGRES_DB=corretordasmansoes
POSTGRES_USER=corretor
POSTGRES_PASSWORD=SENHA_FORTE_AQUI

# JWT Secret (gere com: openssl rand -base64 32)
JWT_SECRET=sua_chave_jwt_forte_aqui

# Manus OAuth (obtenha no painel Manus)
VITE_APP_ID=seu_app_id
OWNER_OPEN_ID=seu_owner_open_id
OWNER_NAME=Hernani Muniz

# APIs Manus Forge
BUILT_IN_FORGE_API_KEY=sua_chave_backend
VITE_FRONTEND_FORGE_API_KEY=sua_chave_frontend

# Analytics
VITE_ANALYTICS_WEBSITE_ID=seu_website_id
```

### 3.4. Gerar JWT Secret

```bash
openssl rand -base64 32
```

Copie o resultado e cole no `.env` como valor de `JWT_SECRET`.

### 3.5. Salvar e fechar

Pressione `Ctrl+X`, depois `Y`, depois `Enter`.

---

## 🐳 Passo 4: Build e Deploy com Docker Compose

### 4.1. Build das imagens

```bash
docker compose build --no-cache
```

Este processo pode levar 5-10 minutos dependendo da sua conexão.

### 4.2. Iniciar os containers

```bash
docker compose up -d
```

### 4.3. Verificar status

```bash
docker compose ps
```

Você deve ver:
- `corretordasmansoes-db` - healthy
- `corretordasmansoes-app` - healthy

### 4.4. Verificar logs

```bash
# Logs de todos os serviços
docker compose logs -f

# Logs apenas da aplicação
docker compose logs -f app

# Logs apenas do banco
docker compose logs -f db
```

Pressione `Ctrl+C` para sair dos logs.

---

## 🗄️ Passo 5: Aplicar Migrations do Banco de Dados

### 5.1. Executar migrations

```bash
docker compose exec app pnpm db:push
```

### 5.2. Verificar se as tabelas foram criadas

```bash
docker compose exec db psql -U corretor -d corretordasmansoes -c "\dt"
```

Você deve ver as 18 tabelas do sistema.

---

## 🌐 Passo 6: Configurar Nginx (Proxy Reverso)

### 6.1. Instalar Nginx

```bash
sudo apt install nginx -y
```

### 6.2. Criar configuração do site

```bash
sudo nano /etc/nginx/sites-available/corretordasmansoes
```

### 6.3. Adicionar configuração

```nginx
server {
    listen 80;
    server_name seu-dominio.com.br www.seu-dominio.com.br;

    # Logs
    access_log /var/log/nginx/corretordasmansoes-access.log;
    error_log /var/log/nginx/corretordasmansoes-error.log;

    # Proxy para a aplicação
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        access_log off;
    }
}
```

### 6.4. Habilitar o site

```bash
sudo ln -s /etc/nginx/sites-available/corretordasmansoes /etc/nginx/sites-enabled/
```

### 6.5. Testar configuração

```bash
sudo nginx -t
```

### 6.6. Reiniciar Nginx

```bash
sudo systemctl restart nginx
```

---

## 🔒 Passo 7: Configurar SSL/HTTPS com Let's Encrypt

### 7.1. Instalar Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

### 7.2. Obter certificado SSL

```bash
sudo certbot --nginx -d seu-dominio.com.br -d www.seu-dominio.com.br
```

Siga as instruções na tela:
1. Digite seu email
2. Aceite os termos
3. Escolha se deseja compartilhar seu email
4. Escolha opção 2 (redirecionar HTTP para HTTPS)

### 7.3. Verificar renovação automática

```bash
sudo certbot renew --dry-run
```

---

## 🔥 Passo 8: Configurar Firewall

### 8.1. Instalar UFW (se não estiver instalado)

```bash
sudo apt install ufw -y
```

### 8.2. Configurar regras

```bash
# Permitir SSH (IMPORTANTE: faça isso primeiro!)
sudo ufw allow 22/tcp

# Permitir HTTP e HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Habilitar firewall
sudo ufw enable

# Verificar status
sudo ufw status
```

---

## ✅ Passo 9: Verificar Deployment

### 9.1. Testar aplicação

Abra no navegador:
```
https://seu-dominio.com.br
```

### 9.2. Testar health check

```bash
curl https://seu-dominio.com.br/health
```

Deve retornar status 200 OK.

---

## 🔄 Comandos Úteis de Manutenção

### Ver logs em tempo real

```bash
docker compose logs -f app
```

### Reiniciar aplicação

```bash
docker compose restart app
```

### Parar todos os containers

```bash
docker compose down
```

### Iniciar todos os containers

```bash
docker compose up -d
```

### Rebuild e restart

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Backup do banco de dados

```bash
docker compose exec db pg_dump -U corretor corretordasmansoes > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restaurar backup

```bash
cat backup_20250101_120000.sql | docker compose exec -T db psql -U corretor -d corretordasmansoes
```

### Ver uso de recursos

```bash
docker stats
```

### Limpar containers e imagens antigas

```bash
docker system prune -a
```

---

## 🔍 Troubleshooting

### Aplicação não inicia

```bash
# Ver logs detalhados
docker compose logs app

# Verificar se o banco está rodando
docker compose ps db

# Testar conexão com o banco
docker compose exec app node -e "console.log(process.env.DATABASE_URL)"
```

### Erro de conexão com banco de dados

```bash
# Verificar se o banco está healthy
docker compose ps

# Reiniciar o banco
docker compose restart db

# Verificar logs do banco
docker compose logs db
```

### Porta já em uso

```bash
# Ver o que está usando a porta 3000
sudo lsof -i :3000

# Matar processo (substitua PID)
sudo kill -9 PID
```

### Migrations não aplicadas

```bash
# Entrar no container da aplicação
docker compose exec app sh

# Executar migrations manualmente
pnpm db:push

# Sair
exit
```

---

## 📊 Monitoramento

### Verificar saúde dos containers

```bash
docker compose ps
```

### Verificar logs de erro

```bash
docker compose logs app | grep -i error
```

### Verificar uso de disco

```bash
df -h
```

### Verificar uso de memória

```bash
free -h
```

---

## 🔄 Atualização da Aplicação

### 1. Fazer backup

```bash
# Backup do banco
docker compose exec db pg_dump -U corretor corretordasmansoes > backup_pre_update.sql

# Backup do .env
cp .env .env.backup
```

### 2. Atualizar código

```bash
git pull origin main
```

### 3. Rebuild e restart

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### 4. Aplicar novas migrations

```bash
docker compose exec app pnpm db:push
```

### 5. Verificar

```bash
docker compose logs -f app
```

---

## 🆘 Suporte

Em caso de problemas:

1. Verifique os logs: `docker compose logs -f`
2. Verifique o status: `docker compose ps`
3. Verifique as variáveis de ambiente: `cat .env`
4. Consulte a documentação: `ENV_VARIABLES.md`

---

## 📝 Checklist Final

- [ ] VPS preparada e atualizada
- [ ] Docker e Docker Compose instalados
- [ ] Repositório clonado
- [ ] Arquivo .env configurado com valores reais
- [ ] JWT_SECRET gerado
- [ ] Containers buildados e rodando
- [ ] Migrations aplicadas
- [ ] Nginx configurado
- [ ] SSL/HTTPS configurado
- [ ] Firewall configurado
- [ ] Aplicação acessível via HTTPS
- [ ] Health check funcionando
- [ ] Backup configurado

---

**Deploy concluído com sucesso!** 🎉
