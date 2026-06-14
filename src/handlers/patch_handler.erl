-module(patch_handler).
-behavior(cowboy_rest).

-export([
  init/2,
  allowed_methods/2,
  content_types_accepted/2,
  content_types_provided/2,
  accept_json/2,
  provide_json/2
]).

init(Req, State) ->
  {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
  {[<<"PATCH">>], Req, State}.

content_types_accepted(Req, State) ->
  {
    [
      {<<"application/json">>, accept_json}
    ],
    Req,
    State
  }.

content_types_provided(Req, State) ->
  {
    [
      {<<"application/json">>, provide_json}
    ],
    Req,
    State
  }.

accept_json(Req0, State) ->
%%  io:format("handling request. accept header is: ~s~n", [cowboy_req:header(<<"accept">>, Req0)]),
  case parse_route_params(Req0) of
    {ok, _Params} ->
      _Query = parse_query(cowboy_req:parse_qs(Req0)),
      ReqHeaders1 = cowboy_req:set_resp_header(
        <<"content-type">>,
        <<"application/json">>,
        Req0),
      Body = json:encode(#{message => <<"hi">>}),
      Req = cowboy_req:set_resp_body(Body, ReqHeaders1),
      {true, Req, State};

    {error, badname} ->
      Body = json:encode(#{error => <<"name is required and must be at least 3 characters">>}),
      ReqResp = cowboy_req:set_resp_body(Body, Req0),
      Req = cowboy_req:reply(400, ReqResp),
      {halt, Req, State};

    {error, id_not_int} ->
      Body = json:encode(#{error => <<"id must be a number">>}),
      ReqResp = cowboy_req:set_resp_body(Body, Req0),
      Req = cowboy_req:reply(400, ReqResp),
      {halt, Req, State}
  end.

provide_json(Req, State) ->
%%  io:format("handling request. accept header is: ~s~n", [cowboy_req:header(<<"accept">>, Req)]),
  {<<"{}">>, Req, State}.

parse_query(Query) ->
  QueryVal1 = proplists:get_value(<<"value1">>, Query),
  QueryVal2 = proplists:get_value(<<"value2">>, Query),
  #{value1 => QueryVal1, value2 => QueryVal2}.

parse_route_params(Req) ->
  RouteId = cowboy_req:binding(id, Req),
  RouteName = cowboy_req:binding(name, Req),

  case binary_helpers:parse_int(RouteId) of
    {ok, Id} ->
      if
        RouteName =:= undefined orelse size(RouteName) < 3 ->
          {error, badname};

        true ->
          {ok, #{id => Id, name => RouteName}}
      end;

    {error, _} = Err ->
      Err
  end.
