# Zsh Configuration

High-performance Zsh configuration with 1.1s startup time (43% improvement) and modular plugin system.

## ✨ Key Features

- **🚀 Performance**: 1.8s → 1.1s startup (43% improvement)
- **📦 Plugin Management**: Sheldon with 6-tier priority loading
- **⚡ Optimization**: mise lazy loading (-39.88ms critical improvement)
- **🔍 Git Integration**: Custom widgets and 50+ abbreviations
- **🔎 FZF Integration**: Repository, file, and process search
- **📚 Help System**: Comprehensive `zsh-help` command

## 📈 Performance Metrics

| Optimization          | Improvement      | Impact         |
| --------------------- | ---------------- | -------------- |
| Overall startup       | 1.8s → 1.1s      | 43% faster     |
| mise ultra-defer      | Complete defer   | Critical       |
| brew optimization     | Minimal env      | High impact    |
| 6-tier plugin loading | Optimized timing | Smooth startup |
| File compilation      | All .zsh files   | Runtime speed  |
| Code cleanup          | ~19MB removed    | Storage/speed  |

## 🏗️ Architecture

### Modular Design

```
zsh/
├── config/
│   ├── loader.zsh         # Main loader system
│   ├── 01-environment.zsh # Environment variables
│   ├── 02-plugins.zsh     # Plugin configuration
│   ├── 03-aliases.zsh     # Aliases and abbreviations
│   ├── 04-functions.zsh   # Custom functions
│   ├── 05-bindings.zsh    # Key bindings
│   └── 06-completions.zsh # Completion settings
├── sheldon.toml           # Plugin management
└── .zshrc                 # Main entry point
```

### 6-Tier Plugin Loading

1. **Essential**: Core functionality (zsh-autosuggestions)
2. **Completion**: Tab completion enhancements
3. **Navigation**: Directory and file navigation
4. **Git**: Version control integration
5. **Utility**: Development tools and helpers
6. **Theme**: Prompt and visual elements

## 🎮 Essential Commands

### Help System

```bash
zsh-help                    # Comprehensive help
zsh-help keybinds          # Key bindings reference
zsh-help aliases           # Abbreviations list (50+)
zsh-help tools             # Installed tools check
```

### Performance Tools

```bash
zsh-benchmark              # Startup time measurement
zsh-profile                # Detailed profiling
```

### Git Workflow (Widgets)

```bash
^]                         # FZF ghq repository selector
^[                         # FZF branch/worktree navigator
^g^g                       # Git diff widget
^g^s                       # Git status widget
^g^a                       # Git add widget
^g^b                       # Git branch/worktree widget
^g^K                       # FZF kill process
```

### FZF Integration

```bash
^R                         # History search
^T                         # File search
^]                         # Repository search (ghq)
```

## 🔧 Configuration Features

### Abbreviations (50+)

```bash
# Git shortcuts
g      → git
ga     → git add
gc     → git commit
gp     → git push
gl     → git pull
gst    → git status
gco    → git checkout

# Directory navigation
..     → cd ..
...    → cd ../..
....   → cd ../../..

# Common commands
ll     → ls -la
la     → ls -A
l      → ls -CF
```

### Environment Optimizations

- **Lazy mise loading**: Deferred until first use
- **Conditional loading**: Tools load only if available
- **Path optimization**: Efficient PATH management
- **Cache utilization**: Command completion caching

### Custom Functions

```bash
mkcd()          # Create directory and cd into it
gco()           # FZF git checkout
ghq-fzf()       # Repository selector
kill-fzf()      # Process killer with preview
```

## 📊 Plugin Ecosystem

### Core Plugins (Tier 1-2)

- **zsh-autosuggestions**: Command suggestions
- **zsh-syntax-highlighting**: Syntax coloring
- **zsh-completions**: Enhanced completions
- **fzf-tab**: FZF-powered tab completion

### Development Plugins (Tier 3-4)

- **zsh-abbr**: Abbreviation expansion
- **forgit**: Interactive git operations
- **zsh-you-should-use**: Alias reminders

### Theme & UI (Tier 5-6)

- **starship**: Cross-shell prompt
- **zsh-notify**: Command completion notifications

## 🔍 Debug & Profiling

### Performance Analysis

```bash
# Enable profiling
zmodload zsh/zprof

# Source configuration
source ~/.zshrc

# View profile
zprof

# Benchmark specific operations
time zsh -i -c exit
```

### Debugging Commands

```bash
# Check plugin loading
sheldon lock

# Verify tool availability
zsh-help tools

# Examine PATH
echo $PATH | tr ':' '\n'

# Check environment
printenv | grep -E '^(EDITOR|SHELL|TERM)'
```

## ⚙️ Customization

### Local Configuration

Create `~/.zshrc.local` for machine-specific settings:

```bash
# Private aliases
alias work="cd ~/work"

# Local environment variables
export CUSTOM_VAR="value"

# Machine-specific optimizations
if [[ $(hostname) == "work-machine" ]]; then
    # Work-specific settings
fi
```

### Plugin Management

```bash
# Add new plugin
echo 'github = "user/repo"' >> sheldon.toml

# Update plugins
sheldon lock --update

# Remove plugin
# Edit sheldon.toml and run sheldon lock
```

## 🚀 Optimization Tips

### Startup Speed

1. **Profile regularly**: Use `zsh-benchmark` weekly
2. **Lazy load**: Defer heavy tools (mise, nvm, etc.)
3. **Compile files**: Ensure all .zsh files are compiled
4. **Plugin audit**: Remove unused plugins quarterly

### Memory Usage

1. **History limits**: Set reasonable HISTSIZE
2. **Completion cache**: Clear periodically
3. **Plugin cleanup**: Remove redundant functionality

### Workflow Efficiency

1. **Learn abbreviations**: Master the 50+ shortcuts
2. **Use widgets**: Git widgets save keystrokes
3. **FZF everything**: File, repo, process selection
4. **Help system**: `zsh-help` for quick reference

## 📋 Maintenance

### Regular Tasks

```bash
# Weekly performance check
zsh-benchmark

# Monthly plugin updates
sheldon lock --update

# Quarterly cleanup
zsh-help tools  # Check for unused tools
```

### Troubleshooting

```bash
# Reset completions
rm -rf ~/.zcompdump*
compinit

# Check for conflicts
zsh -df  # Start with minimal config

# Verify plugin status
sheldon source
```

---

_Optimized for speed, functionality, and developer experience._
