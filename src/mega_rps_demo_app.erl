-module(mega_rps_demo_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
  Dispatch = cowboy_router:compile([
    {
      '_',
      [
        {"/hello-world", hello_world_handler, []},
        {"/simple", simple_handler, []},
        {"/update-something/:id/:name", patch_handler, []}
      ]
    }
  ]),
  {ok, _} = cowboy:start_clear(my_http_listener,
    [{port, 8080}],
    #{env => #{dispatch => Dispatch}}
  ),
  mega_rps_demo_sup:start_link().

stop(_State) ->
	ok.
