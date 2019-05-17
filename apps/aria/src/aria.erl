%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author yangchengjian
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. May 2019 21:28
%%%-------------------------------------------------------------------
-module(aria).
-author("yangchengjian").

%% API
-export([
  init_with_agent/1,
  print_10x10/3
]).


init_with_agent({MinZ, MaxZ}) when MinZ > MaxZ ->
  ok;
init_with_agent({MinZ, MaxZ}) ->
  PidList = matrix_agent_id:get_ids([{0, 99}, {0, 99}]),
  utils_log:debug("[~p, ~p] init_with_agent PidList {Z, Y, X}: ~p", [?MODULE, ?LINE, PidList]),
  matrix_agent:send(PidList, {init, {MinZ, MaxZ}}).


print_10x10(_, 0, _) ->
  ok;
print_10x10({Z, Y, X}, LenY, LenX) ->
  print_every_y({Z, Y + LenY - 1, X}, LenX, []),
  print_10x10({Z, Y, X}, LenY - 1, LenX).

print_every_y(_, 0, Result) ->
  io:format("~n~w~n", [Result]);
print_every_y({Z, Y, X}, LenX, Result) ->
  NodeState = matrix_node:get_node_state({Z, Y, X + LenX - 1}),
  print_every_y({Z, Y, X}, LenX - 1, [NodeState | Result]).



