# git-kura (git-kura)

Installs [git-kura](https://github.com/tooppoo/git-kura), a keyed Git worktree resolver.

After this Feature is installed, `git-kura` is available on `PATH` and can also be used as a Git subcommand with `git kura ...`.

## Example Usage

```jsonc
{
    "features": {
        "ghcr.io/tooppoo/devcontainer-features/git-kura:0": {}
    }
}
```

Pin a specific git-kura binary release:

```jsonc
{
    "features": {
        "ghcr.io/tooppoo/devcontainer-features/git-kura:0": {
            "version": "v0.0.3"
        }
    }
}
```

Install into a custom directory and require cosign verification:

```jsonc
{
    "features": {
        "ghcr.io/tooppoo/devcontainer-features/git-kura:0": {
            "install_dir": "/usr/local/bin",
            "require_signature": true
        }
    }
}
```

When `require_signature` is `true`, `cosign` must already be installed in the image. If it is missing, installation fails with an explicit error from the upstream installer.

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | git-kura release tag to install. Use latest to install the latest release. | string | latest |
| install_dir | Directory where git-kura will be installed. | string | /usr/local/bin |
| require_signature | Require cosign signature verification during installation. | boolean | false |

## Supported Images

This Feature currently supports Debian/Ubuntu based images.
