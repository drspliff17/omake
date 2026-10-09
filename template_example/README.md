# Example Odin Project template

In this example, the usage for the *odin* template following command:

```bash
omake -n projectName -k bin proj -k target src -k path "$PWD/projectName" odin
```

This template generates the following:

- src/main.odin
- compile.sh
- .gitignore
- ds_task.json (for my custom nvim task runner thing)

In which, the keys `{{bin}}`, `{{target}}` and `{{path}}` are replaced
with the given values, on copy
