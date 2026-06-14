-module(simple_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req, State) ->
  ReqWithResponse = cowboy_req:reply(200,
    #{<<"content-type">> => <<"application/json">>},
    json:encode(#{ message => <<"hi">> }),
    Req),
  {ok, ReqWithResponse, State}.
