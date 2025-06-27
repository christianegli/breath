# System Architecture

## Overview

Breath is a safety-first iOS app designed to teach proper breath-holding techniques through progressive, scientifically-backed training methods. The architecture prioritizes user safety, educational content, and clear progression tracking.

## Design Principles

1. **Safety First**: Every feature must prioritize user safety and education
2. **Progressive Complexity**: Start simple, build complexity gradually
3. **Offline Capability**: Core features work without internet connection
4. **Accessibility**: Designed for users with varying abilities
5. **Evidence-Based**: All training methods based on scientific research

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App                              │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer (SwiftUI)                              │
│  ├── Safety Education Views                                │
│  ├── Training Session Views                                │
│  ├── Progress Tracking Views                               │
│  └── Settings & Profile Views                              │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                      │
│  ├── Safety Validator                                      │
│  ├── Training Engine                                       │
│  ├── Progress Calculator                                   │
│  └── Audio/Visual Cue Controller                           │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                │
│  ├── CoreData (User Progress)                              │
│  ├── UserDefaults (Settings)                               │
│  └── Bundle Resources (Training Programs)                  │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Safety Education Module
**Purpose**: Ensure users understand proper techniques and risks before training

**Components**:
- Interactive safety lessons
- Knowledge validation quizzes
- Medical disclaimer acceptance
- Age verification system

**Design Rationale**: Research shows most breath training apps lack proper safety education, leading to dangerous practices. This module is mandatory and blocks access to training features until completed.

### 2. Training Engine
**Purpose**: Deliver structured, progressive breath training sessions

**Components**:
- Breathing technique tutorials
- Timer management with audio/visual cues
- Session state management
- Progress validation

**Design Rationale**: Uses proven CO2 tolerance and static apnea methods from freediving research, adapted for general users with safety modifications.

### 3. Progress Tracking System
**Purpose**: Monitor user improvement while maintaining safety boundaries

**Components**:
- Session history storage
- Improvement metrics calculation
- Safety threshold monitoring
- Achievement recognition

**Design Rationale**: Focuses on safe, gradual improvement rather than maximum performance, preventing users from pushing beyond safe limits.

### 4. Audio/Visual Guidance System
**Purpose**: Provide real-time breathing cues and feedback

**Components**:
- Breathing pattern visualization  
- Audio cue generation
- Haptic feedback coordination
- Accessibility support

**Design Rationale**: Visual and audio cues help users maintain proper breathing rhythms, reducing errors that could lead to unsafe practices.

## Data Flow

### Training Session Flow
1. User selects training program
2. Safety validation check
3. Pre-session safety reminder
4. Guided breathing preparation
5. Timed breath-holding phase
6. Recovery guidance
7. Session data recording
8. Progress analysis and feedback

### Safety Validation Flow
1. Check user completion of safety education
2. Verify session parameters within safe limits
3. Confirm adequate rest between sessions
4. Validate user's self-reported condition
5. Block unsafe activities with educational messaging

## Technology Choices

### **SwiftUI over UIKit**
- **Chosen because**: Declarative UI perfect for breathing visualizations
- **Trade-off**: Newer framework, but better animation support for breathing guides

### **CoreData for Progress Storage**
- **Chosen because**: Robust offline storage, complex query capabilities
- **Trade-off**: More complex than UserDefaults, but needed for detailed progress tracking

### **AVFoundation for Audio**
- **Chosen because**: Precise timing control for breathing cues
- **Trade-off**: More complex than simple audio playback, but essential for accurate guidance

### **MVVM Architecture Pattern**
- **Chosen because**: Clear separation of concerns, testable business logic
- **Trade-off**: More initial complexity, but better maintainability and testing

## Security & Privacy

### Data Protection
- All user data stored locally (no cloud sync initially)
- Progress data encrypted at rest
- No personal health information collected
- User can delete all data at any time

### Safety Measures
- Hard-coded safety limits (cannot be overridden)
- Mandatory cooling-off periods between intensive sessions
- Regular safety reminders throughout app usage
- Clear escalation paths to medical professionals

## Performance Considerations

### Offline-First Design
- All core features work without internet
- Training programs stored locally
- Progress calculated on-device
- Minimal battery impact during sessions

### Timer Precision
- High-precision timing for breathing cues
- Background processing for audio guidance
- Efficient memory usage during long sessions

## Accessibility Features

### Visual Accessibility
- High contrast mode support
- Scalable text for all content
- Alternative text for all images
- Color-blind friendly design

### Audio Accessibility
- VoiceOver support throughout app
- Haptic feedback alternatives
- Customizable audio cue options
- Visual alternatives for audio cues

## Future Architecture Considerations

### Planned Enhancements
- **Apple Watch Integration**: Extended timer and haptic feedback
- **HealthKit Integration**: Optional health data sharing
- **CloudKit Sync**: Backup and cross-device sync
- **Advanced Analytics**: Detailed progress insights

### Scalability Considerations
- Modular design allows easy feature additions
- Plugin architecture for new training methods
- Extensible data model for future metrics
- API-ready for potential backend services

## Development Approach

### Phase 1: Foundation (MVP)
- Safety education system
- Basic training engine
- Core progress tracking
- Essential UI components

### Phase 2: Enhancement
- Advanced training programs
- Detailed analytics
- Apple Watch support
- Improved visualizations

### Phase 3: Platform Expansion
- Potential Android version
- Backend services
- Social features
- Professional integration

## Quality Assurance

### Testing Strategy
- Unit tests for all business logic
- UI tests for critical user flows
- Safety validation testing
- Performance testing under load
- Accessibility testing

### Monitoring
- Crash reporting (privacy-focused)
- Performance metrics
- User safety feedback
- Feature usage analytics (anonymous)

---

*Architecture designed for safety, simplicity, and scientific accuracy.* 