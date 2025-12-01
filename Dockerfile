# ============================================
# STAGE 1: Build do Frontend (Client)
# ============================================
FROM node:22-alpine AS client-builder

WORKDIR /app

# Instalar pnpm globalmente
RUN npm install -g pnpm@latest

# Copiar arquivos de dependências
COPY package.json pnpm-lock.yaml ./

# Instalar todas as dependências (incluindo devDependencies para build)
RUN pnpm install --frozen-lockfile

# Copiar código fonte necessário para o build do client
COPY client ./client
COPY shared ./shared
COPY tsconfig.json ./
COPY vite.config.ts ./
COPY components.json ./
COPY patches ./patches

# Build do frontend
RUN pnpm run build:client

# ============================================
# STAGE 2: Build do Backend (Server)
# ============================================
FROM node:22-alpine AS server-builder

WORKDIR /app

# Instalar pnpm globalmente
RUN npm install -g pnpm@latest

# Copiar arquivos de dependências
COPY package.json pnpm-lock.yaml ./

# Instalar todas as dependências (incluindo devDependencies para build)
RUN pnpm install --frozen-lockfile

# Copiar código fonte necessário para o build do server
COPY server ./server
COPY drizzle ./drizzle
COPY shared ./shared
COPY tsconfig.json ./

# Build do backend
RUN pnpm run build:server

# ============================================
# STAGE 3: Imagem Final de Produção
# ============================================
FROM node:22-alpine

WORKDIR /app

# Instalar pnpm globalmente
RUN npm install -g pnpm@latest

# Copiar arquivos de dependências
COPY package.json pnpm-lock.yaml ./

# Instalar APENAS dependências de produção
RUN pnpm install --prod --frozen-lockfile

# Copiar builds do frontend e backend dos stages anteriores
COPY --from=client-builder /app/dist/public ./dist/public
COPY --from=server-builder /app/dist/server ./dist/server

# Copiar arquivos necessários para runtime
COPY drizzle ./drizzle
COPY shared ./shared
COPY server/_core ./server/_core

# Criar diretório para storage se necessário
RUN mkdir -p storage

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Mudar para usuário não-root
USER nodejs

# Expor porta da aplicação
EXPOSE 3000

# Variáveis de ambiente padrão
ENV NODE_ENV=production \
    PORT=3000

# Health check - verifica se a aplicação está respondendo
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

# Comando de inicialização
CMD ["pnpm", "start"]
