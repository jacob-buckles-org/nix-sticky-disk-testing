# nix-sticky-disk-testing

Comparing two ways of running Nix with `/nix` on a Blacksmith sticky disk:

- `baseline`: multi-user install via `cachix/install-nix-action`, with daemon cleanup at the end
- `quick-install`: single-user install via `nixbuild/nix-quick-install-action`, no daemon

## Usage

```sh
gh workflow run baseline.yml -f fill_gb=130
gh workflow run quick-install.yml -f fill_gb=130

scripts/run-trials.sh jacob-buckles-org/nix-sticky-disk-testing 10
scripts/compare.sh jacob-buckles-org/nix-sticky-disk-testing 10
```
