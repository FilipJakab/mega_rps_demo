PROJECT = mega_rps_demo
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = cowboy
dep_cowboy_commit = 2.16.0

REL_DEPS += relx

DEP_PLUGINS = cowboy

# erlang.mk is gitignored, so bootstrap it on a fresh clone. GNU Make notices
# the included file is missing, runs this rule to fetch it, then restarts. The
# rule is only defined when the file is absent, so it doesn't clash with the
# self-update target that erlang.mk itself provides.
ERLANG_MK_URL ?= https://erlang.mk/erlang.mk

ifeq ($(wildcard erlang.mk),)
erlang.mk:
	curl -fsSL $(ERLANG_MK_URL) -o $@
endif

include erlang.mk

.PHONY: setup
setup: erlang.mk deps
	npm install

# Load test a running server endpoint with autocannon. Pick the endpoint with
# TEST (one of the handlers below) and override the run parameters as needed:
#
#   make loadtest TEST=patch CONNECTIONS=500 DURATION=10 WORKERS=4
#
HOST ?= http://localhost:8080
CONNECTIONS ?= 1000
DURATION ?= 20
WORKERS ?= 8
TEST ?= hello-world

# Per-handler autocannon arguments (method/headers/body/path). Each value maps
# to a route in src/mega_rps_demo_app.erl.
AC_ARGS_hello-world = $(HOST)/hello-world
AC_ARGS_simple = $(HOST)/simple
AC_ARGS_patch = -m PATCH -H 'content-type=application/json' -b '{}' $(HOST)/update-something/1/abc

AC_ARGS = $(AC_ARGS_$(TEST))

.PHONY: loadtest
loadtest:
ifeq ($(AC_ARGS),)
	$(error Unknown TEST '$(TEST)'. Valid values: hello-world simple patch)
endif
	npm exec -c "autocannon -c $(CONNECTIONS) -d $(DURATION) -w $(WORKERS) $(AC_ARGS)"

# Run every endpoint's load test back to back.
.PHONY: loadtest-all
loadtest-all:
	$(MAKE) loadtest TEST=hello-world
	$(MAKE) loadtest TEST=simple
	$(MAKE) loadtest TEST=patch
