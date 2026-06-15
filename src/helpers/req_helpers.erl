%%%-------------------------------------------------------------------
%%% @author fjakab
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2026 17:46
%%%-------------------------------------------------------------------
-module(req_helpers).
-author("fjakab").

%% API
-export([read_whole_body/1]).

read_whole_body(Req0) ->
  read_whole_body_loop([], Req0).

read_whole_body_loop(Acc, Req0) ->
  case cowboy_req:read_body(Req0) of
    {ok, Body, Req} ->
      FullBody = [Body, Acc],
      {iolist_to_binary(FullBody), Req};

    {more, Part, Req} ->
      read_whole_body_loop([Part, Acc], Req)
  end.
