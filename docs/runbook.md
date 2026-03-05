# Codeline Runbook

## Runtime and Storage
- Runtime is Elixir/OTP.
- Session handling uses `GenServer` processes.
- Datastore is ETS only in phase 1.
- Data is ephemeral and is expected to be lost on pod restart.
- No PVC/PV is configured in this phase.

## Local Development
```bash
mix deps.get
mix test
CODELINE_LISTEN_PORT=2323 CODELINE_ADMIN_CODE=2el84u iex -S mix
```

Then connect with telnet:
```bash
telnet 127.0.0.1 2323
```

## Bazel Build and Publish
```bash
bazel run //bazel:build_release
IMAGE_TAG=v0.1.0 bazel run //bazel:build_image
IMAGE_TAG=v0.1.0 bazel run //bazel:push_image
```

Required auth for GHCR:
```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
```

Tagging convention:
- Release: immutable semantic tag (example: `v0.1.0`)
- Non-release: branch or commit tag (example: `main-<sha>`)

## Kubernetes Deploy
Apply production overlay:
```bash
kubectl apply -k k8s/prod
```

Verify resources:
```bash
kubectl -n codeline get deploy,svc,pdb,networkpolicy
kubectl -n codeline get svc codeline-prod -o wide
```

Expected service behavior:
- Service type `LoadBalancer`
- Public telnet on TCP/31337 -> container TCP/31337
- MetalLB IPv4 allocation from `k3s-pool`
- IPv4-only configured
- `external-dns` hostname `codeline.slowburnin.net`

## Migration Notes (C -> Elixir)
- Legacy file-backed state (`codeline.codes`, `codeline.motd`) is replaced with ETS memory tables.
- Operationally this changes state durability from file-backed to ephemeral.
- Command model remains compatible at high level: `POST`, `LIST`, `ADMIN`, `QUIT` and admin `CLEAR`, `MOTD`, `KILL`.

## Rollback Procedure
1. Scale down or remove new deployment:
```bash
kubectl -n codeline scale deployment/codeline-prod --replicas=0
```
2. Reapply previous stable manifests/image.
3. Confirm service endpoint and DNS point to prior stable version.
4. Capture parity gaps before next rollout.
