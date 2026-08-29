## 1. Runtime Rewrite (Elixir)
- [x] 1.1 Create Elixir OTP application skeleton and supervision tree for codeline service.
- [x] 1.2 Implement session/menu handling with `GenServer` processes for client command flows.
- [x] 1.3 Implement ETS-backed storage for MOTD and posted code lines.
- [x] 1.4 Ensure ETS data lifecycle is explicitly ephemeral across pod restarts.
- [x] 1.5 Add runtime configuration for listen port and admin credentials.
- [x] 1.6 Add tests for command parsing, admin auth flow, and ETS read/write behavior.

## 2. Bazel Build and Image Publish
- [x] 2.1 Add Bazel targets to build the Elixir release artifact and OCI image.
- [x] 2.2 Add Bazel target/script to push image to `ghcr.io/carverauto/codeline`.
- [x] 2.3 Document required registry authentication and tagging conventions.

## 3. Kubernetes Deployment (Kustomize)
- [x] 3.1 Create `k8s/base` with Namespace, Deployment, Service, ConfigMap/Secret references, and baseline labels.
- [x] 3.2 Create `k8s/prod` overlay with production-specific replicas, image tags, and environment values.
- [x] 3.3 Add hardening manifests and settings: NetworkPolicy, PodDisruptionBudget, resource requests/limits, probes, and strict pod/container security contexts.
- [x] 3.4 Ensure deployment targets the `codeline` namespace and applies successfully via Kustomize.
- [x] 3.5 Configure Service + MetalLB annotations/policies to allocate a public IPv4 from `k3s-pool`.
- [x] 3.6 Configure `external-dns` annotations/records for `codeline.slowburnin.net` pointing to the service load balancer address(es).
- [x] 3.7 Configure the `LoadBalancer` Service to expose telnet on TCP/31337 to the Elixir app and allow required ingress in NetworkPolicy.
- [x] 3.8 Do not include PVC/PV resources for codeline runtime data in this phase.

## 4. Migration and Cutover
- [x] 4.1 Define migration notes from file-backed storage behavior to ETS-backed runtime behavior.
- [x] 4.2 Define rollback procedure to prior runtime path if production issues are detected.
- [x] 4.3 Update README/runbook with local run, container build/push, and Kubernetes deploy instructions.
