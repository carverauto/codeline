## ADDED Requirements
### Requirement: Kustomize Directory Structure
The repository MUST provide Kubernetes manifests with Kustomize structure at `k8s/base` and `k8s/prod`.

#### Scenario: Base and production render
- **WHEN** operators run a Kustomize build for `k8s/base` or `k8s/prod`
- **THEN** manifests SHALL render successfully
- **AND** the production overlay SHALL compose from the base

### Requirement: Namespace-Scoped Deployment
The Kubernetes deployment MUST run in the `codeline` namespace.

#### Scenario: Applied resources
- **WHEN** manifests are applied to a cluster
- **THEN** workload resources SHALL be created in the `codeline` namespace

### Requirement: Hardened Pod Security Context
The deployment MUST apply hardened container and pod security settings.

#### Scenario: Pod security posture
- **WHEN** pods are inspected in the cluster
- **THEN** containers SHALL run as non-root
- **AND** privilege escalation SHALL be disabled
- **AND** all Linux capabilities SHALL be dropped unless explicitly required
- **AND** seccomp SHALL use `RuntimeDefault`
- **AND** root filesystem SHALL be read-only unless an explicit writable mount is defined

### Requirement: Network Access Controls
The deployment MUST define NetworkPolicy resources that restrict ingress and egress to required traffic only.

#### Scenario: Deny-by-default policy
- **WHEN** network policies are applied
- **THEN** unsolicited traffic SHALL be denied by default
- **AND** only explicitly allowed service traffic SHALL be permitted

#### Scenario: Telnet ingress allowance
- **WHEN** codeline is exposed publicly
- **THEN** ingress on TCP port 31337 to codeline pods SHALL be explicitly allowed by NetworkPolicy
- **AND** non-required ports SHALL remain blocked

### Requirement: MetalLB Public Service Exposure
The deployment MUST expose codeline using a Kubernetes `LoadBalancer` Service integrated with MetalLB.

#### Scenario: IPv4 address allocation from k3s pool
- **WHEN** the Service is applied in the cluster
- **THEN** MetalLB SHALL allocate a public IPv4 address from the `k3s-pool` address pool
- **AND** the Service status SHALL report the assigned IPv4 load balancer address

#### Scenario: Telnet service port
- **WHEN** the Service definition is rendered and applied
- **THEN** the Service SHALL expose TCP port 31337 for inbound telnet traffic
- **AND** the Service target port SHALL route to the Elixir application listener

### Requirement: IPv4 Service Addressing
The deployment MUST use IPv4-only service exposure for this phase.

#### Scenario: IPv4-only load balancer addressing
- **WHEN** the Service is created in the cluster
- **THEN** the Service SHALL be configured with IPv4 `SingleStack` IP family policy
- **AND** the Service SHALL receive an IPv4 load balancer address

### Requirement: External DNS Record Management
The deployment MUST integrate with `external-dns` to manage DNS for `codeline.slowburnin.net`.

#### Scenario: DNS record publication
- **WHEN** the production service is deployed with required `external-dns` annotations
- **THEN** DNS records for `codeline.slowburnin.net` SHALL be created or updated to point at the Service load balancer address(es)
- **AND** DNS management SHALL be automated without manual record edits

### Requirement: Production Reliability Controls
The production overlay MUST include health and availability controls for stable operation.

#### Scenario: Health and disruption handling
- **WHEN** pods are deployed in production
- **THEN** readiness and liveness probes SHALL be configured
- **AND** resource requests and limits SHALL be set
- **AND** a PodDisruptionBudget SHALL be present for controlled disruptions

### Requirement: Phase 1 Storage Scope
The phase 1 Kubernetes manifests MUST not introduce PVC/PV resources for codeline runtime state.

#### Scenario: Manifest inspection
- **WHEN** operators render `k8s/base` and `k8s/prod`
- **THEN** no PersistentVolumeClaim or PersistentVolume resources SHALL be present for codeline state
- **AND** runtime data behavior SHALL remain ETS-only and ephemeral
