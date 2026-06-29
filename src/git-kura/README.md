
# git-kura (git-kura)

Installs git-kura, a keyed Git worktree resolver.

## Example Usage

```json
"features": {
    "ghcr.io/tooppoo/catalog-devcontainer-features/git-kura:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | git-kura release tag to install. Use latest to install the latest release. i.e. "0.0.7" | string | latest |
| install_dir | Directory where git-kura will be installed. | string | /usr/local/bin |
| require_signature | Require cosign signature verification during installation. | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/tooppoo/catalog-devcontainer-features/blob/main/src/git-kura/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
