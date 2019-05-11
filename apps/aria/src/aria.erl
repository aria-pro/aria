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
  init_with_agent/1
]).


init_with_agent({MinZ, MaxZ}) when MinZ > MaxZ ->
  ok;
init_with_agent({MinZ, MaxZ}) ->
  PidList = matrix_agent_id:get_ids([{0, 99}, {0, 99}]),
  utils_log:debug("[~p, ~p] init_with_agent PidList {Z, Y, X}: ~p", [?MODULE, ?LINE, PidList]),
  matrix_agent:send(PidList, {init, {MinZ, MaxZ}}).

