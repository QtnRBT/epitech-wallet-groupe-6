FROM oven/bun:1.2.13-alpine

WORKDIR /app

# Install dependencies first for better layer caching
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copy source
COPY . .

# Build-time defaults (must be overridden in runtime env)
ENV NODE_ENV=production \
    DATABASE_URL=postgresql://wallet_user:wallet_password@postgres:5432/wallet_db \
    JWT_SECRET=change-me-in-production-min-32-chars \
    INTERWALLET_HMAC_SECRET=change-me \
    INTERWALLET_SYSTEM_URL=http://localhost:3000 \
    INTERWALLET_SYSTEM_NAME=Wallet \
    STRIPE_SECRET_KEY=sk_test_dummy \
    STRIPE_CURRENCY=EUR

# Build app once, run many times
RUN bunx prisma generate && bun run build

EXPOSE 3000

ENTRYPOINT ["/app/docker-entrypoint.sh"]
