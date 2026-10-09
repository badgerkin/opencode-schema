# opencode-schema

JSON Schema for [opencode](https://github.com/anomalyco/opencode) **v2** config files (`opencode.json` / `opencode.jsonc`).

opencode only hosts the v1 schema (`https://opencode.ai/config.json`) for now. The official v2 schema will live at
`https://opencode.ai/v2/config.json` once [anomalyco/opencode#51804](https://github.com/anomalyco/opencode/pull/51804)
ships. Switch to that URL then. This repo is a stopgap until that happens.

## Usage

```jsonc
{
  "$schema": "https://badgerkin.github.io/opencode-schema/v2/config.json",
}
```

| URL | Contents |
| --- | --- |
| `https://badgerkin.github.io/opencode-schema/v2/config.json` | Latest v2 release (updated when new versions are added) |
| `https://badgerkin.github.io/opencode-schema/v2.0.26/config.json` | A specific opencode release |

opencode never fetches `$schema`; it's only used by editors for validation and completion. Pointing it here has no
effect on how opencode loads the config.

The schema validates **native v2** fields only. Files that still use v1 syntax (`agent`, `provider`, `permission`, …)
load fine in opencode v2, but they won't validate. Keep `https://opencode.ai/config.json` for those.

## Generating

```sh
scripts/generate.sh            # latest stable v2.* tag of anomalyco/opencode
scripts/generate.sh v2.0.26    # a specific tag
```

The script clones the tag and runs `Schema.toJsonSchemaDocument(Config.Info)` from `packages/schema` with Bun (fetched
via `npx`). This is the same logic as the upstream PR. It writes `<tag>/config.json`, and also `v2/config.json` if
`<tag>` is the newest version here. Requires `git`, `node`/`npx`.

## Fixing a schema

URLs are stable, so fixes go in place: adjust `scripts/config-schema.ts` (or the generated file), regenerate the
affected tag, commit and push. GitHub Pages redeploys and the change is live within about 10 minutes.
