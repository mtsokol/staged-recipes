#!/bin/bash

set -xe

export PYTHON_VERSION=$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
export PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1)
export PYTHON_MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f2)
export BAZEL_VERSION="7.2.1"
export OUTPUT_DIR="$(pwd)"
export SOURCE_DIR="."
export RUN_TESTS="true"
. "./oss/runner_common.sh"

setup_env_vars_py "$PYTHON_MAJOR_VERSION" "$PYTHON_MINOR_VERSION"

function write_to_bazelrc() {
  echo "$1" >> .bazelrc
}

write_to_bazelrc "build -c opt"
write_to_bazelrc "build --cxxopt=-std=c++17"
write_to_bazelrc "build --host_cxxopt=-std=c++17"
write_to_bazelrc "build --experimental_repo_remote_exec"
write_to_bazelrc "build --python_path=\"${PYTHON_BIN}\""
write_to_bazelrc "test --python_path=\"${PYTHON_BIN}\""
PLATFORM="$(uname)"

export USE_BAZEL_VERSION="${BAZEL_VERSION}"
bazel clean
bazel build ... --action_env MACOSX_DEPLOYMENT_TARGET='11.0' --action_env PYTHON_BIN_PATH="${PYTHON_BIN}"
bazel test --verbose_failures --test_output=errors ... --action_env PYTHON_BIN_PATH="${PYTHON_BIN}"

DEST="${OUTPUT_DIR}"'/all_dist'
mkdir -p "${DEST}"

