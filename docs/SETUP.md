# Development Setup Instructions

## Prerequisites

### Required Software
- **Xcode 14.0+** with iOS 15.0+ SDK
- **macOS 12.0+** (for Xcode compatibility)
- **Swift 5.7+** (included with Xcode)
- **Git** for version control

### Optional Tools
- **SF Symbols 4** (for icon design)
- **Instruments** (for performance profiling)
- **TestFlight** (for beta testing)

## Initial Setup

### 1. Clone Repository
```bash
git clone [repository-url]
cd breath
```

### 2. Xcode Project Setup
```bash
# Create Xcode project (will be done in implementation phase)
# For now, project structure is documented in ARCHITECTURE.md
```

### 3. Configure Development Environment
- Open Xcode
- Set up Apple Developer Account for testing
- Configure code signing for development

## Project Structure

```
breath/
├── Breath/                     # Main app target
│   ├── App/                   # App lifecycle and configuration
│   ├── Views/                 # SwiftUI views
│   │   ├── Safety/           # Safety education views
│   │   ├── Training/         # Training session views
│   │   ├── Progress/         # Progress tracking views
│   │   └── Settings/         # Settings and profile views
│   ├── ViewModels/           # MVVM view models
│   ├── Models/               # Data models
│   ├── Services/             # Business logic services
│   │   ├── SafetyValidator.swift
│   │   ├── TrainingEngine.swift
│   │   ├── ProgressCalculator.swift
│   │   └── AudioController.swift
│   ├── Data/                 # CoreData and data management
│   ├── Resources/            # Audio files, training programs
│   └── Utils/                # Utilities and extensions
├── BreathTests/              # Unit tests
├── BreathUITests/            # UI tests
└── docs/                     # Documentation
```

## Dependencies

### Core iOS Frameworks
- **SwiftUI** - User interface
- **Combine** - Reactive programming
- **CoreData** - Data persistence
- **AVFoundation** - Audio playback
- **UserNotifications** - Training reminders

### Third-Party Dependencies
None planned for MVP (keeping it simple and lightweight)

## Build Configuration

### Debug Configuration
- Enable debug logging
- Skip safety education for development (with warnings)
- Shorter training sessions for testing
- Extended safety limits for development testing

### Release Configuration
- All safety features enabled
- Production audio assets
- Standard training programs
- Standard safety limits enforced

## Testing Setup

### Unit Testing
```bash
# Run unit tests
cmd+U in Xcode
# Or via command line:
xcodebuild test -scheme Breath -destination 'platform=iOS Simulator,name=iPhone 14'
```

### UI Testing
- Automated UI tests for critical user flows
- Accessibility testing
- Safety validation testing
- Performance testing

## Code Style & Standards

### Swift Style Guide
- Follow Apple's Swift API Design Guidelines
- Use SwiftLint for code consistency
- 100% documentation coverage for public APIs
- Meaningful variable and function names

### Safety Code Requirements
- All safety-related code must be thoroughly tested
- Safety limits must be hard-coded (no configuration files)
- Clear documentation for all safety decisions
- Code review required for safety-related changes

## Development Workflow

### Feature Development
1. Create feature branch from `main`
2. Implement feature with comprehensive tests
3. Update documentation
4. Safety review for any training-related changes
5. Code review and merge to `main`

### Safety Review Process
Any code changes affecting:
- Training algorithms
- Safety limits
- User education content
- Progress tracking

Must go through additional safety review process.

## Environment Variables

### Development
- `DEBUG_MODE` - Enable debug features
- `SKIP_SAFETY_EDUCATION` - Skip safety module (development only)
- `EXTENDED_LIMITS` - Allow extended training (development only)

### Production
All debug features disabled and safety features fully enforced.

## Deployment

### TestFlight Beta
- Internal testing with development team
- External testing with limited beta users
- Safety feedback collection

### App Store Submission
- Complete safety review
- Medical disclaimer review
- Accessibility compliance check
- Performance optimization verification

## Troubleshooting

### Common Setup Issues

**Xcode Build Errors:**
- Ensure iOS 15.0+ deployment target
- Verify Swift 5.7+ compatibility
- Check code signing configuration

**Audio Issues:**
- Verify AVFoundation framework inclusion
- Check audio file formats (prefer AAC)
- Test on device (not just simulator)

**CoreData Issues:**
- Verify data model configuration
- Check migration scripts for version updates
- Test with clean simulator state

### Performance Considerations
- Profile memory usage during long sessions
- Optimize audio loading and playback
- Test battery impact during extended use
- Verify smooth animations on older devices

## Support

### Documentation
- [Architecture Overview](../ARCHITECTURE.md)
- [Decision Records](../DECISIONS.md)
- [API Documentation](API.md)

### Development Resources
- Apple Developer Documentation
- SwiftUI Tutorials
- AVFoundation Programming Guide
- CoreData Programming Guide

---

*Setup guide for safe, efficient development of the Breath app.* 