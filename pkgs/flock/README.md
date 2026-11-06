# Flock

Packages the Linux AppImages from [seatedro/t3code](https://github.com/seatedro/t3code/releases), not the upstream T3 Code releases. Both `x86_64-linux` and `aarch64-linux` have pinned URLs and SHA-256 hashes in `source.json`.

```sh
nix build path:/nix-config#flock
nix run path:/nix-config#flock
```

The installed launcher is `flock-desktop`, avoiding a collision with util-linux's `flock` file-locking command. The desktop application is Flock, and its existing `t3code://` and `t3code-dev://` URL schemes are routed through `flock.desktop`. Niri's `Mod+Ctrl+T` launches Flock.

## Updates

`.github/workflows/update-flock.yml` checks the fork's nightly prereleases daily at **06:17 UTC**, or on manual dispatch. Once this workflow is on the repository's default branch with Actions enabled and permission to write contents, it:

1. Runs the updater tests.
2. Finds the most recently published non-draft nightly and fetches both Linux AppImages to compute their hashes.
3. Builds the x86_64 package and evaluates the ARM64 derivation.
4. Commits only `pkgs/flock/source.json` if the pins changed.

The workflow does not rebuild or switch your machines. Sync the configuration repository and rebuild to install its pinned release. Branch protection must allow the workflow's update commits. GitHub may delay scheduled runs or disable schedules in inactive repositories.

To update locally without waiting for CI:

```sh
./pkgs/flock/update.sh
sudo nixos-rebuild switch --flake "path:/nix-config#$(hostname)"
```

Zsh also exposes `flock-update`; the existing `upgrade` alias runs the updater before updating flake inputs and rebuilding. An optional `GITHUB_TOKEN` authenticates release API requests.

The updater leaves pins untouched if a release is incomplete or a download fails. It is idempotent and reuses hashes for unchanged URLs. Releases are assumed to have immutable versioned assets; the latest 100 releases are searched.

```sh
python3 pkgs/flock/test_update.py
```
