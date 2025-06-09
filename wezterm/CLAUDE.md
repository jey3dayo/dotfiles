# WezTerm Configuration - Claude Context

## 🎯 Overview

Alternative terminal emulator with Lua-based configuration for enhanced terminal experience. Provides a fallback option to Alacritty with similar performance and additional features.

## 📊 Current Status (2025-06-09)

### ✅ Completed Components

#### 🏗️ Architecture
- **Configuration**: Modular Lua-based system
- **Platform**: Cross-platform (macOS/Windows) with platform-specific configs
- **Performance**: GPU-accelerated rendering with WebGpu backend

#### 🎨 Visual Design
- **Theme**: Gruvbox dark theme with custom tab styling
- **Font**: UDEV Gothic 35NFLG (16pt) with Nerd Font fallbacks
- **Transparency**: 92% opacity for modern glass effect
- **Layout**: Bottom tab bar with custom arrow styling

## 🏗️ Architecture

### File Structure
```
wezterm/
├── wezterm.lua      # Main configuration entry point
├── ui.lua           # Visual theming and tab styling
├── keybinds.lua     # Key bindings and input handling
├── utils.lua        # Utility functions
├── os.lua           # Platform-specific configuration loader
└── win.lua          # Windows-specific settings (WSL support)
```

### Module System
- **Modular Design**: Each aspect separated into focused modules
- **Platform Detection**: Automatic Windows/macOS configuration switching
- **Utility Functions**: Shared helpers for path manipulation and string handling

## 🎮 Key Bindings

### Leader Key System
- **Leader**: `Ctrl+x` (tmux-style)
- **Tab Management**: Leader + c/n/p for create/next/prev
- **Pane Operations**: Leader + split/zoom/rotate commands
- **Copy Mode**: Leader + [ for vim-like text selection

### Direct Bindings
- **Tab Navigation**: Alt+Tab/Shift+Tab for tab switching
- **Pane Navigation**: Alt+hjkl for directional movement
- **Pane Resizing**: Alt+Shift+Ctrl+hjkl for size adjustment
- **Font Size**: Ctrl+plus/minus for zoom

### Copy Mode (Vim-style)
- **Movement**: hjkl for cursor movement
- **Word Movement**: w/b/e for word navigation
- **Selection**: v for visual mode, V for line selection
- **Copy**: y to copy and exit, yy for line copy
- **Search**: / for search, n/N for navigation

## 🎨 UI Configuration

### Color Scheme
```lua
color_scheme = "Gruvbox dark, hard (base16)"
-- Custom tab colors with arrow styling
TAB_BAR_BG = "#222"
ACTIVE_TAB_BG = "#778AC5"
NORMAL_TAB_BG = "#191f26"
```

### Typography
```lua
font = "UDEV Gothic 35NFLG"
font_size = 16
-- Fallback chain includes Inconsolata Nerd Font and Emoji support
```

### Window Settings
```lua
window_background_opacity = 0.92
window_decorations = "RESIZE"  -- Minimal chrome
native_macos_fullscreen_mode = true
initial_cols = 180
initial_rows = 50
```

## 🔧 Advanced Features

### Tab Styling
- **Custom Arrows**: Unicode right arrows for tab separators
- **Dynamic Titles**: Process name or working directory display
- **Hover Effects**: Bold text and color changes
- **New Tab Button**: Styled with consistent theme

### GPU Acceleration
```lua
webgpu_preferred_adapter = gpus[1]
front_end = "WebGpu"
```

### Platform Support
- **macOS**: Full native integration with proper decorations
- **Windows**: WSL Ubuntu integration with proper environment
- **Input Method**: IME support for international keyboards

## 🛠️ Utility Functions

### Path Manipulation
- `convert_home_dir()`: Replace home directory with ~
- `basename()`: Extract filename from path
- `convert_useful_path()`: Combine home conversion with basename

### Table Operations
- `object_assign()`: Merge configuration objects
- `array_concat()`: Concatenate arrays with nested support
- `merge_tables()`: Deep merge for complex configurations

### Font Handling
- `font_with_fallback()`: Create font chain with Nerd Font support
- Emoji support through Noto Color Emoji

## 📈 Performance

### Startup Optimization
- **Lazy Loading**: Minimal initial configuration
- **GPU Rendering**: Hardware acceleration for smooth scrolling
- **Memory Management**: Efficient buffer handling

### Resource Usage
- **CPU**: Low impact with GPU offloading
- **Memory**: Moderate usage with tab multiplexing
- **Battery**: Optimized for laptop usage

## 🔗 Integration Points

### Shell Integration
- **Working Directory**: Automatic detection and display
- **Process Names**: Show running command in tab titles
- **Environment**: Proper variable passing

### Cross-Platform
- **WSL Support**: Seamless Linux environment on Windows
- **macOS Native**: Full platform feature support
- **Font Consistency**: Cross-platform font selection

## 🚀 Advanced Configuration

### Key Table System
```lua
-- Resize mode with timeout
resize_pane = {
  timeout_milliseconds = 3000,
  one_shot = false,
}

-- Copy mode with vim bindings
copy_mode = {
  -- Full vim-style navigation and selection
}
```

### Mouse Bindings
- **Left Click**: Primary selection
- **Right Click**: Clipboard
- **Cmd/Ctrl+Click**: Link opening

## 🔧 Customization Notes

### TODO Items
```lua
-- TODO: いつかtrueにする
disable_default_key_bindings = false
```

### Platform Conditionals
```lua
if wezterm.target_triple:find "windows" then
  keys = utils.array_concat(keys, windows_keybinds)
end
```

## 📋 Maintenance

### Regular Updates
- Monitor WezTerm releases for new features
- Update GPU adapter selection as needed
- Adjust font sizes for display changes

### Performance Monitoring
- GPU usage tracking
- Startup time measurement
- Memory consumption monitoring

## 🎯 Use Cases

### Primary Scenarios
1. **Development**: Alternative to Alacritty with more features
2. **Windows Development**: WSL integration for Linux workflows
3. **Multi-platform**: Consistent experience across systems
4. **Tab Management**: Heavy multitasking with visual feedback

### Integration Benefits
- **Tmux Compatibility**: Leader key system matches tmux
- **Vim Workflows**: Copy mode mirrors vim navigation
- **Modern UI**: Visual feedback with transparency effects

---

*Last Updated: 2025-06-09*
*Status: Alternative Terminal (Feature Complete)*