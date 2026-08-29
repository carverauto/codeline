# Change: Rewrite codeline in Elixir with Bazel container delivery and hardened Kubernetes deployment

## Why
The current C daemon is difficult to evolve safely and has limited operational controls for modern deployment environments.
Migrating to Elixir with OTP supervision and codifying build/deploy standards enables maintainable runtime behavior, reproducible container delivery, and secure Kubernetes operations.

## What Changes
- Replace the C runtime with an Elixir/OTP implementation using `GenServer` processes for command/session behavior.
- Use ETS tables for in-memory datastore responsibilities currently handled through flat files.
- Keep storage explicitly ephemeral in this phase (no PVC-backed persistence yet).
- Add Bazel-based container build and image publish flow targeting `ghcr.io/carverauto/codeline`.
- Add Kubernetes manifests organized as Kustomize base/overlay structure (`k8s/base`, `k8s/prod`).
- Apply Kubernetes hardening defaults, including namespace scoping, security context restrictions, and network policies.
- Expose the service publicly through MetalLB with IPv4 addressing from `k3s-pool`.
- Configure `external-dns` integration so `codeline.slowburnin.net` resolves to the MetalLB service address(es).
- Expose inbound telnet traffic on TCP/31337 through the Kubernetes `LoadBalancer` Service to the Elixir application.
- **BREAKING**: Runtime storage and process model change from file-backed C daemon to OTP + ETS service.

## Impact
- Affected specs:
  - `serve-codeline`
  - `publish-codeline-image`
  - `deploy-codeline-kubernetes`
- Affected code:
  - New Elixir application modules and supervision tree
  - New Bazel build/publish targets for container images
  - New Kubernetes/Kustomize manifests under `k8s/`
  - Legacy `codeline.c` runtime path retired from primary deployment path
