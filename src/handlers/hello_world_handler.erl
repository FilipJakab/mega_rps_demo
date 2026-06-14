-module(hello_world_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req, State) ->
  ReqWithResponse = cowboy_req:reply(200,
    #{<<"content-type">> => <<"text/plain">>},
    <<"Hello Erlang!">>,
    Req),
  {ok, ReqWithResponse, State}.
