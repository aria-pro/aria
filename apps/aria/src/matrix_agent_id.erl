%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author yangchengjian
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. May 2019 13:42
%%%-------------------------------------------------------------------
-module(matrix_agent_id).
-author("yangchengjian").

%% API
-export([
  get_id/1,
  get_ids/1,
  get_zyx/1
]).

get_id({Y, X}) ->
  PidNameBin = <<0:16/integer, Y:16/integer, X:16/integer>>,
%%  PidNameBin = matrix_node_id:get_id({0, Y, X}),
  erlang:binary_to_atom(PidNameBin, latin1).

get_zyx(Id) ->
  <<Z:16/integer, Y:16/integer, X:16/integer>> = erlang:atom_to_binary(Id, latin1),
  {Z, Y, X}.

get_ids([{MinY, MaxY}, {MinX, MaxX}]) ->
  ListY = lists:seq(MinY, MaxY, 10),
  ListX = lists:seq(MinX, MaxX, 10),
%%  utils_log:debug("[~p, ~p] generate_pid_list ListY: ~p, ListX: ~p", [?MODULE, ?LINE, ListY, ListX]),
  generate_pid_list(ListY, ListX, []).

generate_pid_list([], _ListX, Result) ->
%%  utils_log:debug("[~p, ~p] generate_pid_list Result: ~p", [?MODULE, ?LINE, Result]),
  Result;
generate_pid_list([Y | ListY], ListX, Result) ->
  Result0 = generate_pid_list_(Y, ListX, []),
  generate_pid_list(ListY, ListX, lists:merge(Result0, Result)).

generate_pid_list_(_Y, [], Result) ->
  Result;
generate_pid_list_(Y, [X | ListX], Result) ->
%%  utils_log:debug("[~p, ~p] generate_pid_list_ Y: ~p, X: ~p", [?MODULE, ?LINE, Y, X]),
  R = get_id({Y, X}),
  generate_pid_list_(Y, ListX, [R | Result]).




