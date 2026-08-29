## ADDED Requirements
### Requirement: Elixir OTP Runtime
The codeline service MUST run as an Elixir OTP application with supervised processes for lifecycle management.

#### Scenario: Service boot
- **WHEN** the application starts
- **THEN** a supervision tree SHALL start all required runtime components
- **AND** failures in child processes SHALL be handled by supervision restart strategy

### Requirement: GenServer-Based Session Handling
The system MUST implement client command/session behavior using one or more `GenServer` processes.

#### Scenario: Client command execution
- **WHEN** a client issues a supported command
- **THEN** the responsible `GenServer` SHALL validate and execute the command
- **AND** the response SHALL be returned over the active session

### Requirement: ETS Datastore for Runtime State
The system MUST store MOTD and posted code-line entries in ETS tables.

#### Scenario: Post and list flow
- **WHEN** a client posts a code-line entry
- **THEN** the entry SHALL be persisted in ETS
- **AND** a subsequent list operation SHALL return the entry from ETS

#### Scenario: Pod restart behavior
- **WHEN** the application pod restarts
- **THEN** ETS-backed runtime data SHALL be treated as non-durable
- **AND** prior in-memory entries SHALL not be assumed to persist across restart

### Requirement: Runtime Configuration
The service MUST support runtime configuration for listen port and admin credentials without source edits.

#### Scenario: Environment-specific config
- **WHEN** deployment provides environment-specific settings
- **THEN** the service SHALL start with those settings applied
- **AND** no code changes SHALL be required for configuration updates
