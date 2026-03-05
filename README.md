# codeline

```
______________________________________________________________________________

888888888888888888888888888888888888888888888888888888888888888888888888888888
______________________________________________________________________________
BoW BoW BoW BoW BoW Bo*                                *BoW BoW BoW BoW BoW Bo
W BoW BoW BoW BoW Bo* + ------------------------------ + *BoW BoW BoW BoW BoW
BoW BoW BoW BoW BoW Bo|   THe BoW CoDE-LiNE FoR iNET   |BoW BoW BoW BoW BoW Bo
W BoW BoW BoW BoW Bo* + ------------------------------ + *BoW BoW BoW BoW BoW
BoW BoW BoW BoW BoW Bo*  by: TH3 V3LKR0 K0D3 WaRRi0R  *BoW BoW BoW BoW BoW Bo
==============================================================================
```

## Origin Story
Originally found in http://www.textfiles.com/magazines/BOW/bow6.txt, `codeline.c` was created by BoW in 1994.

This repository now includes a modern Elixir/OTP implementation for production deployment, while keeping the legacy C source for reference.

## Runtime (Elixir)
- OTP application with supervised processes
- Per-session command handling via `GenServer`
- ETS-only datastore (ephemeral in phase 1)

### Local run
```bash
mix deps.get
mix test
CODELINE_LISTEN_PORT=2323 CODELINE_ADMIN_CODE=2el84u iex -S mix
```

Connect locally:
```bash
telnet 127.0.0.1 2323
```

## Bazel Build / Image Publish
Build release:
```bash
bazel run //bazel:build_release
```

Build image:
```bash
IMAGE_TAG=v0.1.0 bazel run //bazel:build_image
```

Push image to GHCR:
```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
IMAGE_TAG=v0.1.0 bazel run //bazel:push_image
```

Default image repo is `ghcr.io/carverauto/codeline`.

## Kubernetes
Manifests are organized with Kustomize:
- `k8s/base`
- `k8s/prod`

Deploy production overlay:
```bash
kubectl apply -k k8s/prod
```

Deployment characteristics:
- Namespace: `codeline`
- Service type: `LoadBalancer`
- Public telnet: `TCP/31337` -> app `TCP/31337`
- MetalLB IPv4 pool: `k3s-pool`
- IPv4-only service policy
- `external-dns` hostname: `codeline.slowburnin.net`
- Hardened workload defaults: non-root, no privilege escalation, capabilities dropped, seccomp `RuntimeDefault`, read-only root filesystem

## Runbook
Operational details, migration notes, and rollback steps are in [docs/runbook.md](docs/runbook.md).
