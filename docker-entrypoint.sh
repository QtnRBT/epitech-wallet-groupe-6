#!/usr/bin/env sh
set -eu

echo "[entrypoint] Starting wallet initialization..."

echo "[entrypoint] Generating Prisma client"
bunx prisma generate

echo "[entrypoint] Applying database schema (prisma db push)"
ATTEMPT=1
MAX_ATTEMPTS=${DB_PUSH_MAX_ATTEMPTS:-30}

until bunx prisma db push; do
  if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "[entrypoint] prisma db push failed after ${MAX_ATTEMPTS} attempts"
    exit 1
  fi

  echo "[entrypoint] Database not ready yet, retry ${ATTEMPT}/${MAX_ATTEMPTS} in 2s..."
  ATTEMPT=$((ATTEMPT + 1))
  sleep 2
done

if [ "${RUN_DB_SEED:-false}" = "true" ]; then
  echo "[entrypoint] Running seed"
  bun run seed
else
  echo "[entrypoint] Seed skipped (RUN_DB_SEED=false)"
fi

echo "[entrypoint] Building Next.js app"
bun run build

echo "[entrypoint] Starting Next.js app"
exec bun run start
