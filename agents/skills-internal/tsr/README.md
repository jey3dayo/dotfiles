# TSR Plugin - TypeScript/React Dead Code Detection and Removal

A flexible plugin for detecting and removing unused TypeScript/React code with a cascading configuration system.

## Features

- Cascading configuration system (project > home > default)
- Framework-specific detection (Next.js, React, Node.js)
- Automatic `.tsrignore` generation based on framework
- Configurable verification (type-check, lint, test)
- Safe deletion with configurable limits
- Date-templated report output

## Quick Start

### 1. Installation

```bash
cd /path/to/your/project
npm install --save-dev tsr
```

### 2. Setup Configuration

```bash
# Copy appropriate template
cp examples/nextjs-app-router.json .tsr-config.json

# Or use the setup script
./setup-tsr.sh
```

### 3. Run TSR

```bash
# Check for dead code
pnpm tsr:check

# Remove dead code
pnpm tsr:fix
```

## Configuration System

### Configuration Priority (Cascading)

1. **Project Root** (highest): `.tsr-config.json`
2. **Home Directory**: `~/.config/tsr/config.json`
3. **Default** (lowest): `tsr-config.default.json`

### Configuration Files

See `examples/` directory for ready-to-use templates:

- `nextjs-app-router.json` - Next.js 13+ with App Router
- `nextjs-pages-router.json` - Next.js with Pages Router
- `react-app.json` - Standalone React application
- `nodejs-app.json` - Node.js application
- `home-config.json` - Global user configuration

### View Current Configuration

```bash
node config-loader.ts
```

## Directory Structure

```
tsr/
├── README.md                     # This file
├── SKILL.md                      # Skill definition
├── config-loader.ts              # Configuration loader
├── tsr-config.schema.json        # JSON schema
├── tsr-config.default.json       # Default configuration
├── examples/                     # Configuration templates
│   ├── README.md
│   ├── nextjs-app-router.json
│   ├── nextjs-pages-router.json
│   ├── react-app.json
│   ├── nodejs-app.json
│   └── home-config.json
└── references/                   # Documentation
    ├── workflow.md               # Workflow guide
    ├── tsrignore.md              # .tsrignore guide
    └── examples.md               # Usage examples
```

## Usage Examples

### Basic Workflow

```bash
# 1. Check configuration
node config-loader.ts

# 2. Detect dead code
pnpm tsr:check > /tmp/tsr-report.txt

# 3. Review report
cat /tmp/tsr-report.txt

# 4. Remove dead code (limited by maxDeletionPerRun)
pnpm tsr:fix

# 5. Automatic verification runs based on config
```

### Project-Specific Configuration

```json
{
  "version": "1.0.0",
  "maxDeletionPerRun": 20,
  "framework": {
    "type": "nextjs",
    "nextjs": {
      "appRouter": true,
      "pagesRouter": false
    }
  },
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": false
  }
}
```

### Global User Configuration

Create `~/.config/tsr/config.json`:

```json
{
  "verification": {
    "typeCheck": true,
    "lint": true,
    "test": true
  },
  "reporting": {
    "outputPath": "~/tsr-reports/tsr-{date}.txt",
    "verbose": true
  }
}
```

## Integration

### package.json Scripts

```json
{
  "scripts": {
    "tsr:check": "tsr 'src/.*\\.(ts|tsx)$'",
    "tsr:fix": "tsr -w 'src/.*\\.(ts|tsx)$'",
    "tsr:config": "node config-loader.ts"
  }
}
```

### GitHub Actions

See `references/workflow.md` for CI/CD integration examples.

## Documentation

- **SKILL.md**: Complete skill documentation
- **references/workflow.md**: Detailed workflow guide
- **references/tsrignore.md**: .tsrignore configuration
- **references/examples.md**: Real-world usage examples
- **examples/README.md**: Configuration templates guide

## Configuration Schema

See `tsr-config.schema.json` for the complete JSON schema definition.

### Key Configuration Fields

| Field                  | Type    | Default                      | Description                                   |
| ---------------------- | ------- | ---------------------------- | --------------------------------------------- |
| `maxDeletionPerRun`    | number  | 10                           | Maximum items to delete per run               |
| `includeDts`           | boolean | false                        | Include .d.ts files in analysis               |
| `recursive`            | boolean | false                        | Enable recursive deletion mode                |
| `verification.*`       | object  | {typeCheck, lint, test}      | Automatic verification after deletion         |
| `reporting.outputPath` | string  | "/tmp/tsr-report-{date}.txt" | Report output path (supports {date} template) |
| `framework.type`       | string  | "nextjs"                     | Framework type (nextjs\|react\|node\|custom)  |

## Migration from Old Setup

If you have existing TSR configuration without the new config system:

1. Copy your project to use the new structure
2. Create `.tsr-config.json` from an example template
3. Migrate `.tsrignore` patterns to the config file's `ignorePatterns` field (optional)
4. Test with `node config-loader.ts` to verify configuration

## Troubleshooting

### Configuration Not Loading

```bash
# Check file exists and is valid JSON
cat .tsr-config.json | jq .

# Verify permissions
chmod 644 .tsr-config.json

# Display current config
node config-loader.ts
```

### Verification Not Running

```bash
# Check verification settings
node config-loader.ts | grep -A 5 "Verification"

# Enable verification in config
vim .tsr-config.json
```

### Reports in Wrong Location

```bash
# Check resolved paths
node config-loader.ts | grep "outputPath"

# Adjust in project config
vim .tsr-config.json
```

## Contributing

See the main marketplace repository for contribution guidelines.

## License

See the main marketplace repository for license information.
