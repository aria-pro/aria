%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author captcha
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Sep 2017 下午5:50
%%%-------------------------------------------------------------------
-module(matrix_node).
-author("captcha").

%% API
-export([
  init_z/1,
  get_node_info/1,
  get_node_timestamp/1,
  get_node_state/1,
  set_node_state/2,
  handle_next/1,
  get_next_nodes/1,
  update_node_state/1,
  check_if_active_next/2,
  active_next_state/1
]).

%%--------------------------------------------------------------------
%% @doc
%% init node [{MinZ, MaxZ}, {MinY, MaxY}, {MinX, MaxX}],
%% for example:
%% init_z([{0, 9}, {0, 99}, {0, 999}])
%% will initail a matrix with x = 1000, y = 100, z = 10。
%% @end
%%--------------------------------------------------------------------
-spec init_z(list()) -> ok.
init_z([{MinZ, MaxZ}, {_MinY, _MaxY}, {_MinX, _MaxX}]) when MinZ > MaxZ ->
  ok;
init_z([{MinZ, MaxZ}, {MinY, MaxY}, {MinX, MaxX}]) ->
  init_y([{MinZ, MaxZ}, {MinY, MaxY}, {MinX, MaxX}]),
  init_z([{MinZ + 1, MaxZ}, {MinY, MaxY}, {MinX, MaxX}]).

init_y([{_MinZ, _MaxZ}, {MinY, MaxY}, {_MinX, _MaxX}]) when MinY > MaxY ->
  ok;
init_y([{MinZ, MaxZ}, {MinY, MaxY}, {MinX, MaxX}]) ->
  init_x([{MinZ, MaxZ}, {MinY, MaxY}, {MinX, MaxX}]),
  init_y([{MinZ, MaxZ}, {MinY + 1, MaxY}, {MinX, MaxX}]).

init_x([{_MinZ, _MaxZ}, {_MinY, _MaxY}, {MinX, MaxX}]) when MinX > MaxX ->
  ok;
init_x([{MinZ, MaxZ}, {MinY, MaxY}, {MinX, MaxX}]) ->
  utils_log:debug("[~p, ~p] init_x: ~p~n", [?MODULE, ?LINE, {MinZ, MinY, MinX}]),
  init_(MinZ, MinY, MinX),
  init_x([{MinZ, MaxZ}, {MinY, MaxY}, {MinX + 1, MaxX}]).
init_(Z, Y, X) ->
  NodeKey = matrix_node_id:get_id({Z, Y, X}),
  Timestamp = utils_tool:epoch_micro_ts(),
  NodeNext = [matrix_node_id:get_id({Z + 1, Y, X})],
  MatrixNodeJson = utils_json:encode([{node_state, 0}, {timestamp, Timestamp}, {next, NodeNext}]),
  matrix_database:put(NodeKey, MatrixNodeJson).

%%--------------------------------------------------------------------
%% @doc
%% Get node all informations
%% @end
%%--------------------------------------------------------------------
-spec get_node_info(tuple()) -> list().
get_node_info({_Z, _Y, _X} = Location) ->
  NodeId = matrix_node_id:get_id(Location),
  {ok, MatrixNode} = matrix_database:get(NodeId),
  utils_json:decode(MatrixNode).

%%--------------------------------------------------------------------
%% @doc
%% Get node state
%% @end
%%--------------------------------------------------------------------
-spec get_node_timestamp(tuple()) -> binary().
get_node_timestamp({_Z, _Y, _X} = Location) ->
  MatrixNodeProp = get_node_info(Location),
  proplists:get_value(<<"timestamp">>, MatrixNodeProp).

%%--------------------------------------------------------------------
%% @doc
%% Get node state
%% @end
%%--------------------------------------------------------------------
-spec get_node_state(tuple()) -> binary().
get_node_state({_Z, _Y, _X} = Location) ->
  MatrixNodeProp = get_node_info(Location),
  proplists:get_value(<<"node_state">>, MatrixNodeProp).

%%--------------------------------------------------------------------
%% @doc
%% Set node state
%% @end
%%--------------------------------------------------------------------
-spec set_node_state(tuple(), integer()) -> ok | {error, any()}.
set_node_state({_Z, _Y, _X} = Location, NodeState) ->
  NodeId = matrix_node_id:get_id(Location),
  {ok, MatrixNode} = matrix_database:get(NodeId),
  MatrixNodeProp = utils_json:decode(MatrixNode),
  NewMatrixNodeProp0 = [{<<"timestamp">>, utils_tool:epoch_micro_ts()} | proplists:delete(<<"timestamp">>, MatrixNodeProp)],
  NewMatrixNodeProp = [{<<"node_state">>, NodeState} | proplists:delete(<<"node_state">>, NewMatrixNodeProp0)],
  matrix_database:put(NodeId, utils_json:encode(NewMatrixNodeProp)).

%%--------------------------------------------------------------------
%% @doc
%% Update node state
%% @end
%%--------------------------------------------------------------------
-spec update_node_state(tuple()) -> ok | {error, any()}.
update_node_state({_Z, _Y, _X} = Location) ->
  NodeId = matrix_node_id:get_id(Location),
  {ok, MatrixNode} = matrix_database:get(NodeId),
  MatrixNodeProp = utils_json:decode(MatrixNode),
  NodeState = proplists:get_value(<<"node_state">>, MatrixNodeProp),
  NewNodeState = matrix_gen_rule:update_node_state(NodeState),
  NewMatrixNodeProp = [{<<"node_state">>, NewNodeState} | proplists:delete(<<"node_state">>, MatrixNodeProp)],
  matrix_database:put(NodeId, utils_json:encode(NewMatrixNodeProp)).


%%--------------------------------------------------------------------
%% @doc
%% Handle next nodes
%% @end
%%--------------------------------------------------------------------
-spec handle_next(tuple()) -> list().
handle_next(Location) ->
  NextNodes = get_next_nodes(Location),
  active_next_state(NextNodes).
%%--------------------------------------------------------------------
%% @doc
%% Get next nodes
%% @end
%%--------------------------------------------------------------------
-spec get_next_nodes(tuple()) -> list().
get_next_nodes({_Z, _Y, _X} = Location) ->
  MatrixNodeProp = get_node_info(Location),
  proplists:get_value(<<"next">>, MatrixNodeProp).

%%--------------------------------------------------------------------
%% @doc
%% Check if active next nodes
%% @end
%%--------------------------------------------------------------------
-spec check_if_active_next(tuple(), integer()) -> atom().
check_if_active_next(Location, Input) ->
  MatrixNodeProp = get_node_info(Location),
  Timestamp = proplists:get_value(<<"timestamp">>, MatrixNodeProp),
  NodeState = proplists:get_value(<<"node_state">>, MatrixNodeProp),
%%  utils_log:debug("[~p, ~p] check_if_active_next location: ~p, {timestamp, now, nodestate, input}: ~p,", [?MODULE, ?LINE, Location, {Timestamp, utils_tool:epoch_micro_ts(), NodeState, Input}]),
  matrix_gen_rule:active_rules(NodeState, Input, Timestamp).

%%--------------------------------------------------------------------
%% @doc
%% Active next node state
%% @end
%%--------------------------------------------------------------------
-spec active_next_state(list()) -> ok | {error, any()}.
active_next_state([]) ->
  ok;
active_next_state([NextNode | NextNodeList]) ->
  Location = matrix_node_id:get_zyx(NextNode),
  how_to_handle_next_node(check_if_active_next(Location, 1), Location),
  active_next_state(NextNodeList).

how_to_handle_next_node('add', Location) ->
%%  utils_log:debug("[~p, ~p] how_to_handle_next_node 'add': ~p", [?MODULE, ?LINE, Location]),
  update_node_state(Location);
how_to_handle_next_node('active', Location) ->
  utils_log:debug("[~p, ~p] how_to_handle_next_node 'active': ~p", [?MODULE, ?LINE, Location]),
  update_node_state(Location),
  handle_next(Location),
  set_node_state(Location, 0);
how_to_handle_next_node('reset', Location) ->
%%  utils_log:debug("[~p, ~p] how_to_handle_next_node 'reset': ~p", [?MODULE, ?LINE, Location]),
  set_node_state(Location, 1).





