%%%-------------------------------------------------------------------
%%% @author fjakab
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Jun 2026 17:40
%%%-------------------------------------------------------------------
-module(binary_helpers).
-author("fjakab").

%% API
-export([parse_int/1]).

parse_int(Bin) ->
  try {ok, binary_to_integer(Bin)}
  catch error:badarg -> {error, not_an_integer}
  end.
