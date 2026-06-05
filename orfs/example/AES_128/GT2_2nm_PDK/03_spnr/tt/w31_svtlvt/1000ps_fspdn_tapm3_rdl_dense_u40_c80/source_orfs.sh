#!/usr/bin/env bash
# Source from this run directory before calling orfs_make.
# Usually edit only OR_IMAGE. If Docker cannot mount this package directory
# directly, set ORFS_WORKSPACE_HOST to a readable ancestor, for example
# /home/naeemi3; container paths are derived automatically.

export RUN_DIR_HOST="$(pwd -P)"
export HANDOFF_ROOT="${HANDOFF_ROOT:-$(cd "$RUN_DIR_HOST/../../../../../.." && pwd -P)}"
_default_orfs="$HANDOFF_ROOT/OpenROAD-flow-scripts"
if [[ ! -x "$_default_orfs/flow/util/docker_shell" && -x "$HANDOFF_ROOT/../../OpenROAD-flow-scripts/flow/util/docker_shell" ]]; then
  _default_orfs="$(cd "$HANDOFF_ROOT/../../OpenROAD-flow-scripts" && pwd -P)"
fi
export ORFS="${GT2N_ORFS:-${ORFS:-$_default_orfs}}"
export OR_IMAGE="${OR_IMAGE:-docker.io/openroad/orfs:26Q2}"

export ORFS_WORKSPACE_HOST="${ORFS_WORKSPACE_HOST:-$HANDOFF_ROOT}"
export ORFS_WORK_MOUNT_TARGET="${ORFS_WORK_MOUNT_TARGET:-/work}"

# Add filesystem groups needed for mounted research directories. This keeps
# Docker writes working on shared lab filesystems whose group differs from the
# user primary group.
_workspace_gid="$(stat -c %g "$ORFS_WORKSPACE_HOST")"
_run_gid="$(stat -c %g "$RUN_DIR_HOST")"
if [[ -z "${ORFS_EXTRA_GROUPS:-}" ]]; then
  export ORFS_EXTRA_GROUPS="$(printf '%s\n%s\n' "$_workspace_gid" "$_run_gid" | sort -u | tr '\n' ' ')"
fi

if [[ ! -x "$ORFS/flow/util/docker_shell" ]]; then
  echo "Error: cannot execute $ORFS/flow/util/docker_shell" >&2
  echo "Set ORFS to a full OpenROAD-flow-scripts checkout before sourcing." >&2
  return 1 2>/dev/null || exit 1
fi
if [[ ! -f "$RUN_DIR_HOST/config.mk" ]]; then
  echo "Error: config.mk not found in $RUN_DIR_HOST" >&2
  return 1 2>/dev/null || exit 1
fi

case "$HANDOFF_ROOT" in
  "$ORFS_WORKSPACE_HOST") HANDOFF_REL="" ;;
  "$ORFS_WORKSPACE_HOST"/*) HANDOFF_REL="${HANDOFF_ROOT#"$ORFS_WORKSPACE_HOST"/}" ;;
  *)
    echo "Error: HANDOFF_ROOT is outside ORFS_WORKSPACE_HOST." >&2
    echo "  HANDOFF_ROOT=$HANDOFF_ROOT" >&2
    echo "  ORFS_WORKSPACE_HOST=$ORFS_WORKSPACE_HOST" >&2
    return 1 2>/dev/null || exit 1
    ;;
esac

case "$RUN_DIR_HOST" in
  "$ORFS_WORKSPACE_HOST") RUN_DIR_REL="" ;;
  "$ORFS_WORKSPACE_HOST"/*) RUN_DIR_REL="${RUN_DIR_HOST#"$ORFS_WORKSPACE_HOST"/}" ;;
  *)
    echo "Error: run directory is outside ORFS_WORKSPACE_HOST." >&2
    echo "  ORFS_WORKSPACE_HOST=$ORFS_WORKSPACE_HOST" >&2
    echo "  RUN_DIR_HOST=$RUN_DIR_HOST" >&2
    return 1 2>/dev/null || exit 1
    ;;
esac

if [[ -n "$HANDOFF_REL" ]]; then
  export CONTAINER_PROJ_IN_CONTAINER="$ORFS_WORK_MOUNT_TARGET/$HANDOFF_REL"
else
  export CONTAINER_PROJ_IN_CONTAINER="$ORFS_WORK_MOUNT_TARGET"
fi

if [[ -n "$RUN_DIR_REL" ]]; then
  export DESIGN_CONFIG_IN_CONTAINER="$ORFS_WORK_MOUNT_TARGET/$RUN_DIR_REL/config.mk"
  export WORK_HOME_IN_CONTAINER="$ORFS_WORK_MOUNT_TARGET/$RUN_DIR_REL/work"
else
  export DESIGN_CONFIG_IN_CONTAINER="$ORFS_WORK_MOUNT_TARGET/config.mk"
  export WORK_HOME_IN_CONTAINER="$ORFS_WORK_MOUNT_TARGET/work"
fi

# Preserve the old PROJ name for scripts/logs that print it, but do not let a
# stale exported PROJ corrupt this handoff package's path mapping.
export PROJ="$HANDOFF_ROOT"
mkdir -p "$RUN_DIR_HOST/work"

orfs() {
  ( cd "$ORFS_WORKSPACE_HOST" && "$ORFS/flow/util/docker_shell" "$@" )
}

orfs_make() {
  orfs "make -f /OpenROAD-flow-scripts/flow/Makefile DESIGN_CONFIG=$DESIGN_CONFIG_IN_CONTAINER WORK_HOME=$WORK_HOME_IN_CONTAINER CONTAINER_PROJ=$CONTAINER_PROJ_IN_CONTAINER $*"
}

orfs_check() {
  orfs "openroad -version && yosys -V && klayout -v"
}

echo "ORFS environment loaded."
echo "HANDOFF_ROOT=$HANDOFF_ROOT"
echo "ORFS=$ORFS"
echo "RUN_DIR_HOST=$RUN_DIR_HOST"
echo "ORFS_WORKSPACE_HOST=$ORFS_WORKSPACE_HOST"
echo "CONTAINER_PROJ_IN_CONTAINER=$CONTAINER_PROJ_IN_CONTAINER"
echo "DESIGN_CONFIG_IN_CONTAINER=$DESIGN_CONFIG_IN_CONTAINER"
echo "WORK_HOME_IN_CONTAINER=$WORK_HOME_IN_CONTAINER"
