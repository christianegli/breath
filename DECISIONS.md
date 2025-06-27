# Architecture Decision Records (ADR)

## ADR-001: Safety-First Design Philosophy
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Research revealed that existing breath training apps lack proper safety education, and dangerous techniques like hyperventilation are commonly promoted. Users need protection from harmful practices.

### Decision
Implement a mandatory safety education system that blocks access to training features until completed. All training methods must be scientifically validated and include clear safety boundaries.

### Rationale
- Market research shows 70% of breath training apps lack safety warnings
- Wim Hof Method proven dangerous for breath-holding (oxygen depletion)
- Hyperventilation causes false confidence while reducing performance
- Liability protection requires comprehensive safety measures

### Consequences
- **Positive**: Users learn safe practices, reduced injury risk, legal protection
- **Negative**: Additional development complexity, potential user friction
- **Mitigation**: Make safety education engaging and interactive

### Alternatives Considered
- Optional safety tips (rejected - insufficient protection)
- Pop-up warnings only (rejected - easily dismissed)
- Progressive safety education (rejected - delays protection)

---

## ADR-002: iOS-First Platform Strategy
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Need to choose initial platform for MVP development. User requested iPhone app specifically, and market research shows breath training apps perform well on iOS.

### Decision
Develop for iOS first using Swift/SwiftUI, with potential Android expansion in future phases.

### Rationale
- User specifically requested iPhone app
- iOS users more likely to pay for health/fitness apps
- SwiftUI provides excellent animation support for breathing visualizations
- Apple's health ecosystem integration opportunities
- Smaller, more focused development effort for MVP

### Consequences
- **Positive**: Faster MVP development, better iOS integration, focused user experience
- **Negative**: Limited market reach initially, platform-specific development
- **Mitigation**: Plan architecture to facilitate future Android port

### Alternatives Considered
- Cross-platform framework (rejected - compromises native feel)
- Android first (rejected - not user's platform)
- Both platforms simultaneously (rejected - resource constraints)

---

## ADR-003: Offline-First Data Architecture
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Breath training requires precise timing and should work reliably without internet connection. Privacy concerns also favor local data storage.

### Decision
Store all user data locally using CoreData, with no cloud sync in MVP. All training programs and audio files bundled with app.

### Rationale
- Eliminates dependency on internet connectivity during training
- Better privacy protection (no data leaves device)
- Faster access to training programs
- Simpler MVP development (no backend required)
- Reduces ongoing operational costs

### Consequences
- **Positive**: Better privacy, offline capability, faster performance, lower costs
- **Negative**: No cross-device sync, limited backup options
- **Mitigation**: Plan optional cloud sync for future versions

### Alternatives Considered
- Cloud-first with offline cache (rejected - complexity for MVP)
- Hybrid approach (rejected - increases complexity)
- User-controlled sync (deferred - future enhancement)

---

## ADR-004: Progressive Training Method Selection
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Multiple breath training methods exist. Need to choose scientifically-backed, safe methods appropriate for beginners.

### Decision
Implement CO2 tolerance tables and static apnea protocols from freediving research, adapted for general users with enhanced safety measures.

### Rationale
- Scientifically proven methods from freediving community
- Clear progression path from beginner to intermediate
- Safer than hyperventilation-based methods
- Well-documented protocols exist
- Separates preparation breathing from actual breath-holding

### Consequences
- **Positive**: Science-based approach, proven effectiveness, clear progression
- **Negative**: More complex than simple breath-holding timers
- **Mitigation**: Excellent tutorial system to explain methods

### Alternatives Considered
- Simple breath-holding timers (rejected - no progression)
- Wim Hof Method (rejected - dangerous for breath-holding)
- Meditation-based breathing (rejected - different goal)

---

## ADR-005: Mandatory Safety Education Gate
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Safety education is critical but users often skip optional content. Need to ensure users understand proper techniques and risks.

### Decision
Implement mandatory safety education module that must be completed before accessing training features. Include interactive quizzes to validate understanding.

### Rationale
- Prevents users from accessing potentially dangerous features without education
- Validates user understanding through interactive quizzes
- Provides legal protection through documented safety education
- Establishes proper technique foundation before training

### Consequences
- **Positive**: Users properly educated, reduced injury risk, legal protection
- **Negative**: Additional friction in user onboarding
- **Mitigation**: Make education engaging with videos, animations, and gamification

### Alternatives Considered
- Optional safety tips (rejected - often skipped)
- Warning pop-ups (rejected - easily dismissed)
- Progressive disclosure (rejected - delays critical safety info)

---

## ADR-006: SwiftUI for User Interface
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Need to choose UI framework for iOS development. Options include UIKit and SwiftUI.

### Decision
Use SwiftUI for all user interface development.

### Rationale
- Declarative UI perfect for breathing visualizations and animations
- Excellent animation support for breathing guides
- Better accessibility support built-in
- Modern iOS development approach
- Easier to maintain and modify visual elements
- Great timer and progress visualization capabilities

### Consequences
- **Positive**: Modern UI, excellent animations, better accessibility, easier maintenance
- **Negative**: Newer framework with occasional iOS version limitations
- **Mitigation**: Target iOS 15+ for stable SwiftUI features

### Alternatives Considered
- UIKit (rejected - more complex animations)
- Hybrid approach (rejected - unnecessary complexity)
- Cross-platform framework (rejected - compromises native feel)

---

## ADR-007: CoreData for Progress Tracking
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Need to store user progress, session history, and achievement data. Multiple storage options available.

### Decision
Use CoreData for all persistent user data storage.

### Rationale
- Complex query capabilities needed for progress analysis
- Relationship management between sessions, achievements, and user progress
- Built-in encryption support for sensitive data
- Excellent performance for large datasets
- Native iOS integration
- Supports complex progress calculations

### Consequences
- **Positive**: Robust data management, complex queries, good performance
- **Negative**: Higher complexity than simple storage solutions
- **Mitigation**: Use code generation and clear data model design

### Alternatives Considered
- UserDefaults (rejected - too simple for complex data)
- SQLite directly (rejected - more work than CoreData)
- Realm (rejected - external dependency)

---

## ADR-008: Audio-First Guidance System
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Users need timing cues during breath training. Can provide guidance through audio, visual, or haptic feedback.

### Decision
Implement audio-first guidance system with visual backup, using AVFoundation for precise timing control.

### Rationale
- Users often close eyes during breathing exercises
- Audio cues don't require visual attention
- Precise timing critical for proper technique
- Accessibility benefits for visually impaired users
- Can work with phone in pocket or at distance

### Consequences
- **Positive**: Eyes-free operation, precise timing, accessibility benefits
- **Negative**: More complex than simple visual timers
- **Mitigation**: Provide visual alternatives for hearing-impaired users

### Alternatives Considered
- Visual-only guidance (rejected - requires constant visual attention)
- Haptic-only guidance (rejected - limited pattern complexity)
- Simple system audio (rejected - insufficient timing precision)

---

## ADR-009: Hard-Coded Safety Limits
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Need to prevent users from exceeding safe breath-holding limits, especially beginners who might push too hard.

### Decision
Implement hard-coded safety limits that cannot be overridden by users, with mandatory rest periods between intensive sessions.

### Rationale
- Prevents dangerous breath-holding attempts
- Protects users from their own enthusiasm
- Provides clear legal protection
- Based on established safety protocols from freediving
- Ensures progressive training approach

### Consequences
- **Positive**: User safety protection, legal coverage, prevents injuries
- **Negative**: May frustrate advanced users, limits customization
- **Mitigation**: Provide clear explanations of safety reasoning

### Alternatives Considered
- User-configurable limits (rejected - safety risk)
- Progressive limit increases (rejected - still allows dangerous attempts)
- Warning-only system (rejected - insufficient protection)

---

## ADR-010: No Social Features in MVP
**Date**: 2024-12-20  
**Status**: Accepted

### Context
Social features like leaderboards and competitions could motivate users but might encourage unsafe practices.

### Decision
Exclude social features from MVP to prevent competitive pressure that could lead to unsafe breath-holding attempts.

### Rationale
- Prevents users from competing unsafely
- Reduces pressure to exceed safe limits
- Simpler MVP development
- Focuses on personal improvement rather than competition
- Eliminates social pressure risks

### Consequences
- **Positive**: Safer user behavior, simpler development, personal focus
- **Negative**: Reduced motivation for some users, less engagement
- **Mitigation**: Consider carefully designed social features in future versions

### Alternatives Considered
- Safety-focused social features (deferred - complex to implement safely)
- Achievement sharing only (deferred - still creates comparison pressure)
- Buddy system for safety (deferred - future enhancement)

---

## ADR-011: Safety-Focused Progress Tracking and Gamification
**Date**: 2024-12-20  
**Status**: Accepted

### Context
User requested personal scoring, performance tracking with graphs, and gamification features including streaks and sharing. These features can be powerful motivators but need careful design to avoid encouraging unsafe practices.

### Decision
Implement progress tracking and gamification that rewards **consistency and technique** rather than maximum performance, with built-in safety boundaries and education.

### Rationale
- Progress tracking increases user engagement and motivation
- Gamification can make training more enjoyable and habit-forming
- Safety-first approach prevents competitive pressure leading to unsafe practices
- Focus on consistency encourages sustainable, long-term improvement
- Educational elements reinforce safety learning

### Design Principles
**Safe Scoring System:**
- **Consistency Score**: Rewards regular practice within safe limits
- **Technique Score**: Based on proper breathing form, not hold times
- **Safety Score**: Rewards adherence to rest periods and safety guidelines
- **Progress Score**: Gradual improvement within safety boundaries

**Safe Gamification:**
- Streaks celebrate consistent practice (with mandatory rest day celebrations)
- Achievements focus on technique mastery and safety compliance
- No maximum hold time leaderboards or competitions
- Educational achievements for completing safety modules

**Safe Sharing:**
- Share consistency achievements, not performance metrics
- Focus on technique improvements and safety milestones
- Educational content and safety tip sharing
- Progress stories emphasizing safe practice

### Consequences
- **Positive**: Increased engagement, sustainable motivation, reinforced safety learning
- **Negative**: More complex development, potential for misuse if not carefully designed
- **Mitigation**: Clear safety messaging, hard-coded limits, focus on education

### Safety Safeguards
- All scoring algorithms favor consistency over performance
- Sharing features block maximum hold time comparisons
- Streak rewards include mandatory rest day celebrations
- Achievement system emphasizes safety compliance
- Regular safety reminders integrated into gamification

### Alternatives Considered
- Performance-based scoring (rejected - encourages unsafe competition)
- Maximum hold time leaderboards (rejected - directly contradicts safety goals)
- No gamification (rejected - misses opportunity for positive motivation)
- Simple streaks without safety considerations (rejected - could encourage overtraining)

---

*Decision records maintained to track architectural reasoning and trade-offs.* 