# Development Workflow

## Kiro Spec-Driven Development
This project uses the Kiro framework for spec-driven development with Claude Code integration.

### Development Process
1. **Steering (Optional)**: `/kiro:steering` - Create/update project guidance
2. **Specification Creation**:
   - `/kiro:spec-init [description]` - Initialize feature specification
   - `/kiro:spec-requirements [feature]` - Generate requirements
   - `/kiro:spec-design [feature]` - Create design document
   - `/kiro:spec-tasks [feature]` - Generate implementation tasks
3. **Implementation**: `/kiro:spec-impl [feature] [task-number]` - Execute tasks using TDD
4. **Progress Tracking**: `/kiro:spec-status [feature]` - Check progress

### Key Principles
- **Follow 3-phase approval workflow**: Requirements → Design → Tasks → Implementation
- **Approval required**: Each phase requires human review
- **No skipping phases**: Design requires approved requirements; Tasks require approved design
- **Test-Driven Development**: TDD methodology with RED-GREEN-REFACTOR cycles

## Test-Driven Development (TDD)
The project strictly follows TDD methodology:

### TDD Cycle
1. **RED**: Write failing tests first
2. **GREEN**: Write minimal code to pass tests
3. **REFACTOR**: Clean up and improve code structure

### Testing Framework
- **SwiftTesting**: Modern testing framework using `@Test` and `#expect`
- **Test Organization**: Tests mirror source structure
- **Parallel Testing**: Tests designed to run in parallel for speed

## Development Guidelines
- **Think in English, but generate responses in Japanese** (思考は英語、回答の生成は日本語で行うように)
- **Protocol-Based Design**: All major components behind protocols
- **Dependency Injection**: Externally provided dependencies for testability
- **Security First**: Always consider security implications
- **Privacy by Design**: Local-first approach with user control