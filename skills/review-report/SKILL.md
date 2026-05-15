# Review Report Skill

Use this skill when the user asks for a review report of generated code, or invokes `/review-report`.

## Instructions

Generate a file-by-file code review report. For each file created, modified, or deleted:

1. **Show the file path and status** (created / modified / deleted)
2. **Show the file's full content** (or just the diff for modified files)
3. **Add a block below each file** with a short explanation:

```
> **Pourquoi :** <1-3 lines explaining what this file does and why it's needed. Avoid walls of text. One key insight per file.>
```

4. **End with a summary section**:
   - What components are new vs removed vs kept
   - What happens when deployed (the flow)
   - What is NOT included and why

## Tone

- Explain the "why", not the "what"
- 1-3 lines per explanation
- Use `>` blockquotes for explanations so they visually separate from code
- Every explanation must answer: "what would break if I deleted this file?"

## Report structure

```
## N files créés, M modifiés, X supprimés

### 1. `path/to/file.yaml` (créé)

```yaml
<full content>
```

> **Pourquoi :** <explanation>

[... repeat for each file ...]

### Résumé

| Composant | Avant | Après |
|---|---|---|
...
```

## Notes

- Always list ALL files, no exceptions
- Modified files: show just the changed lines with before/after
- If a file was copied from elsewhere, mention the source
- Never group explanations across files — one explanation per file
