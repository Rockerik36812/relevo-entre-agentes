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

## ¿Y si tengo varios proyectos?

**Cada proyecto tiene sus propios archivos, dentro de su propio repo.** Nada se sobrescribe y nada se comparte:

```
relevo-entre-agentes/     ← esta plantilla: SOLO el molde, aquí no se trabaja
panel-agentes/            ← HANDOFF.md propio, AGENTS.md propio
otro-proyecto/            ← HANDOFF.md propio, AGENTS.md propio
```

- El `HANDOFF.md` de un proyecto **no sabe nada** de los otros. Cada repo es su propio batón.
- Esta plantilla **nunca se modifica al adoptar**: se copia. Si mejoras el protocolo, se actualiza aquí y los proyectos lo jalan cuando quieran.
- Los agentes leen el `HANDOFF.md` del repo en el que están trabajando, no uno global.

**Opcional — regla global de Antigravity:** si no quieres depender de que cada repo tenga `.agents/rules/`, puedes poner una regla global en `~/.gemini/AGENTS.md` que diga: *"Si el repo tiene `HANDOFF.md`, sigue el protocolo de relevo"*. Aplica a todos tus proyectos y ahorra repetir la config.

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
