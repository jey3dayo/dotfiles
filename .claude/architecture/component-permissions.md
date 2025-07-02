# Component-Specific Claude Permissions

This document explains how to manage Claude permissions for different project components and development contexts.

## 🎯 Permission Management Strategy

### Why Distributed Permissions?

- **Principle of Least Privilege**: Each component holds only the minimum required permissions
- **Security Boundaries**: Isolate permissions between different components/projects
- **Maintainability**: Limit impact scope when changing permissions
- **Context-Specific**: Different projects need different tool access patterns

## 📂 Component-Based Permission Patterns

### Shell Environment Permissions

**Target**: Shell configuration, plugin management, performance optimization
**Common Tools**: zsh, bash, sheldon, mise, brew

```json
{
  "permissions": {
    "allow": [
      "Bash(sheldon *)",
      "Bash(zsh *)",
      "Bash(source *)",
      "Bash(mise *)",
      "Bash(brew *)",
      "Bash(abbr *)",
      "Bash(alias *)",
      "Bash(echo *)",
      "Bash(which *)",
      "Bash(type *)"
    ]
  }
}
```

### Terminal/Editor Permissions

**Target**: Terminal emulators, text editors, multiplexers
**Common Tools**: wezterm, alacritty, tmux, nvim, vim

```json
{
  "permissions": {
    "allow": [
      "Bash(wezterm *)",
      "Bash(alacritty *)",
      "Bash(tmux *)",
      "Bash(nvim *)",
      "Bash(vim *)",
      "Bash(lua *)"
    ]
  }
}
```

### Development Environment Permissions

**Target**: Programming languages, package managers, build tools
**Common Tools**: node, python, rust, go, docker

```json
{
  "permissions": {
    "allow": [
      "Bash(node *)",
      "Bash(npm *)",
      "Bash(yarn *)",
      "Bash(pnpm *)",
      "Bash(python *)",
      "Bash(pip *)",
      "Bash(cargo *)",
      "Bash(go *)",
      "Bash(docker *)",
      "Bash(make *)"
    ]
  }
}
```

### Git/Version Control Permissions

**Target**: Version control operations, repository management
**Common Tools**: git, gh, hub

```json
{
  "permissions": {
    "allow": ["Bash(git *)", "Bash(gh *)", "Bash(hub *)"]
  }
}
```

## 🔧 Permission Configuration Patterns

### Basic Template Structure

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": ["Bash(command pattern)", "WebFetch(domain:allowed-domain.com)"],
    "deny": ["Bash(dangerous-command *)"]
  },
  "model": "sonnet",
  "cleanupPeriodDays": 7
}
```

### Progressive Permission Levels

#### Level 1: Read-Only

```json
{
  "permissions": {
    "allow": [
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(find *)",
      "Bash(head *)",
      "Bash(tail *)"
    ]
  }
}
```

#### Level 2: Configuration Management

```json
{
  "permissions": {
    "allow": [
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(find *)",
      "Bash(mv *)",
      "Bash(cp *)",
      "Bash(ln *)",
      "Bash(mkdir *)",
      "Bash(touch *)"
    ]
  }
}
```

#### Level 3: Full Development

```json
{
  "permissions": {
    "allow": [
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(find *)",
      "Bash(mv *)",
      "Bash(cp *)",
      "Bash(ln *)",
      "Bash(mkdir *)",
      "Bash(rm *)",
      "Bash(chmod *)",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(docker *)"
    ]
  }
}
```

## 🚫 Security Considerations

### Prohibited Patterns

```json
{
  "permissions": {
    "deny": [
      "Bash(sudo *)",
      "Bash(su *)",
      "Bash(rm -rf /*)",
      "Bash(dd *)",
      "Bash(mkfs *)",
      "Bash(fdisk *)",
      "Bash(shutdown *)",
      "Bash(reboot *)",
      "Bash(systemctl *)",
      "Bash(service *)",
      "Bash(iptables *)",
      "Bash(ufw *)"
    ]
  }
}
```

### Recommended Patterns

- **Specific Commands**: Use specific command patterns rather than wildcards
- **Path Restrictions**: Limit operations to specific directories when possible
- **Tool-Specific**: Grant permissions only for tools actually used in the project
- **Regular Review**: Periodically review and clean up unused permissions

## 📋 Permission Management Workflow

### Adding New Permissions

1. **Assess Necessity**: Can the goal be achieved with existing permissions?
2. **Define Specifically**: Avoid broad permissions; be as specific as possible
3. **Test Thoroughly**: Verify the permission works as expected
4. **Document Usage**: Record why the permission was added

### Removing/Changing Permissions

1. **Impact Assessment**: Understand what functionality might be affected
2. **Gradual Changes**: Don't remove many permissions at once
3. **Backup Configuration**: Keep a backup of the working configuration
4. **Monitor Results**: Watch for any issues after changes

## 📝 Project-Specific Examples

### Web Development Project

```json
{
  "permissions": {
    "allow": [
      "Bash(node *)",
      "Bash(npm *)",
      "Bash(npx *)",
      "Bash(yarn *)",
      "Bash(pnpm *)",
      "Bash(git *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "WebFetch(domain:nodejs.org)",
      "WebFetch(domain:npmjs.com)",
      "WebFetch(domain:github.com)"
    ]
  }
}
```

### System Administration Project

```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)",
      "Bash(docker-compose *)",
      "Bash(kubectl *)",
      "Bash(terraform *)",
      "Bash(ansible *)",
      "Bash(ssh *)",
      "Bash(ping *)",
      "Bash(nc *)",
      "Bash(curl *)"
    ]
  }
}
```

### Data Science Project

```json
{
  "permissions": {
    "allow": [
      "Bash(python *)",
      "Bash(python3 *)",
      "Bash(pip *)",
      "Bash(pip3 *)",
      "Bash(jupyter *)",
      "Bash(conda *)",
      "Bash(pipenv *)",
      "Bash(poetry *)"
    ]
  }
}
```

## 💡 Best Practices

### Successful Patterns

- **Component Isolation**: Separate permissions for different project components
- **Minimal Access**: Grant only the permissions actually needed
- **Explicit Allow**: Clearly define what operations are permitted
- **Path Limitations**: Restrict operations to specific directories when possible
- **Regular Cleanup**: Remove unused permissions periodically

### Patterns to Avoid

- **Broad Wildcards**: Using `*` for wide-ranging permissions
- **Duplicate Permissions**: Setting the same permissions across multiple components
- **Unused Permissions**: Keeping permissions for tools no longer used
- **Security Holes**: Allowing dangerous operations without proper justification

## 🔍 Permission Testing

### Validation Checklist

- [ ] All necessary operations work with current permissions
- [ ] No unnecessary permissions are granted
- [ ] Security-sensitive operations are properly restricted
- [ ] Permissions are documented and justified
- [ ] Regular review schedule is established

### Testing Commands

```bash
# Test basic file operations
ls -la
cat file.txt
grep "pattern" file.txt

# Test tool-specific operations
git status
npm --version
docker --version

# Test restricted operations (should fail)
sudo ls
rm -rf /
```

---

_Last Updated: 2025-06-28_
_Status: Global Template - Applicable across projects_
