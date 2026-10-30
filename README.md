# Relevo entre agentes — Titán ↔ Antigravity

Plantilla para trabajar un proyecto **en turnos entre dos agentes**, sin que ninguno pierda el trabajo del otro.

**El problema que resuelve:** a Erik se le acaba el uso de Antigravity y quiere que Titán continúe desde donde él quedó; luego Antigravity regresa y sigue. Sin un punto de relevo, el segundo agente no tiene idea de qué se hizo.

**La solución:** el estado vive en el **repo Git**, no en la conversación.

## Cómo funciona

| Archivo | Para qué |
|---|---|
| `AGENTS.md` | El protocolo. **Los dos agentes lo leen automáticamente.** |
| `HANDOFF.md` | El batón: estado vivo, dueño actual y el SIGUIENTE PASO. |
| `.handoff/log.md` | Bitácora append-only: quién hizo qué y cuándo. |
| `.agents/rules/protocolo-relevo.md` | Regla que Antigravity carga sola en este proyecto. |
| `.agents/skills/relevo-entre-agentes/SKILL.md` | La misma skill, en el formato estándar, para Antigravity. |

**Por qué Git:** Titán empuja desde el servidor, Antigravity desde la PC de Erik, y los dos ven exactamente lo mismo. Si un agente se equivoca, el historial lo delata.

## Empezar un proyecto nuevo

```bash
# 1. Clona la plantilla
git clone <url-de-este-repo> mi-proyecto
cd mi-proyecto

# 2. Borra el historial de la plantilla y arranca limpio
rm -rf .git && git init
# 3. Renombra el repo y describe el proyecto en HANDOFF.md
```

## Arrancar un turno (el prompt que se le da al agente)

**A Titán (Telegram):**
> Toma el proyecto: clona `<repo>`, lee `HANDOFF.md` y continúa desde el SIGUIENTE PASO. Cuando termines, deja el relevo actualizado y haz push.

**A Antigravity (IDE):**
> Lee `HANDOFF.md` y `.handoff/log.md`, toma el batón (`Dueño actual: antigravity`) y continúa desde el SIGUIENTE PASO. Al terminar, actualiza `HANDOFF.md`, la bitácora, y haz push.

## Reglas que hacen que funcione

1. **Un solo dueño a la vez.** Si `Dueño actual` no está libre, no se toca el repo.
2. **Al cerrar, se actualiza `HANDOFF.md`.** Siempre. Es la única forma de que el relevo no se rompa.
3. **Estado autocontenido.** El otro agente no ve la conversación: si no está en el repo, no existe.
4. **Nada de secretos en el repo.** Se documenta dónde vive el secreto, no su valor.
5. **Commits con prefijo** `[titán]` / `[antigravity]` para saber de quién es cada cambio.

---
© By Erik Cano
