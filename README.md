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

1. Edit YAML here and commit. Pushing runs the CI config check.
2. `.\deploy.ps1 -DryRun` uploads HEAD, runs `ha core check` on the device, then rolls back.
3. `.\deploy.ps1` deploys HEAD and reloads YAML. Use `-Restart` when `configuration.yaml` changes or an
   integration is added or removed. A failed check restores the previous files automatically.

Deployment goes over SSH via the Terminal & SSH add-on (`root@homeassistant.local:22`, key
`~/.ssh/ha_green_ed25519`) and reloads via the REST API using the `HOME_ASSISTANT_TOKEN` environment variable.

## Notes

- Core listens on port 80. That's a Supervisor setting (`ha core info`), not `configuration.yaml`.
- If you edit automations in the UI, HA rewrites `automations.yaml` on the device. Copy it back into the
  repo before the next deploy, or the deploy will overwrite those edits.
