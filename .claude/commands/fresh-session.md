---
description: Archive Doggies session summaries for a clean-context next session
---

Run the fresh-session script to archive all prior session summaries for this project.
The next time you open Claude Code in this project, no prior context will be injected.

```bash
bash /Users/guirau/GitHub/guirau/Doggies/scripts/clear-session.sh
```

After running, **start a new Claude Code session** — `/clear` alone is not enough because
the startup hook already fired for this session.

To also **overwrite** the saved context (rather than erase it), run `ecc:save-session`
at the end of your current session. That writes a new `.tmp` with only what happened today.
