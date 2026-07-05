# omake

## Small utility that allows you to template files, or directories && their contents

The Config directory will be created on launch, if needed.

The Template directory will also be created, inside the config directory

Simply place your files/directories inside the templates dir.

## Usage

```bash
-l | list [-k/key]   - List template names [ or key names ]
-n | name <value>    - Override template name on copy
-k | key  <$K & $V>  - Requires a key, and value to be given
```

To use the key/value substitution, simply add some keys to your config, then
in your templates, you can use a 'key' like:

```bash
{{example}}
```

```bash
# ~/.config/omake/templates/pointlessScript
echo "Here is my {{example}}"
```

Then, when doing:

```bash
omake -k example spoon pointlessScript
```

Would become:

```bash
# ./pointlessScript
echo "Here is my spoon"
```
