%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author mike
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Oct 2017 4:41 PM
%%%-------------------------------------------------------------------
-module(matrix_gen_rule).
-author("mike").

%% API
-export([
  active_rules/3,
  update_node_state/1
]).

active_rules(NodeState, Input, Timestamp) ->
  Now = utils_tool:epoch_micro_ts(),
  active_rule(NodeState, Input, Timestamp, Now).

active_rule(_NodeState, _Input, Timestamp, Now) when (Timestamp + 60000) =< Now ->
  'reset';
active_rule(NodeState, Input, _Timestamp, _Now) when (NodeState + Input) >= 5 ->
  'active';
active_rule(_NodeState, _Input, _Timestamp, _Now) ->
  'add'.

update_node_state(NodeState) ->
  NodeState + 1.



