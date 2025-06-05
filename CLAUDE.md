# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
# Install dependencies
pod install

# Generate new VIPER module
generamba gen [ModuleName] stepik-module

# Lint code
./lint.sh Stepic
./lint.sh StepicUITests

# Auto-fix lint issues
./autocorrect.sh Stepic
./autocorrect.sh StepicUITests
```

### Testing
```bash
# Run tests for specific scheme
fastlane test scheme:"Stepic Production"
fastlane test scheme:"Stepic Develop"
fastlane test scheme:"Stepic Release"
```

### Build & Deploy
```bash
# Build beta for Firebase distribution
fastlane beta scheme:"Stepic Production"
fastlane beta scheme:"Stepic Develop"

# Deploy to App Store
fastlane release scheme:"Stepic Production" target:"Stepic" should_submit:true

# Version management
fastlane increment_build
fastlane set_version version:"1.2.3"
fastlane increment_minor_version

# Certificate management
fastlane match_all scheme:"Stepic Production"
```

## Architecture

### VIPER Pattern
This project uses VIPER architecture for all feature modules:

- **View**: ViewControllers and UI components
- **Interactor**: Business logic and data operations
- **Presenter**: View formatting and presentation logic
- **Entity**: Data models and DTOs
- **Router**: Navigation and module transitions
- **Assembly**: Dependency injection setup
- **DataFlow**: Input/output protocols and data transfer objects
- **Provider**: Data source management (network, cache, database)

### Module Structure
```
ModuleName/
├── Assembly/
│   └── ModuleNameAssembly.swift
├── View/
│   ├── ModuleNameViewController.swift
│   └── Views/
├── Presenter/
│   └── ModuleNamePresenter.swift
├── Interactor/
│   └── ModuleNameInteractor.swift
├── Router/
│   └── ModuleNameRouter.swift
├── DataFlow/
│   └── ModuleNameDataFlow.swift
└── InputOutput/
    ├── ModuleNameInputProtocol.swift
    └── ModuleNameOutputProtocol.swift
```

### Legacy vs Modern Code
- **Legacy/**: Contains older MVC-based code being gradually migrated
- **Sources/**: Modern VIPER-based modular architecture
- When working on features, prefer adding to `Sources/Modules/` using VIPER pattern

### Core Services
- **NetworkingService**: Handles API requests using Alamofire
- **PersistenceService**: Core Data management
- **AnalyticsService**: Multiple analytics providers (Firebase, AppMetrica, Amplitude)
- **AuthService**: Authentication and user management
- **CacheService**: Image and data caching
- **NotificationsService**: Push notifications via Firebase

### Project Targets
- **Stepic**: Main application
- **StepicWidgetExtension**: iOS 14+ home screen widgets
- **StickerPackExtension**: iMessage sticker pack
- **StepicTests**: Unit tests
- **StepicUITests**: UI automation tests

### Build Configurations
- **Production**: App Store builds with production API endpoints
- **Develop**: Development builds with staging API
- **Release**: Release candidate builds

### Code Quality
- SwiftLint enforces 150+ rules with line length limit of 120 characters
- Force unwrapping and force casting are treated as errors
- All new code should follow the established VIPER patterns
- Tests should be written for all new business logic in Interactors