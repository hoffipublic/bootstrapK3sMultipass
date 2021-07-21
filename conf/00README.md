# configuration

## usage:

all contents of all files ending in .yml or .yaml will be read in `00_init.sh`

e.g.:

```yaml
---
some:
  value: val
  flattened:
  - name: one
  - name: two
```


and will be ...

### available as flattened-concatenated exported shell variables:

with

```bash
ytt -f example.yml -o json \
| jq '[leaf_paths as $path | {"key": $path | join("__"), "value": getpath($path)}] | from_entries' \
| yq eval --prettyPrint '.' - \
| yq eval '.. style="single"' - \
| sed -E "s/^([^:]+): (.*)/export \1=\2/"
```


to: (inside `generated/` folder)

```bash
export some__value='val'
export some__flattened__0__name='one'
export some__flattened__1__name='two'
```

### available as ytt data:

to: (inside `generated/` folder)

```yaml
#@data/values
---
some:
  value: val
  flattened:
  - name: one
  - name: two
```
