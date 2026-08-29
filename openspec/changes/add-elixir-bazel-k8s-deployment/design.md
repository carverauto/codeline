## Context
`codeline` is currently a small C daemon using manual process management and local file persistence. The requested direction introduces a modern runtime and delivery platform: OTP-based service behavior, Bazel-driven container publishing, and hardened Kubernetes deployment patterns.

## Goals / Non-Goals
- Goals:
  - Provide a functionally equivalent codeline service on Elixir/OTP.
  - Use `GenServer` and supervision for robust process lifecycle management.
  - Use ETS as the operational datastore for MOTD and posted lines.
  - Keep runtime data ephemeral for phase 1 (no persistent volume-backed state).
  - Build and publish container images through Bazel to `ghcr.io/carverauto/codeline`.
  - Standardize Kubernetes deployment structure with Kustomize base/production overlay and hardening controls.
  - Expose the service at `codeline.slowburnin.net` using `external-dns` with MetalLB-backed public addresses.
  - Support stable IPv4 service exposure from `k3s-pool`.
- Non-Goals:
  - Re-creating legacy implementation details that are unsafe or irrelevant in containerized production.
  - Introducing external managed databases as part of this rewrite.
  - Adding persistent volume-backed state management in this phase.

## Decisions
- Decision: Implement client/session workflow using OTP processes (`GenServer`) under a supervision tree.
  - Alternatives considered: direct process spawning with raw sockets, or retaining C server with wrappers.
  - Rationale: OTP supervision and message-passing improves fault isolation and maintainability.

- Decision: Use ETS tables as primary service datastore.
  - Alternatives considered: local files, Mnesia, external DB.
  - Rationale: ETS is lightweight, in-process, fast, and aligns with requested architecture.

- Decision: Do not implement PVC-backed persistence in this phase.
  - Alternatives considered: ETS snapshot to disk on PVC, DETS on PVC.
  - Rationale: current scope prioritizes runtime rewrite and platform delivery; persistence can be added as a follow-on change.

- Decision: Use Bazel as the canonical build and image publishing path.
  - Alternatives considered: Dockerfile-only pipeline or mix-only release pipeline.
  - Rationale: Bazel provides reproducible builds and consistent CI/CD integration.

- Decision: Use Kustomize with `k8s/base` and `k8s/prod` overlays.
  - Alternatives considered: flat manifests or Helm chart.
  - Rationale: Kustomize overlays satisfy the requested environment layering while keeping manifests transparent.

- Decision: Publish service using Kubernetes `LoadBalancer` + MetalLB + `external-dns`.
  - Alternatives considered: Ingress-only exposure or manual DNS management.
  - Rationale: MetalLB provides deterministic on-prem/public IP allocation, and `external-dns` automates DNS record management for `codeline.slowburnin.net`.

- Decision: Configure IPv4-only service semantics for this phase.
  - Alternatives considered: dual-stack service.
  - Rationale: current environment has unstable IPv6 reachability; IPv4-only is required for reliable public access.

## Risks / Trade-offs
- ETS is in-memory and ephemeral by default.
  - Mitigation: document non-durable behavior explicitly and test restart semantics.

- Rewriting runtime behavior may introduce command compatibility gaps.
  - Mitigation: define compatibility-focused tests and acceptance scenarios for key command flows.

- Security hardening controls may conflict with runtime assumptions (filesystem writes, privileged operations).
  - Mitigation: design container/runtime to run non-root with read-only filesystem and explicit writable paths only if required.

- Public exposure through MetalLB and DNS automation can create unintended reachability if policies are too broad.
  - Mitigation: enforce explicit NetworkPolicy allowlists, constrained Service ports, and clearly scoped `external-dns` ownership/annotations.

## Migration Plan
1. Implement Elixir service with feature parity for core commands.
2. Validate local runtime behavior and tests.
3. Build/publish container via Bazel into GHCR.
4. Deploy into Kubernetes `codeline` namespace via `k8s/prod` overlay.
5. Verify public IPv4 allocation through MetalLB and DNS propagation for `codeline.slowburnin.net`.
6. Perform smoke verification and monitor logs/health probes.

## Rollback Plan
1. Stop rollout of new deployment and scale down Elixir pods.
2. Re-deploy previous stable runtime path.
3. Restore service endpoint routing to prior version.
4. Document incident notes and parity gaps before retry.

## Open Questions
- Exact authentication/authorization mechanism for GHCR push in CI environment.
