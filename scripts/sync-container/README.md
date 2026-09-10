# Containerized openshift-docs sync

This directory contains a containerized environment for running the legacy OpenShift documentation sync script, `sync.sh`.

## Prerequisites

- **Podman:** You have Podman installed.
- **Aura:** You have the `aura.tar.gz` file in the sync-container directory (`scripts/sync-container/`).
- **VPN:** You are connected to the Red Hat VPN.

## Building the image
Place `aura.tar.gz` in `scripts/sync-container/` and run:

```bash
podman build -t openshift-docs-sync .
```

## Sync!
Run the wrapper script from the root of the repository:

```bash
./scripts/sync-container/run-sync.sh <version>
```

For example:
```bash
./scripts/sync-container/run-sync.sh 4.22
```
