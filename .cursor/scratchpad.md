# Breath Training App - Project Scratchpad
**Current Role:** Planner
**MVP Status:** Foundation Phase Ready
**GitHub Repo:** https://github.com/christianegli/breath
**Last Push:** Initial commit with comprehensive documentation (589ed49)

## Background and Motivation
User wants to learn to hold their breath longer and have an iPhone app to help them. This is a new project requiring comprehensive market research, competitive analysis, and safety-first approach to breath training.

## Research Findings

### Competitive Analysis
**Existing Breath Training Apps on iOS:**

1. **Apnea FreeDive Breath Hold** (SleepyBytes SIA)
   - Rating: 4.7/5 (606 reviews)
   - Features: 4-week training program, customizable tables, breath-hold tracking
   - Pricing: Free with in-app purchases ($2.99-$69.99)
   - Focus: Freediving, spearfishing, underwater activities

2. **Breath Hold Trainer** (Guillermo Mondet)
   - Rating: 5.0/5 (11 reviews)
   - Features: CO2 & O2 training tables, progress tracking, assessments
   - Pricing: Free with $9.99 premium
   - Focus: CO2 tolerance, lung capacity, mental resilience

3. **Apnea Trainer: Nea** (keinois OU)
   - Rating: 5.0/5 (4 reviews)
   - Features: Relaxation tables, CO2/O2 training, Home Screen widgets
   - Pricing: Free with subscriptions ($1.99-$49.99)
   - Focus: Freediving, spearfishing with personalized training

4. **STAmina Apnea Coach** (Squarecrowd Apps)
   - Rating: 3.0/5 (1 review)
   - Apple Watch exclusive
   - Focus: CO2 tolerance development

### Key Market Gaps Identified:
- **Beginner-friendly apps**: Most focus on advanced freediving
- **Safety-first approach**: Limited emphasis on safety warnings
- **Educational content**: Lack of comprehensive technique instruction
- **Progressive training**: Few apps offer truly beginner-to-intermediate progression
- **Visual feedback**: Limited real-time breathing guidance

### Proven Breath-Holding Techniques Research:

1. **Freediving Methods (Safe & Scientific)**:
   - CO2 tolerance tables (reducing prep time, fixed hold)
   - O2 efficiency tables (fixed prep, increasing hold time)
   - Static apnea training with proper safety protocols
   - Progressive training over weeks/months

2. **Box Breathing**: 4-4-4-4 pattern for relaxation and control

3. **Diaphragmatic Breathing**: Belly breathing for efficiency

**CRITICAL SAFETY FINDINGS:**
- **Wim Hof Method**: Research shows it's DANGEROUS for freediving
  - Creates false confidence through CO2 depletion
  - Can lead to blackouts at dangerous oxygen levels
  - Should NEVER be combined with water activities
- **Hyperventilation**: Universally contraindicated for breath-holding
- **Buddy system**: Essential for any serious training

### User Pain Points Identified:
1. **Safety Concerns**: Users don't know what's dangerous
2. **Overwhelming Information**: Too much conflicting advice online
3. **Lack of Structure**: No clear progression path for beginners
4. **Technique Confusion**: Don't know proper breathing methods
5. **Progress Tracking**: Difficulty measuring improvement safely
6. **Motivation**: Hard to stick with training consistently

### Safety Requirements (CRITICAL):
- Clear warnings about hyperventilation dangers
- Emphasis on dry training vs. wet training safety
- Medical disclaimers and contraindications
- Buddy system recommendations
- Emergency safety protocols
- Age restrictions and supervision requirements

## MVP Definition

**Core Features (Build First - Safety-Focused):**
- [ ] Comprehensive safety education module (must complete first)
- [ ] Guided breathing technique tutorials (box breathing, diaphragmatic)
- [ ] Progressive dry training program (beginner-friendly)
- [ ] Timer with audio/visual cues for training sessions
- [ ] Progress tracking with safe metrics
- [ ] Medical disclaimer and safety warnings

**Essential Safety Features:**
- [ ] Pre-training safety quiz (must pass to unlock features)
- [ ] Regular safety reminders during sessions
- [ ] Clear distinction between dry and wet training
- [ ] Age verification and parental controls
- [ ] Emergency contact information display

## Enhancement Roadmap (Build Later):
- [ ] Advanced CO2/O2 table training
- [ ] Apple Watch integration
- [ ] Social features/buddy system connectivity
- [ ] Personalized training plans based on goals
- [ ] Integration with health apps
- [ ] Guided meditation and relaxation features
- [ ] Achievement system and gamification
- [ ] Community features and challenges

## Key Challenges and Analysis

### Technical Challenges:
- Accurate timing and audio cues during breath holds
- User safety monitoring and intervention
- Progressive difficulty without overwhelming beginners
- iOS-specific features (widgets, health integration)

### Safety Challenges:
- Ensuring users understand risks before starting
- Preventing misuse of techniques in dangerous situations
- Clear guidance on when to seek medical advice
- Age-appropriate content and restrictions

### Market Challenges:
- Differentiating from existing freediving-focused apps
- Building trust around safety-first approach
- Educating users about proper vs. dangerous techniques
- Balancing simplicity with comprehensive safety

## High-level Task Breakdown

### Phase 1: Foundation Setup (Week 1)
1. **Project Infrastructure**
   - Create Xcode project with proper structure
   - Set up CoreData model for user progress
   - Configure SwiftUI app architecture (MVVM)
   - Implement basic navigation structure

2. **Safety Education Module** 
   - Design mandatory safety education curriculum
   - Create interactive safety quizzes
   - Implement education completion validation
   - Add medical disclaimer and age verification

3. **Core Services Architecture**
   - Implement SafetyValidator service
   - Create basic TrainingEngine framework
   - Set up ProgressCalculator foundation
   - Design AudioController for breathing cues

### Phase 2: Core Training Features (Week 2-3)
4. **Breathing Technique Tutorials**
   - Implement box breathing guide
   - Create diaphragmatic breathing tutorial
   - Add visual breathing animations
   - Develop audio cue system

5. **Basic Training Engine**
   - Implement beginner training programs
   - Create session management system
   - Add timer functionality with audio/visual cues
   - Implement safety validation during sessions

6. **Progress Tracking System**
   - Design progress data models
   - Implement session recording
   - Create progress calculation algorithms
   - Add basic progress visualization

### Phase 3: Polish & Safety (Week 4)
7. **Safety Hardening**
   - Implement hard-coded safety limits
   - Add mandatory rest period enforcement
   - Create comprehensive error handling
   - Test all safety edge cases

8. **User Experience Polish**
   - Improve UI/UX based on testing
   - Add accessibility features
   - Optimize performance
   - Create onboarding flow

9. **Testing & Validation**
   - Comprehensive unit test coverage
   - UI automation tests
   - Safety validation testing
   - Performance optimization

## Project Status Board

### MVP Tasks (Priority: CRITICAL)

#### Week 1: Foundation
- [x] **Task 1**: Create Xcode project structure ✅
  - Success: Project builds and runs on simulator/device
  - Priority: CRITICAL
  - Estimate: 1 day
  - **COMPLETED**: iOS project structure created with SwiftUI+MVVM architecture

- [ ] **Task 2**: Implement mandatory safety education module
  - Success: Users cannot access training without completing education
  - Priority: CRITICAL
  - Estimate: 3 days

- [ ] **Task 3**: Set up core service architecture
  - Success: SafetyValidator, TrainingEngine, ProgressCalculator operational
  - Priority: CRITICAL
  - Estimate: 2 days

#### Week 2: Core Features
- [ ] **Task 4**: Implement breathing technique tutorials
  - Success: Box breathing and diaphragmatic breathing guides functional
  - Priority: CRITICAL
  - Estimate: 3 days

- [ ] **Task 5**: Build basic training engine
  - Success: Users can complete guided breath training sessions
  - Priority: CRITICAL
  - Estimate: 4 days

#### Week 3: Progress & Polish
- [ ] **Task 6**: Create progress tracking system with basic gamification
  - Success: Sessions recorded, progress calculated, basic graphs displayed
  - Features: Session history, simple progress charts, consistency tracking
  - Safety: Focus on consistency rather than maximum performance
  - Priority: CRITICAL
  - Estimate: 4 days

- [ ] **Task 7**: Implement safety hardening
  - Success: All safety limits enforced, comprehensive error handling
  - Priority: CRITICAL
  - Estimate: 2 days

- [ ] **Task 8**: Complete testing and validation
  - Success: 90%+ test coverage, all safety tests pass
  - Priority: CRITICAL
  - Estimate: 2 days

### Enhancement Tasks (Priority: LATER)

#### High Priority Enhancements (Phase 4 - Week 5-6)
- [ ] **Personal Scoring System** (Safety-Focused)
  - Consistency Score (regularity of practice)
  - Technique Score (proper breathing form)
  - Safety Score (adherence to rest periods)
  - Progress Score (gradual improvement within safe limits)

- [ ] **Advanced Progress Tracking & Graphs**
  - Weekly/monthly progress charts
  - Consistency trend visualization
  - Technique improvement metrics
  - Safety compliance tracking
  - Goal setting with safety boundaries

- [ ] **Safe Gamification Elements**
  - Practice streaks (with mandatory rest day celebrations)
  - Technique mastery badges
  - Safety milestone achievements
  - Consistency rewards (not performance-based)
  - Educational quiz achievements

#### Medium Priority Enhancements (Phase 5 - Week 7-8)
- [ ] **Community Features** (Safety-First Design)
  - Share consistency achievements (not max times)
  - Educational content sharing
  - Safety tip sharing
  - Progress photos/stories (technique focus)
  - Buddy system for accountability

- [ ] **Advanced Training Programs**
  - CO2/O2 table training (with enhanced safety)
  - Intermediate breathing techniques
  - Specialized programs (stress relief, focus)
  - Personalized training plans

#### Future Enhancements (Phase 6+)
- [ ] Apple Watch integration for extended functionality
- [ ] HealthKit integration for optional data sharing
- [ ] Professional trainer integration
- [ ] Advanced analytics and insights

## Current Status / Progress Tracking
✅ **Market Research Complete**: Competitive analysis and safety research finished
✅ **Architecture Designed**: Comprehensive technical architecture documented
✅ **Project Initialized**: Git repository, documentation structure complete
✅ **GitHub Repository**: Ready for creation and first push
⏳ **Next Phase**: Ready for transition to Executor role for implementation

## Test Results & Validation
[To be filled by Tester role]

## Executor's Feedback or Assistance Requests
[To be filled by Executor role]

## Documentation Status
- [x] README.md created and comprehensive
- [x] ARCHITECTURE.md created with detailed system design
- [x] DECISIONS.md created with 10 documented ADRs
- [x] API documentation created with full interface specs
- [x] Setup instructions created with development workflow
- [x] Contributing guidelines created with safety focus

## Lessons Learned
- **Safety is paramount**: Many existing apps lack proper safety education
- **Beginner gap exists**: Market focused on advanced freediving, not general breath training
- **Education crucial**: Users need to understand WHY techniques work/don't work
- **Wim Hof Method**: Popular but scientifically proven dangerous for breath-holding
- **Progressive approach**: Success comes from gradual, structured improvement 