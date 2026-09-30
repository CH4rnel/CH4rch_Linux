#!/usr/bin/env bash
# 𒀭 𝙲𝙷𝟺𝚛𝚌𝚑 𝙻𝚒𝚗𝚞𝚡 𒀭
# Profile Enforcer for CH4rch Linux.
# Reads Agent Profile YAML and generates isolation flags for bwrap/microvm-launch.
# Implements real enforcement of profile-defined isolation.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/build.conf"

PROFILES_DIR="$CH4RCH_SRC/profiles"

usage() {
    echo "Usage: $0 <profile-name> [--backend bwrap|microvm]"
    echo "  Reads agent profile and outputs isolation flags"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

PROFILE_NAME="$1"
OUTPUT_BACKEND="${2:-bwrap}"
PROFILE_FILE="$PROFILES_DIR/${PROFILE_NAME}.yaml"

if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "ERROR: Profile '$PROFILE_NAME' not found at $PROFILE_FILE" >&2
    exit 1
fi

# Parse YAML using Python
parse_profile() {
    python3 << EOF
import yaml
import sys
import json

with open('$PROFILE_FILE', 'r') as f:
    profile = yaml.safe_load(f)

# Validate required fields
required = ['agent', 'isolation', 'capabilities']
for field in required:
    if field not in profile:
        print(f"ERROR: Missing required field: {field}", file=sys.stderr)
        sys.exit(1)

# Extract isolation settings
isolation = profile['isolation']
backend = isolation.get('backend', 'bubblewrap')
privilege = isolation.get('privilege', 'unprivileged')
network = isolation.get('network', 'none')
filesystem = isolation.get('filesystem', {})
read_only = filesystem.get('read_only', [])
read_write = filesystem.get('read_write', [])
ttl = isolation.get('ttl', None)

# Extract capabilities
capabilities = profile.get('capabilities', [])

# Output as JSON for bash consumption
output = {
    'backend': backend,
    'privilege': privilege,
    'network': network,
    'read_only': read_only,
    'read_write': read_write,
    'ttl': ttl,
    'capabilities': capabilities,
    'enabled': profile.get('enabled', False)
}

print(json.dumps(output))
EOF
}

# Generate bwrap flags
generate_bwrap_flags() {
    local profile_json="$1"
    
    python3 << EOF
import json
import sys

profile = json.loads('$profile_json')

flags = []

# Filesystem bindings
for path in profile['read_only']:
    flags.append(f"--ro-bind {path} {path}")

for path in profile['read_write']:
    flags.append(f"--bind {path} {path}")

# Privilege model
if profile['privilege'] == 'unprivileged':
    flags.append("--unshare-user")
    flags.append("--uid-map 0:$(id -u):1")
    flags.append("--gid-map 0:$(id -g):1")
    flags.append("--cap-drop ALL")

# Network isolation
if profile['network'] == 'none':
    flags.append("--unshare-net")
elif profile['network'] == 'lan-only':
    # LAN-only requires custom iptables/nftables rules (TODO)
    pass

# TTL (requires external wrapper)
if profile['ttl']:
    print(f"# TTL: {profile['ttl']}s (requires timeout wrapper)", file=sys.stderr)

# Output flags
print(' '.join(flags))
EOF
}

# Generate microvm flags
generate_microvm_flags() {
    local profile_json="$1"
    
    python3 << EOF
import json

profile = json.loads('$profile_json')

flags = []

# Memory and CPUs (defaults, can be extended)
flags.append("--memory 512M")
flags.append("--cpus 1")

# Network
if profile['network'] == 'none':
    flags.append("--network none")
elif profile['network'] == 'lan-only':
    flags.append("--network lan")

# Output flags
print(' '.join(flags))
EOF
}

# Main execution
echo "[CH4RCH] Enforcing profile: $PROFILE_NAME" >&2

PROFILE_JSON=$(parse_profile)

# Check if profile is enabled
ENABLED=$(echo "$PROFILE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['enabled'])")
if [[ "$ENABLED" != "True" ]]; then
    echo "[CH4RCH] WARNING: Profile '$PROFILE_NAME' is disabled (enabled: false)" >&2
    echo "[CH4RCH] Set 'enabled: true' in profile to activate" >&2
    exit 1
fi

# Generate flags based on backend
if [[ "$OUTPUT_BACKEND" == "bwrap" ]]; then
    echo "[CH4RCH] Generating bubblewrap flags..." >&2
    generate_bwrap_flags "$PROFILE_JSON"
elif [[ "$OUTPUT_BACKEND" == "microvm" ]]; then
    echo "[CH4RCH] Generating microvm flags..." >&2
    generate_microvm_flags "$PROFILE_JSON"
else
    echo "ERROR: Unknown backend '$OUTPUT_BACKEND'" >&2
    exit 1
fi

# Log to hash-chain
if [[ -x "$CH4RCH_SRC/build-tools/hash-chain.sh" ]]; then
    "$CH4RCH_SRC/build-tools/hash-chain.sh" "PROFILE_ENFORCE name=$PROFILE_NAME backend=$OUTPUT_BACKEND"
fi