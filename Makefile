PROJECT = mega_rps_demo
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = cowboy
dep_cowboy_commit = 2.16.0

REL_DEPS += relx

DEP_PLUGINS = cowboy

include erlang.mk
