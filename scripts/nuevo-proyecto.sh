#!/usr/bin/env bash
# Crea un proyecto nuevo a partir de esta plantilla de relevo.
# Uso: ./scripts/nuevo-proyecto.sh /ruta/destino "Nombre del proyecto"
set -euo pipefail

DEST="${1:?uso: nuevo-proyecto.sh <ruta-destino> <nombre-del-proyecto>}"
NOMBRE="${2:?falta el nombre del proyecto}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -e "$DEST" ] && { echo "ERROR: $DEST ya existe"; exit 1; }

mkdir -p "$DEST"
for f in AGENTS.md HANDOFF.md README.md .agents; do
  cp -r "$SRC/$f" "$DEST/"
done
mkdir -p "$DEST/.handoff"
cp "$SRC/.handoff/log.md" "$DEST/.handoff/log.md"

# Ajusta el nombre del proyecto en el handoff
sed -i "s|^# HANDOFF — .*|# HANDOFF — $NOMBRE|" "$DEST/HANDOFF.md"
sed -i "s|^# Relevo entre agentes — .*|# Relevo entre agentes — $NOMBRE|" "$DEST/README.md" 2>/dev/null || true
# La bitácora arranca limpia en proyectos nuevos
cat > "$DEST/.handoff/log.md" <<'EOF'
# Bitácora de relevos

Append-only: **solo se agrega al final**, nunca se reescribe. Es el rastro de quién hizo qué.

Formato: `fecha | agente | qué cambió | archivos | estado`

| fecha | agente | qué cambió | archivos | estado |
|---|---|---|---|---|
EOF

git -C "$DEST" init -q
git -C "$DEST" add -A
git -C "$DEST" commit -q -m "[plantilla] arranca $NOMBRE con protocolo de relevo"

echo "OK: $NOMBRE creado en $DEST"
echo "Siguiente: describe el Objetivo y el SIGUIENTE PASO en $DEST/HANDOFF.md"
