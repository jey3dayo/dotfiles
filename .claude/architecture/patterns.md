# Global Architecture Patterns - Universal Design Principles

This document defines reusable architecture patterns, principles, and best practices that can be applied across different codebases and projects.

## 🏗️ Core Architecture Principles

### 1. Modular Design

- **Separation of Concerns**: Each module handles a single responsibility
- **Loose Coupling**: Minimize dependencies between components
- **High Cohesion**: Related functionality grouped together
- **Interface-Driven**: Well-defined APIs between modules

### 2. Performance-First Approach

- **Lazy Loading**: Load resources only when needed
- **Caching Strategies**: Implement appropriate caching at multiple levels
- **Resource Optimization**: Minimize memory and CPU usage
- **Measurement-Driven**: All optimizations should be measured

### 3. Configuration Management

- **Environment-Specific**: Support for dev/staging/prod environments
- **Hierarchical Loading**: default → environment → local overrides
- **Validation**: Validate configuration at startup
- **Documentation**: All config options should be documented

## 📁 Directory Structure Patterns

### Standard Project Layout

```
project/
├── .claude/                    # AI assistance configuration
│   ├── layers/                # Knowledge layer management
│   ├── architecture/          # Architecture documentation
│   ├── commands/              # Custom commands
│   └── settings.json          # Project-specific settings
├── src/                       # Source code
│   ├── core/                  # Core functionality
│   ├── modules/               # Feature modules
│   ├── utils/                 # Utilities
│   └── types/                 # Type definitions
├── config/                    # Configuration files
│   ├── default.json           # Default configuration
│   ├── development.json       # Development overrides
│   └── production.json        # Production overrides
├── docs/                      # Documentation
├── tests/                     # Test files
└── README.md                  # Project documentation
```

## 🔧 Configuration Patterns

### Environment-Based Configuration

```javascript
// config/loader.js
function loadConfig(env = 'development') {
    const defaultConfig = require('./default.json');
    const envConfig = require(`./${env}.json`);
    const localConfig = fs.existsSync('./local.json') ? require('./local.json') : {};
    
    return deepMerge(defaultConfig, envConfig, localConfig);
}
```

### Validation Pattern

```javascript
// config/validator.js
const Joi = require('joi');

const configSchema = Joi.object({
    port: Joi.number().port().default(3000),
    database: Joi.object({
        host: Joi.string().required(),
        port: Joi.number().port().default(5432),
        name: Joi.string().required()
    }).required(),
    logging: Joi.object({
        level: Joi.string().valid('debug', 'info', 'warn', 'error').default('info')
    })
});

function validateConfig(config) {
    const { error, value } = configSchema.validate(config);
    if (error) {
        throw new Error(`Configuration validation failed: ${error.message}`);
    }
    return value;
}
```

## ⚡ Performance Patterns

### Lazy Loading Pattern

```javascript
// Lazy module loading
class ModuleLoader {
    constructor() {
        this.modules = new Map();
    }
    
    async getModule(name) {
        if (!this.modules.has(name)) {
            const module = await import(`./modules/${name}`);
            this.modules.set(name, module);
        }
        return this.modules.get(name);
    }
}
```

### Caching Pattern

```javascript
// Multi-level caching
class CacheManager {
    constructor() {
        this.memoryCache = new Map();
        this.diskCache = new DiskCache('./cache');
    }
    
    async get(key) {
        // Level 1: Memory cache
        if (this.memoryCache.has(key)) {
            return this.memoryCache.get(key);
        }
        
        // Level 2: Disk cache
        const diskValue = await this.diskCache.get(key);
        if (diskValue) {
            this.memoryCache.set(key, diskValue);
            return diskValue;
        }
        
        return null;
    }
    
    set(key, value, ttl) {
        this.memoryCache.set(key, value);
        this.diskCache.set(key, value, ttl);
    }
}
```

## 🔄 Integration Patterns

### Event-Driven Architecture

```javascript
// Event system
class EventBus {
    constructor() {
        this.listeners = new Map();
    }
    
    on(event, callback) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, []);
        }
        this.listeners.get(event).push(callback);
    }
    
    emit(event, data) {
        const callbacks = this.listeners.get(event) || [];
        callbacks.forEach(callback => callback(data));
    }
}
```

### Plugin System

```javascript
// Plugin architecture
class PluginManager {
    constructor() {
        this.plugins = new Map();
    }
    
    register(name, plugin) {
        if (typeof plugin.init === 'function') {
            plugin.init();
        }
        this.plugins.set(name, plugin);
    }
    
    get(name) {
        return this.plugins.get(name);
    }
    
    async loadPlugin(path) {
        const plugin = require(path);
        this.register(plugin.name, plugin);
    }
}
```

## 📋 Error Handling Patterns

### Structured Error Handling

```javascript
// Custom error classes
class ApplicationError extends Error {
    constructor(message, code, statusCode = 500) {
        super(message);
        this.name = this.constructor.name;
        this.code = code;
        this.statusCode = statusCode;
    }
}

class ValidationError extends ApplicationError {
    constructor(field, message) {
        super(`Validation failed for ${field}: ${message}`, 'VALIDATION_ERROR', 400);
        this.field = field;
    }
}

// Error handler middleware
function errorHandler(error, req, res, next) {
    if (error instanceof ApplicationError) {
        return res.status(error.statusCode).json({
            error: {
                code: error.code,
                message: error.message,
                field: error.field
            }
        });
    }
    
    // Unknown error
    console.error('Unexpected error:', error);
    res.status(500).json({
        error: {
            code: 'INTERNAL_ERROR',
            message: 'An unexpected error occurred'
        }
    });
}
```

## 🎨 Code Organization Patterns

### Feature-Based Structure

```
src/
├── features/
│   ├── user/
│   │   ├── index.js          # Public API
│   │   ├── service.js        # Business logic
│   │   ├── repository.js     # Data access
│   │   ├── validation.js     # Input validation
│   │   └── types.js          # Type definitions
│   └── product/
│       ├── index.js
│       ├── service.js
│       └── repository.js
├── shared/
│   ├── utils/
│   ├── types/
│   └── constants/
└── core/
    ├── database/
    ├── cache/
    └── config/
```

### Dependency Injection

```javascript
// Simple DI container
class Container {
    constructor() {
        this.services = new Map();
        this.singletons = new Map();
    }
    
    register(name, factory, singleton = false) {
        this.services.set(name, { factory, singleton });
    }
    
    get(name) {
        const service = this.services.get(name);
        if (!service) {
            throw new Error(`Service ${name} not found`);
        }
        
        if (service.singleton) {
            if (!this.singletons.has(name)) {
                this.singletons.set(name, service.factory(this));
            }
            return this.singletons.get(name);
        }
        
        return service.factory(this);
    }
}
```

## 🧪 Testing Patterns

### Test Structure

```javascript
// Test organization
describe('UserService', () => {
    let userService;
    let mockRepository;
    
    beforeEach(() => {
        mockRepository = {
            findById: jest.fn(),
            save: jest.fn()
        };
        userService = new UserService(mockRepository);
    });
    
    describe('getUserById', () => {
        it('should return user when found', async () => {
            // Arrange
            const userId = 1;
            const expectedUser = { id: 1, name: 'John' };
            mockRepository.findById.mockResolvedValue(expectedUser);
            
            // Act
            const result = await userService.getUserById(userId);
            
            // Assert
            expect(result).toEqual(expectedUser);
            expect(mockRepository.findById).toHaveBeenCalledWith(userId);
        });
    });
});
```

## 📊 Monitoring and Observability

### Structured Logging

```javascript
// Logger with context
class Logger {
    constructor(context = {}) {
        this.context = context;
    }
    
    info(message, meta = {}) {
        this.log('info', message, meta);
    }
    
    error(message, error, meta = {}) {
        this.log('error', message, { ...meta, error: error.stack });
    }
    
    log(level, message, meta) {
        const logEntry = {
            timestamp: new Date().toISOString(),
            level,
            message,
            context: this.context,
            meta
        };
        
        console.log(JSON.stringify(logEntry));
    }
    
    child(additionalContext) {
        return new Logger({ ...this.context, ...additionalContext });
    }
}
```

### Health Checks

```javascript
// Health check system
class HealthCheck {
    constructor() {
        this.checks = new Map();
    }
    
    register(name, checkFn, timeout = 5000) {
        this.checks.set(name, { checkFn, timeout });
    }
    
    async runAll() {
        const results = {};
        
        for (const [name, { checkFn, timeout }] of this.checks) {
            try {
                const result = await Promise.race([
                    checkFn(),
                    new Promise((_, reject) => 
                        setTimeout(() => reject(new Error('Timeout')), timeout)
                    )
                ]);
                
                results[name] = { status: 'healthy', result };
            } catch (error) {
                results[name] = { status: 'unhealthy', error: error.message };
            }
        }
        
        return results;
    }
}
```

## 💡 Design Decision Templates

### Architecture Decision Record (ADR)

```markdown
# ADR-001: [Decision Title]

## Status
[Proposed | Accepted | Rejected | Deprecated | Superseded]

## Context
What is the issue that we're seeing that is motivating this decision or change?

## Decision
What is the change that we're proposing or have agreed to implement?

## Consequences
What becomes easier or more difficult to do and any risks introduced by the change?

### Positive Consequences
- [e.g., improvement of quality attribute satisfaction, follow-up decisions required, ...]

### Negative Consequences
- [e.g., compromising quality attribute, follow-up decisions required, ...]

## Implementation Notes
Technical details about how to implement this decision.

## Alternatives Considered
Other options that were considered but rejected.
```

## 🔧 Common Anti-Patterns to Avoid

### 1. God Object
- **Problem**: Single class/module handles too many responsibilities
- **Solution**: Split into smaller, focused modules

### 2. Tight Coupling
- **Problem**: Components directly depend on each other's implementation
- **Solution**: Use interfaces and dependency injection

### 3. Configuration Chaos
- **Problem**: Configuration scattered across multiple files/formats
- **Solution**: Centralized, hierarchical configuration system

### 4. No Error Handling
- **Problem**: Errors are ignored or handled inconsistently
- **Solution**: Structured error handling with proper logging

### 5. Performance Afterthought
- **Problem**: Performance considerations added after implementation
- **Solution**: Performance requirements defined upfront with monitoring

---

_Last Updated: 2025-06-28_
_Status: Global Template - Applicable across projects_