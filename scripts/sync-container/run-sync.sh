#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <version> (e.g., $0 4.22)"
    exit 1
fi

VERSION=$1
WORK_DIR="/tmp/openshift-docs-sync-${VERSION}-$(date +%s)"
MAIN_REPO_DIR=$(pwd)
EXPECTED_BRANCH="enterprise-${VERSION}"
CURRENT_BRANCH=$(git -C "${MAIN_REPO_DIR}" rev-parse --abbrev-ref HEAD)

if [[ "${CURRENT_BRANCH}" != "${EXPECTED_BRANCH}" ]]; then
    echo "❌ Wrong branch: you are on '${CURRENT_BRANCH}', but syncing version ${VERSION} requires '${EXPECTED_BRANCH}'."
    echo "   Run: git checkout ${EXPECTED_BRANCH}"
    exit 1
fi

echo "======================================================"
echo " Starting sync for version ${VERSION}"
echo " Working directory: ${WORK_DIR}"
echo "======================================================"

mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

echo "Cloning doc-${VERSION} from GitLab..."
mkdir -p mock-gitlab
git clone --bare --branch stage --single-branch git@gitlab.cee.redhat.com:red-hat-enterprise-openshift-documentation/doc-${VERSION}.git "mock-gitlab/doc-${VERSION}.git"

git --git-dir="mock-gitlab/doc-${VERSION}.git" show HEAD:sync.sh > sync.sh
chmod +x sync.sh

echo "Running sync process inside container..."
sed -i 's|/root/sync/openshift-docs/|/workspace/|g' sync.sh
cp "${MAIN_REPO_DIR}/build_for_portal.py" "${MAIN_REPO_DIR}/makeBuild.py" "${WORK_DIR}/"

podman run --rm -it \
    --ulimit nofile=8192:8192 \
    --userns=keep-id \
    -v "${WORK_DIR}:/workspace:Z" \
    -w /workspace \
    -e GIT_AUTHOR_NAME="$(git config user.name)" \
    -e GIT_AUTHOR_EMAIL="$(git config user.email)" \
    -e GIT_COMMITTER_NAME="$(git config user.name)" \
    -e GIT_COMMITTER_EMAIL="$(git config user.email)" \
    openshift-docs-sync /bin/bash -c "
        git config --global url.\"/workspace/mock-gitlab/doc-${VERSION}.git\".insteadOf \"git@gitlab.cee.redhat.com:red-hat-enterprise-openshift-documentation/doc-${VERSION}.git\" &&
        ./sync.sh ${VERSION}
    "

echo "Pushing changes to GitLab..."
cd "mock-gitlab/doc-${VERSION}.git"
git push origin stage:stage

echo "======================================================"
echo " Sync complete! Build available at:"
echo " ${WORK_DIR}"
echo "======================================================"
