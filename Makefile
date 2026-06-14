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
