#!/usr/bin/env node
/**
 * TSR Configuration Loader
 *
 * Cascading configuration resolution:
 * 1. Project root: .tsr-config.json (highest priority)
 * 2. Home directory: ~/.config/tsr/config.json
 * 3. Global default: tsr-config.default.json (lowest priority)
 *
 * Usage:
 *   const config = await loadTsrConfig('/path/to/project');
 */

import * as fs from 'fs/promises'
import * as path from 'path'
import * as os from 'os'
import { fileURLToPath } from 'url'
import { dirname } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

export interface TsrConfig {
  version: string
  tsconfig: string
  ignoreFile: string
  entryPatterns: string[]
  maxDeletionPerRun: number
  includeDts: boolean
  recursive: boolean
  ignorePatterns: string[]
  verification: {
    typeCheck: boolean
    lint: boolean
    test: boolean
  }
  reporting: {
    outputPath: string
    verbose: boolean
  }
  framework: {
    type: 'nextjs' | 'react' | 'node' | 'custom'
    nextjs?: {
      appRouter?: boolean
      pagesRouter?: boolean
    }
  }
}

export interface ResolvedConfig extends TsrConfig {
  projectRoot: string
  configSource: 'project' | 'home' | 'default'
  resolvedPaths: {
    tsconfig: string
    ignoreFile: string
    outputPath: string
  }
}

/**
 * Load TSR configuration with cascading strategy
 */
export async function loadTsrConfig(projectRoot: string): Promise<ResolvedConfig> {
  const defaultConfig = await loadDefaultConfig()
  const homeConfig = await loadHomeConfig()
  const projectConfig = await loadProjectConfig(projectRoot)

  // Merge configs (project > home > default)
  const mergedConfig: TsrConfig = {
    ...defaultConfig,
    ...homeConfig,
    ...projectConfig,
    verification: {
      ...defaultConfig.verification,
      ...homeConfig?.verification,
      ...projectConfig?.verification,
    },
    reporting: {
      ...defaultConfig.reporting,
      ...homeConfig?.reporting,
      ...projectConfig?.reporting,
    },
    framework: {
      ...defaultConfig.framework,
      ...homeConfig?.framework,
      ...projectConfig?.framework,
      nextjs: {
        ...defaultConfig.framework.nextjs,
        ...homeConfig?.framework?.nextjs,
        ...projectConfig?.framework?.nextjs,
      },
    },
  }

  // Resolve absolute paths
  const resolvedPaths = {
    tsconfig: path.resolve(projectRoot, mergedConfig.tsconfig),
    ignoreFile: path.resolve(projectRoot, mergedConfig.ignoreFile),
    outputPath: resolveOutputPath(mergedConfig.reporting.outputPath),
  }

  // Determine config source
  const configSource: 'project' | 'home' | 'default' = projectConfig
    ? 'project'
    : homeConfig
      ? 'home'
      : 'default'

  return {
    ...mergedConfig,
    projectRoot,
    configSource,
    resolvedPaths,
  }
}

/**
 * Load default configuration
 */
async function loadDefaultConfig(): Promise<TsrConfig> {
  const defaultConfigPath = path.join(__dirname, 'tsr-config.default.json')
  const content = await fs.readFile(defaultConfigPath, 'utf-8')
  return JSON.parse(content)
}

/**
 * Load home directory configuration
 */
async function loadHomeConfig(): Promise<Partial<TsrConfig> | null> {
  const homeConfigPath = path.join(os.homedir(), '.config', 'tsr', 'config.json')

  try {
    const content = await fs.readFile(homeConfigPath, 'utf-8')
    return JSON.parse(content)
  } catch {
    return null
  }
}

/**
 * Load project-specific configuration
 */
async function loadProjectConfig(projectRoot: string): Promise<Partial<TsrConfig> | null> {
  const projectConfigPath = path.join(projectRoot, '.tsr-config.json')

  try {
    const content = await fs.readFile(projectConfigPath, 'utf-8')
    return JSON.parse(content)
  } catch {
    return null
  }
}

/**
 * Resolve output path with date template
 */
function resolveOutputPath(outputPath: string): string {
  const date = new Date().toISOString().split('T')[0].replace(/-/g, '')
  return outputPath.replace('{date}', date)
}

/**
 * Validate configuration against schema
 */
export function validateConfig(config: TsrConfig): {
  valid: boolean
  errors: string[]
} {
  const errors: string[] = []

  if (!config.version) {
    errors.push('Missing required field: version')
  }

  if (!config.entryPatterns || config.entryPatterns.length === 0) {
    errors.push('entryPatterns must contain at least one pattern')
  }

  if (config.maxDeletionPerRun < 1) {
    errors.push('maxDeletionPerRun must be at least 1')
  }

  if (!['nextjs', 'react', 'node', 'custom'].includes(config.framework.type)) {
    errors.push('framework.type must be one of: nextjs, react, node, custom')
  }

  return {
    valid: errors.length === 0,
    errors,
  }
}

/**
 * Generate .tsrignore content based on framework configuration
 */
export async function generateTsrIgnore(config: ResolvedConfig): Promise<string> {
  const lines: string[] = [
    '# TSR (TypeScript React) Ignore Patterns',
    '# Auto-generated based on framework configuration',
    '# Last updated: ' + new Date().toISOString(),
    '',
  ]

  // Common patterns
  lines.push('# === Configuration Files ===')
  lines.push('*.config.ts')
  lines.push('*.config.js')
  lines.push('*.config.mjs')
  lines.push('middleware.ts')
  lines.push('next-env.d.ts')
  lines.push('')

  // Framework-specific patterns
  if (config.framework.type === 'nextjs') {
    lines.push('# === Next.js Specific ===')

    if (config.framework.nextjs?.appRouter) {
      lines.push('# App Router (Next.js 13+)')
      lines.push('src/app/**/page.tsx')
      lines.push('src/app/**/layout.tsx')
      lines.push('src/app/**/loading.tsx')
      lines.push('src/app/**/error.tsx')
      lines.push('src/app/**/not-found.tsx')
      lines.push('src/app/**/template.tsx')
      lines.push('src/app/api/**/*.ts')
      lines.push('src/app/**/route.ts')
      lines.push('')
    }

    if (config.framework.nextjs?.pagesRouter) {
      lines.push('# Pages Router')
      lines.push('pages/**/*.tsx')
      lines.push('pages/**/*.ts')
      lines.push('pages/api/**/*.ts')
      lines.push('pages/_app.tsx')
      lines.push('pages/_document.tsx')
      lines.push('')
    }
  }

  // Test patterns
  lines.push('# === Test Files ===')
  lines.push('*.test.ts')
  lines.push('*.test.tsx')
  lines.push('*.spec.ts')
  lines.push('*.spec.tsx')
  lines.push('src/tests/**')
  lines.push('src/mocks/**')
  lines.push('*.stories.ts')
  lines.push('*.stories.tsx')
  lines.push('')

  // Type definitions
  lines.push('# === Type Definitions ===')
  lines.push('*.d.ts')
  lines.push('**/types.ts')
  lines.push('*.types.ts')
  lines.push('')

  // Build artifacts
  lines.push('# === Build Artifacts ===')
  lines.push('.next/**')
  lines.push('dist/**')
  lines.push('out/**')
  lines.push('build/**')
  lines.push('node_modules/**')
  lines.push('')

  // Custom patterns
  if (config.ignorePatterns.length > 0) {
    lines.push('# === Custom Patterns ===')
    lines.push(...config.ignorePatterns)
    lines.push('')
  }

  return lines.join('\n')
}

/**
 * Save configuration to project root
 */
export async function saveProjectConfig(
  projectRoot: string,
  config: Partial<TsrConfig>
): Promise<void> {
  const configPath = path.join(projectRoot, '.tsr-config.json')
  const content = JSON.stringify(config, null, 2)
  await fs.writeFile(configPath, content, 'utf-8')
}

/**
 * CLI helper: Display configuration
 */
export async function displayConfig(projectRoot: string): Promise<void> {
  const config = await loadTsrConfig(projectRoot)

  console.log('TSR Configuration')
  console.log('='.repeat(50))
  console.log(`Project Root: ${config.projectRoot}`)
  console.log(`Config Source: ${config.configSource}`)
  console.log('')
  console.log('Resolved Paths:')
  console.log(`  tsconfig: ${config.resolvedPaths.tsconfig}`)
  console.log(`  ignoreFile: ${config.resolvedPaths.ignoreFile}`)
  console.log(`  outputPath: ${config.resolvedPaths.outputPath}`)
  console.log('')
  console.log('Settings:')
  console.log(`  Framework: ${config.framework.type}`)
  console.log(`  Max Deletion: ${config.maxDeletionPerRun}`)
  console.log(`  Include .d.ts: ${config.includeDts}`)
  console.log(`  Recursive: ${config.recursive}`)
  console.log('')
  console.log('Verification:')
  console.log(`  Type Check: ${config.verification.typeCheck}`)
  console.log(`  Lint: ${config.verification.lint}`)
  console.log(`  Test: ${config.verification.test}`)
  console.log('='.repeat(50))
}

// CLI entry point
// Note: ES module doesn't have require.main, use import.meta.url check instead
if (import.meta.url === `file://${process.argv[1]}`) {
  const projectRoot = process.cwd()
  displayConfig(projectRoot).catch(console.error)
}
