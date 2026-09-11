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

---

## Bare-metal fallback (no container)

Use this if Podman is unavailable. Requires VPN.

### One-time setup

Install system dependencies:

```bash
sudo dnf install -y ruby ruby-devel publican libxslt libxml2 docbook-dtds git rsync openssh-clients make gcc python3.9 python3.9-devel
```

Pin asciidoctor to the version used by Prow CI (Fedora ships a newer, incompatible version):

```bash
gem install asciidoctor -v 2.0.20 --no-document --user-install
gem install asciidoctor-diagram --no-document --user-install
```

Create a Python 3.9 venv with Aura and its dependencies (do this once, reuse it):

```bash
python3.9 -m venv ~/sync-venv
~/sync-venv/bin/pip install --upgrade pip setuptools==68.2.2 wheel
~/sync-venv/bin/pip install pyyaml
~/sync-venv/bin/pip install /path/to/aura.tar.gz
```

### Per-sync procedure

1. Make sure you're on the right openshift-docs branch:
   ```bash
   git checkout enterprise-<version>   # e.g. enterprise-4.19
   ```

2. Clone the GitLab `stage` branch outside your working directory and extract `sync.sh`:
   ```bash
   cd /tmp
   git clone --branch stage --single-branch \
     git@gitlab.cee.redhat.com:red-hat-enterprise-openshift-documentation/doc-<version>.git
   cp doc-<version>/sync.sh ./sync-<version>.sh
   chmod +x sync-<version>.sh
   ```

3. Copy the build scripts from your local openshift-docs checkout:
   ```bash
   cp ~/Development/openshift-docs/build_for_portal.py .
   cp ~/Development/openshift-docs/makeBuild.py .
   ```

4. Activate the venv and run the sync:
   ```bash
   export PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"
   source ~/sync-venv/bin/activate
   ./sync-<version>.sh <version>        # e.g. ./sync-4.19.sh 4.19
   ```
