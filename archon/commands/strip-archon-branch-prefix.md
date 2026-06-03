---
description: Strip the archon/ prefix from the current branch name, if present.
allowed-tools: Bash
---

# Strip Archon Branch Prefix

```bash
CURRENT=$(git branch --show-current)
if echo "$CURRENT" | grep -q "^archon/"; then
  NEW="${CURRENT#archon/}"
  git branch -m "$CURRENT" "$NEW"
  echo "Renamed branch: $CURRENT → $NEW"
else
  echo "Branch already correctly named: $CURRENT"
fi
```
