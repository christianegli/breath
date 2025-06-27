# Contributing to Breath App

Thank you for your interest in contributing to the Breath app! This guide outlines how to contribute safely and effectively to a health-focused application.

## 🚨 Safety First

**CRITICAL**: This app deals with breath training techniques that can be dangerous if implemented incorrectly. All contributions must prioritize user safety above all other considerations.

### Safety Review Required

Any changes to the following areas require mandatory safety review:
- Training algorithms or methods
- Safety validation logic
- User education content
- Progress tracking calculations
- Audio cue timing
- Session parameters or limits

## Getting Started

### Prerequisites
- Read and understand [SETUP.md](SETUP.md)
- Familiarize yourself with [ARCHITECTURE.md](../ARCHITECTURE.md)
- Review [DECISIONS.md](../DECISIONS.md) for context on architectural choices
- Complete safety education module (in app) to understand user experience

### Development Environment
1. Follow the setup instructions in [SETUP.md](SETUP.md)
2. Create a feature branch from `main`
3. Make your changes with comprehensive tests
4. Submit a pull request with detailed description

## Contribution Guidelines

### Code Standards

#### Swift Style
- Follow [Apple's Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Document all public APIs
- Include inline comments for complex logic
- Use SwiftLint for consistency

#### Safety Code Requirements
```swift
// ✅ Good: Clear safety validation with explanation
func validateHoldTime(_ duration: TimeInterval) -> Bool {
    // Maximum hold time for beginners is 2 minutes to prevent
    // dangerous breath-holding attempts that could lead to hypoxia
    guard duration <= SafetyLimits.maxHoldTimeBeginner else {
        logger.warning("Hold time \(duration)s exceeds safe limit")
        return false
    }
    return true
}

// ❌ Bad: No safety validation or explanation
func setHoldTime(_ duration: TimeInterval) {
    self.holdTime = duration
}
```

#### Documentation Requirements
All safety-related code must include:
- Purpose and safety rationale
- Limits and their scientific basis
- Potential risks if modified
- Testing requirements

### Testing Requirements

#### Unit Tests
- 100% coverage for safety-related code
- Test all edge cases and error conditions
- Mock external dependencies
- Performance tests for timing-critical code

#### Safety Tests
```swift
func testHoldTimeSafetyLimits() {
    // Test maximum safe limits
    XCTAssertTrue(validator.validateHoldTime(120)) // 2 minutes
    XCTAssertFalse(validator.validateHoldTime(121)) // Over limit
    
    // Test minimum safe limits
    XCTAssertTrue(validator.validateHoldTime(10)) // 10 seconds
    XCTAssertFalse(validator.validateHoldTime(5)) // Too short
}
```

#### UI Tests
- Test critical user flows
- Verify safety education completion requirements
- Test accessibility features
- Validate error handling

### Pull Request Process

#### Before Submitting
1. **Run all tests** and ensure they pass
2. **Update documentation** for any API changes
3. **Test on device** (not just simulator)
4. **Verify accessibility** features work correctly
5. **Review safety implications** of your changes

#### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Safety-related change (requires safety review)

## Safety Impact
- [ ] No safety impact
- [ ] Modifies safety validation
- [ ] Changes training algorithms
- [ ] Affects user education
- [ ] Other (explain):

## Testing
- [ ] Unit tests added/updated
- [ ] UI tests added/updated
- [ ] Safety tests added/updated
- [ ] Tested on device
- [ ] Accessibility tested

## Documentation
- [ ] Code comments updated
- [ ] API documentation updated
- [ ] Architecture documentation updated
- [ ] Decision records updated (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Safety implications considered
- [ ] No debug code left in
- [ ] Performance impact assessed
```

### Commit Message Guidelines

Use conventional commits format:

```
feat(safety): add mandatory rest period validation

- Implements 4-hour minimum rest between intensive sessions
- Prevents user from exceeding safe training frequency
- Includes comprehensive unit tests for validation logic
- Addresses safety requirement SAF-003

Fixes #123
```

#### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `safety`: Safety-related changes
- `perf`: Performance improvements

## Areas for Contribution

### High Priority
- **Safety education content**: Improve user education materials
- **Accessibility features**: Enhance app accessibility
- **Testing**: Increase test coverage
- **Documentation**: Improve code and user documentation

### Medium Priority
- **UI/UX improvements**: Better user experience
- **Performance optimization**: Improve app performance
- **Audio improvements**: Better breathing cues
- **Progress tracking**: Enhanced metrics

### Future Enhancements
- **Apple Watch integration**: Extended functionality
- **Advanced training programs**: New training methods
- **Social features**: Community aspects
- **Analytics**: Usage insights

## Safety Review Process

### When Safety Review is Required
- Changes to training algorithms
- Modifications to safety limits
- Updates to user education content
- Changes to progress calculations
- Audio timing adjustments

### Safety Review Checklist
- [ ] Scientific basis for changes documented
- [ ] Potential risks identified and mitigated
- [ ] Safety limits maintained or justified
- [ ] User education updated if needed
- [ ] Emergency procedures considered
- [ ] Legal implications reviewed

### Safety Reviewers
Safety reviews are conducted by:
- Lead developers with medical/safety background
- External safety consultants (for major changes)
- Medical professionals (when available)

## Code of Conduct

### Our Commitment
We are committed to providing a safe, inclusive, and harassment-free experience for all contributors.

### Expected Behavior
- Use welcoming and inclusive language
- Respect differing viewpoints and experiences
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior
- Harassment or discrimination of any kind
- Trolling, insulting, or derogatory comments
- Public or private harassment
- Publishing others' private information
- Any conduct inappropriate for a professional setting

## Questions and Support

### Getting Help
- **Technical questions**: Create an issue with the `question` label
- **Safety concerns**: Email safety@breathapp.com (when available)
- **Documentation issues**: Create an issue with the `documentation` label
- **General discussion**: Start a discussion in the repository

### Resources
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Accessibility Guidelines](https://developer.apple.com/accessibility/)
- [Breath Training Research](https://example.com/research) (to be added)

## Recognition

Contributors who make significant improvements to the app's safety, accessibility, or user experience will be recognized in:
- App credits
- Repository contributors list
- Release notes for major contributions

---

**Remember**: We're building an app that could directly impact people's health and safety. Every contribution should be made with this responsibility in mind.

*Thank you for helping make breath training safer and more accessible!* 