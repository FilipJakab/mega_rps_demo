#!/usr/bin/env bash
#
# Build and start the release, wait until it accepts connections, run the
# autocannon load test, then shut the release down again.
#
# Any arguments are forwarded to `make loadtest`, so you can pick the endpoint
# and override the benchmark parameters, e.g.:
#
#   ./run.sh TEST=patch CONNECTIONS=500 DURATION=10 WORKERS=4
#
# Valid TEST values: hello-world (default), simple, patch.
#
set -euo pipefail

cd "$(dirname "$0")"

REL=mega_rps_demo_release
REL_BIN="_rel/$REL/bin/$REL"
URL="http://localhost:8080/"

# Build the release (same prerequisite `make run` uses).
make all

# Stop the daemon on exit, however we got there (success, error or Ctrl-C).
cleanup() {
	"$REL_BIN" stop >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Starting $REL ..."
"$REL_BIN" daemon

# Wait for the HTTP listener to come up (curl returns 0 once it gets any
# response, even a 404; exit code 7 means the connection was refused).
echo -n "Waiting for $URL "
for _ in $(seq 1 30); do
	if curl -s -o /dev/null "$URL"; then
		echo "up."
		break
	fi
	echo -n "."
	sleep 1
done

if ! curl -s -o /dev/null "$URL"; then
	echo "server did not come up in time" >&2
	exit 1
fi

make loadtest "$@"