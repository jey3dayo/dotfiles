# TSR Configuration Examples

This directory contains example configuration files for different project types.

## Usage

Copy the appropriate example to your project root as `.tsr-config.json`:

```bash
# Next.js with App Router
cp examples/nextjs-app-router.json .tsr-config.json

# Next.js with Pages Router
cp examples/nextjs-pages-router.json .tsr-config.json

# React application
cp examples/react-app.json .tsr-config.json

# Node.js application
cp examples/nodejs-app.json .tsr-config.json

# Home directory config (applies to all projects)
mkdir -p ~/.config/tsr
cp examples/home-config.json ~/.config/tsr/config.json
```

## Configuration Files

### nextjs-app-router.json

Configuration for Next.js 13+ projects using App Router.

- Framework: Next.js App Router
- Entry patterns: `src/.*\.(ts|tsx)$`
- Max deletion: 10 items per run
- Verification: type-check + lint (no tests)
- Custom ignore patterns for debug directories

### nextjs-pages-router.json

Configuration for Next.js projects using Pages Router.

- Framework: Next.js Pages Router
- Entry patterns: `src/.*\.(ts|tsx)$`, `pages/.*\.(ts|tsx)$`
- Max deletion: 10 items per run
- Verification: type-check + lint (no tests)
- Ignores API routes and Next.js special files

### react-app.json

Configuration for standalone React applications (Create React App, Vite, etc.).

- Framework: React
- Entry patterns: `src/.*\.(ts|tsx)$`
- Max deletion: 15 items per run
- Verification: type-check + lint + test
- Ignores test setup files

### nodejs-app.json

Configuration for Node.js applications.

- Framework: Node.js
- Entry patterns: `src/.*\.ts$` (TypeScript only, no TSX)
- Max deletion: 10 items per run
- Verification: type-check + lint + test
- Ignores scripts and migrations

### home-config.json

Global configuration for all projects (place in `~/.config/tsr/config.json`).

- Shared verification settings
- Custom report output location
- Verbose logging enabled
- Default max deletion limit

## Customization

Edit the configuration files to match your project structure:

1. **Entry Patterns**: Adjust regex patterns to match your source directory structure
2. **Max Deletion**: Set higher values for more aggressive cleanup
3. **Verification**: Enable/disable type-check, lint, test based on your workflow
4. **Ignore Patterns**: Add project-specific paths to ignore
5. **Framework**: Set the correct framework type and options

## Cascading Priority

Configuration files are merged in this order (highest to lowest priority):

1. Project root: `.tsr-config.json`
2. Home directory: `~/.config/tsr/config.json`
3. Default: `tsr-config.default.json`

Later configurations override earlier ones, with deep merging for nested objects.

## Verification

After creating your configuration, verify it:

```bash
node config-loader.ts
```

This will display the resolved configuration with all merged settings.
