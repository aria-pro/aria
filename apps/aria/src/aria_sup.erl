%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%% @doc aria top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(aria_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  MatrixDatabase = child(matrix_database_rocksdb),
  MatrixCube = child(matrix_cube),
  MatrixAgents = agents(),
  Childs = lists:merge([MatrixDatabase, MatrixCube], MatrixAgents),
  {ok, {{one_for_all, 0, 1}, Childs}}.

%%====================================================================
%% Internal functions
%%====================================================================
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
child(Id) ->
  {Id, {Id, start_link, []}, permanent, 5000, worker, [Id]}.

agents() ->
  agents(matrix_agent_id:get_ids([{0, 999}, {0, 999}]), []).

agents([], Result) ->
  Result;
agents([AgentId | AgentIdList], Result) ->
  MatrixAgent = {AgentId, {matrix_agent, start_link, [AgentId]}, permanent, 5000, worker, []},
  agents(AgentIdList, [MatrixAgent | Result]).