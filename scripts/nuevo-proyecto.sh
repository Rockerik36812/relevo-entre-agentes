#!/usr/bin/env bash
# Crea un proyecto nuevo a partir de esta plantilla de relevo.
# Uso: ./scripts/nuevo-proyecto.sh /ruta/destino "Nombre del proyecto"
set -euo pipefail

DEST="${1:?uso: nuevo-proyecto.sh <ruta-destino> <nombre-del-proyecto>}"
NOMBRE="${2:?falta el nombre del proyecto}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -e "$DEST" ] && { echo "ERROR: $DEST ya existe"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: falta git en el PATH"; exit 1; }

# `sed -i` NO es portable: GNU lo acepta como `sed -i`, BSD/macOS exige `sed -i ''`.
# Aborta el script a medias (carpeta creada y sin commit). Se escribe a un temporal
# y se copia encima del original: mismo resultado en Linux y en macOS.
editar_en_sitio() {
  local expr="$1" archivo="$2" tmp
  tmp="$(mktemp "$archivo.XXXXXX")"
  if ! sed "$expr" "$archivo" > "$tmp"; then
    rm -f "$tmp"
    echo "ERROR: sed falló editando $archivo"
    return 1
  fi
  cat "$tmp" > "$archivo"
  rm -f "$tmp"
}

# Escapa lo que sed interpreta DENTRO del reemplazo: `\` (escape), `&` (la
# coincidencia completa) y `|` (el delimitador de estos `s|||`). Sin esto, un
# proyecto llamado "Diseño & Marketing" o "Panel | Beta" corrompe el reemplazo.
escapar_sed() {
  printf '%s' "$1" | sed 's/[\\&|]/\\&/g'
}

mkdir -p "$DEST"
for f in AGENTS.md HANDOFF.md README.md .agents; do
  cp -r "$SRC/$f" "$DEST/"
done
mkdir -p "$DEST/.handoff"
cp "$SRC/.handoff/log.md" "$DEST/.handoff/log.md"

# Ajusta el nombre del proyecto en el handoff
NOMBRE_SED="$(escapar_sed "$NOMBRE")"
editar_en_sitio "s|^# HANDOFF — .*|# HANDOFF — $NOMBRE_SED|" "$DEST/HANDOFF.md"
if [ -f "$DEST/README.md" ]; then
  editar_en_sitio "s|^# Relevo entre agentes — .*|# Relevo entre agentes — $NOMBRE_SED|" "$DEST/README.md"
fi
# La bitácora arranca limpia en proyectos nuevos
cat > "$DEST/.handoff/log.md" <<'EOF'
# Bitácora de relevos

Append-only: **solo se agrega al final**, nunca se reescribe. Es el rastro de quién hizo qué.

Formato: `fecha | agente | qué cambió | archivos | estado`

| fecha | agente | qué cambió | archivos | estado |
|---|---|---|---|---|
EOF

git -C "$DEST" init -q
git -C "$DEST" symbolic-ref HEAD refs/heads/main   # la rama se llama main, como en el protocolo
git -C "$DEST" add -A
git -C "$DEST" -c user.name="${GIT_AUTHOR_NAME:-Rockerik}" -c user.email="${GIT_AUTHOR_EMAIL:-erik36812@gmail.com}" \
  commit -q -m "[plantilla] arranca $NOMBRE con protocolo de relevo"

# --- Autoverificación: el proyecto NO puede quedar a medias ----------------
fallas=0
grep -q "<nombre del proyecto>" "$DEST/HANDOFF.md" && { echo "ERROR: HANDOFF.md conservó el marcador <nombre del proyecto>"; fallas=1; }
grep -qxF "# HANDOFF — $NOMBRE" "$DEST/HANDOFF.md" || { echo "ERROR: HANDOFF.md no quedó con el nombre real del proyecto"; fallas=1; }
git -C "$DEST" rev-parse --verify HEAD >/dev/null 2>&1 || { echo "ERROR: el repo quedó sin commit inicial"; fallas=1; }
if [ "$fallas" -ne 0 ]; then
  echo
  echo "El proyecto quedó INCOMPLETO en $DEST. Bórralo y repite:  rm -rf $DEST"
  exit 1
fi

echo "OK: $NOMBRE creado en $DEST"
echo "Siguiente: describe el Objetivo y el SIGUIENTE PASO en $DEST/HANDOFF.md"
