# RaffMachine

Home Assistant configuration as code for a Home Assistant Green (`homeassistant.local`, HA 2026.10.4).

The repo root mirrors `/config` on the device. Runtime state (`.storage/`, the recorder DB, logs) and
`secrets.yaml` are git-ignored, so HA owns those and this repo owns the YAML.

## Layout

| Path | Purpose |
|---|---|
| `configuration.yaml` | Entry point. Kept small; loads everything else. |
| `packages/*.yaml` | One file per concern (lighting, climate, presence…). Each can define any integration's config. |
| `automations.yaml`, `scripts.yaml`, `scenes.yaml` | Targets of the UI editors. HA rewrites these when you save in the UI. |
| `themes/` | Frontend themes. |
| `ci/fake_secrets.yaml` | Stand-in secrets so CI can resolve `!secret` references. |
| `.github/workflows/check.yaml` | Runs a full HA config check on every push, pinned to the device's version. |

## Workflow

1. Edit YAML here, push. CI validates the config.
2. Deploy to `/config` (method TBD: Git pull add-on or `scp` via the SSH add-on).
3. Reload the affected domain (Developer Tools → YAML), or restart if a new integration was added.

## Status

- `configuration.yaml` is a **draft** and must be merged with the live file before the first deploy.
  The device serves on port 80, so the live file probably contains settings this draft lacks.
