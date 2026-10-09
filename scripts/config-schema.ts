// Adapted from anomalyco/opencode#51804 (packages/schema/script/config-schema.ts).
// Run from <opencode checkout>/packages/schema/script/: bun config-schema.ts <out> <id>
import { Schema } from "effect"
import { Config } from "../src/config.js"

const [target, id] = process.argv.slice(2)
if (!target || !id) throw new Error("Usage: config-schema.ts <out> <id>")

const document = Schema.toJsonSchemaDocument(Config.Info)
const content = `${JSON.stringify(
  {
    $schema: "https://json-schema.org/draft/2020-12/schema",
    $id: id,
    ...document.schema,
    ...(Object.keys(document.definitions).length ? { $defs: document.definitions } : {}),
  },
  null,
  2,
)}\n`

await Bun.write(target, content)
