#!/usr/bin/env bash
# Inyecta el protocolo de relevo en un proyecto YA EXISTENTE, sin tocar su código.
# Uso: ./scripts/adoptar-proyecto.sh /ruta/al/repo-existente "Nombre del proyecto"
# NO hace push: deja el commit local para que Erik o el agente decidan.
set -euo pipefail

DEST="${1:?uso: adoptar-proyecto.sh <ruta-del-repo> <nombre-del-proyecto>}"
NOMBRE="${2:?falta el nombre del proyecto}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -d "$DEST" ] || { echo "ERROR: $DEST no existe"; exit 1; }
git -C "$DEST" rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: $DEST no es un repo git"; exit 1; }

echo "== Adoptando protocolo de relevo en: $DEST"

# --- 1. Archivos que no dependen del proyecto -------------------------------
mkdir -p "$DEST/.handoff" "$DEST/.agents/rules" "$DEST/.agents/skills/relevo-entre-agentes"
cp "$SRC/.agents/rules/protocolo-relevo.md"                    "$DEST/.agents/rules/protocolo-relevo.md"
cp "$SRC/.agents/skills/relevo-entre-agentes/SKILL.md"         "$DEST/.agents/skills/relevo-entre-agentes/SKILL.md"

# AGENTS.md: no se sobrescribe si ya existe (puede tener reglas del proyecto)
if [ -f "$DEST/AGENTS.md" ]; then
  echo "   AGENTS.md ya existía -> se conserva, se le anexa el protocolo si falta"
  if ! grep -q 'Protocolo de relevo' "$DEST/AGENTS.md"; then
    { echo; echo "---"; echo; cat "$SRC/AGENTS.md"; } >> "$DEST/AGENTS.md"
  fi
else
  cp "$SRC/AGENTS.md" "$DEST/AGENTS.md"
fi

# --- 2. Bitácora: arranca limpia y con la primera línea real ---------------
if [ ! -f "$DEST/.handoff/log.md" ]; then
  cat > "$DEST/.handoff/log.md" <<'EOF'
# Bitácora de relevos

Append-only: **solo se agrega al final**, nunca se reescribe. Es el rastro de quién hizo qué.

Formato: `fecha | agente | qué cambió | archivos | estado`

| fecha | agente | qué cambió | archivos | estado |
|---|---|---|---|---|
EOF
  printf '| %s | titán | adopta el protocolo de relevo | `AGENTS.md`, `HANDOFF.md`, `.handoff/`, `.agents/` | 🟢 protocolo activo |\n' \
    "$(date '+%Y-%m-%d %H:%M')" >> "$DEST/.handoff/log.md"
fi

# --- 3. HANDOFF.md: se prellena con lo que el repo ya dice ----------------
if [ -f "$DEST/HANDOFF.md" ]; then
  echo "   HANDOFF.md ya existía -> NO se toca (borra o renombra si quieres regenerarlo)"
else
  RAMA=$(git -C "$DEST" rev-parse --abbrev-ref HEAD)
  ULTIMOS=$(git -C "$DEST" log -8 --format='- [x] `%h` %s (%ad)' --date=short 2>/dev/null || echo "- (repo sin commits)")
  TOPE=$(cd "$DEST" && ls -1A | grep -vE '^\.git$|^\.handoff$|^\.agents$' | head -12 | sed 's/^/- `/; s/$/`/')

  # Comandos útiles detectados
  CMDS=""
  [ -f "$DEST/package.json" ]       && CMDS="${CMDS}npm install && npm run dev   # arrancar\n"
  [ -f "$DEST/docker-compose.yml" ] && CMDS="${CMDS}docker compose up -d      # levantar con Docker\n"
  [ -f "$DEST/Makefile" ]           && CMDS="${CMDS}make                        # tareas del Makefile\n"
  [ -f "$DEST/requirements.txt" ]   && CMDS="${CMDS}pip install -r requirements.txt\n"
  [ -z "$CMDS" ]                    && CMDS="# (no se detectó comando de arranque: anótalo aquí)\n"

  cat > "$DEST/HANDOFF.md" <<EOF
# HANDOFF — $NOMBRE

**Dueño actual:** libre
**Última actualización:** $(date '+%Y-%m-%d %H:%M') (CST)
**Estado:** 🟡 adoptado — falta definir el siguiente paso

## Objetivo

> ⚠️ PENDIENTE DE ESCRIBIR. Una o dos frases: qué tiene que existir para que esto esté TERMINADO.

## SIGUIENTE PASO

> ⚠️ PENDIENTE DE ESCRIBIR. Una sola acción concreta y verificable.

\`\`\`bash
# comando si aplica
\`\`\`

## Hecho (historial reciente del repo, rama \`$RAMA\`)

$ULTIMOS

*Lo anterior es solo el historial de Git: no dice si quedó verificado ni qué falta.*

## En curso (a medias)

- (pendiente de revisar)

## Bloqueos y decisiones pendientes

- (pendiente de revisar)

## Comandos útiles

\`\`\`bash
$(printf "$CMDS")
\`\`\`

## Archivos clave

$TOPE

## Notas para el otro agente

- Proyecto adoptado al protocolo de relevo el $(date '+%Y-%m-%d'). El estado real hay que confirmarlo leyendo el código y el historial.
EOF
fi

# --- 4. Commit SOLO de los archivos del protocolo --------------------------
git -C "$DEST" add AGENTS.md HANDOFF.md .handoff .agents
git -C "$DEST" -c user.name=Rockerik -c user.email=erik36812@gmail.com \
  commit -q -m "[plantilla] adopta el protocolo de relevo entre agentes" \
  && echo "   commit local creado ✅"

echo
echo "OK: $NOMBRE adoptado."
echo "  1) Escribe el Objetivo y el SIGUIENTE PASO en $DEST/HANDOFF.md"
echo "  2) Revisa la sección 'En curso' (el historial de Git no dice qué quedó a medias)"
echo "  3) Push cuando estés listo:  git -C $DEST push"
