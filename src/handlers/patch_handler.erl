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

-record(query_params, {value1, value2}).
-record(route_params, {id, name}).

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
    {ok, Params} ->
      case parse_query(cowboy_req:parse_qs(Req0)) of
        {ok, Query} ->
          {ReqBody, Req1} = req_helpers:read_whole_body(Req0),
          ReqBodyParsed = json:decode(ReqBody),
          TotalFoo = parse_foo_values_from_body(ReqBodyParsed),

          ReqHeaders1 = cowboy_req:set_resp_header(
            <<"content-type">>,
            <<"application/json">>,
            Req1),
          Body = json:encode(#{
            id => Params#route_params.id,
            name => Params#route_params.name,
            value1 => Query#query_params.value1,
            value2 => Query#query_params.value2,
            total_foo => TotalFoo
          }),
          Req = cowboy_req:set_resp_body(Body, ReqHeaders1),
          {true, Req, State};

        _ ->
          Body = json:encode(#{error => <<"invalid query params">>}),
          ReqResp = cowboy_req:set_resp_body(Body, Req0),
          Req = cowboy_req:reply(400, ReqResp),
          {halt, Req, State}
      end;

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

parse_foo_values_from_body(BodyParsed) ->
  ExtractedFoos =
    [
      map_get(<<"foo", (integer_to_binary(Idx))/binary>>, BodyParsed)
      || Idx <- lists:seq(1, 10, 1)
    ],
  MappedFoos = [format_foo_to_text(Foo) || Foo <- ExtractedFoos],
  MappedFoosUpper = string:uppercase(MappedFoos),
  unicode:characters_to_binary(MappedFoosUpper).

parse_query(Query) ->
  QueryVal1 = proplists:get_value(<<"value1">>, Query),
  QueryVal2 = proplists:get_value(<<"value2">>, Query),
  {ok, #query_params{value1 = QueryVal1, value2 = QueryVal2}}.

parse_route_params(Req) ->
  RouteId = cowboy_req:binding(id, Req),
  RouteName = cowboy_req:binding(name, Req),

  case binary_helpers:parse_int(RouteId) of
    {ok, Id} ->
      if
        RouteName =:= undefined orelse size(RouteName) < 3 ->
          {error, badname};

        true ->
          {ok, #route_params{id = Id, name = RouteName}}
      end;

    {error, _} = Err ->
      Err
  end.

format_foo_to_text(V) when is_binary(V)  -> [V, <<". ">>];
format_foo_to_text(V) when is_integer(V) -> integer_to_binary(V);
format_foo_to_text(V) when is_float(V)   -> float_to_binary(V, [short]);
format_foo_to_text(true)                 -> <<"true">>;
format_foo_to_text(false)                -> <<"false">>;
format_foo_to_text(null)                 -> <<>>;
format_foo_to_text(undefined)            -> <<>>.

