## ADDED Requirements
### Requirement: Bazel Container Build
The project MUST provide Bazel targets to build a container image for the Elixir codeline service.

#### Scenario: Local or CI image build
- **WHEN** the Bazel container build target is executed
- **THEN** a runnable OCI image SHALL be produced for the codeline service

### Requirement: Bazel GHCR Publish
The project MUST provide a Bazel-driven publish path for `ghcr.io/carverauto/codeline`.

#### Scenario: Authenticated image push
- **WHEN** valid GHCR credentials are present and publish target is executed
- **THEN** the image SHALL be pushed to `ghcr.io/carverauto/codeline` with the configured tag

### Requirement: Image Tagging Convention
The project MUST define and document image tagging rules for release and non-release builds.

#### Scenario: Release tagging
- **WHEN** a production release is prepared
- **THEN** the published image SHALL include an immutable version tag
- **AND** the deployment overlay SHALL reference that immutable tag
