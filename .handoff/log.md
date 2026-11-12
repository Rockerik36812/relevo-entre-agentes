# Bitácora de relevos

Append-only: **solo se agrega al final**, nunca se reescribe. Es el rastro de quién hizo qué.

Formato: `fecha | agente | qué cambió | archivos | estado`

| fecha | agente | qué cambió | archivos | estado |
|---|---|---|---|---|
| 2026-10-30 02:00 | titán | crea el protocolo de relevo | `AGENTS.md`, `HANDOFF.md`, `.handoff/log.md` | 🟢 plantilla lista |
| 2026-11-12 | titán | agrega a OpenCode como tercer agente del relevo: dueños válidos, roles (dos pares + un trabajador) y regla de no compartir carpeta con Antigravity | `AGENTS.md`, `README.md`, `.agents/rules/protocolo-relevo.md`, `.agents/skills/relevo-entre-agentes/SKILL.md` | 🟢 protocolo listo para 3 agentes |
| 2026-11-12 | titán | fix reportado por OpenCode: quita `sed -i` (GNU-only) de `nuevo-proyecto.sh`, que en macOS abortaba a medias dejando un proyecto sin git ni commit; agrega autoverificación, rama `main` y preflight de git | `scripts/nuevo-proyecto.sh`, `.handoff/log.md` | 🟢 probado en Linux y con sed tipo macOS |
