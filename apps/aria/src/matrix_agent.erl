%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author yangchengjian
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. May 2019 10:08
%%%-------------------------------------------------------------------
-module(matrix_agent).
-author("yangchengjian").

-behaviour(gen_server).

%% API
-export([
  start_link/0, start_link/1,
  send/2
]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {location}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

-spec(start_link([{X :: integer(), Y :: integer()}]) ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link(AgentId) ->
  ZYX = matrix_agent_id:get_zyx(AgentId),
  gen_server:start_link({local, AgentId}, ?MODULE, [ZYX], []).

send([], _) ->
  ok;
send([Pid | PidList], Msg) ->
  erlang:send_after(10, Pid, Msg),
  send(PidList, Msg).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([Location]) ->
  {ok, #state{location = Location}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info({init, {MinZ, MaxZ}}, #state{location = {Z, Y, X}} = State) ->
  matrix_node:init_z([{MinZ, MaxZ}, {Y, Y + 9}, {X, X + 9}]),
  {noreply, State};
handle_info({data, List}, #state{location = Location} = State) ->
  update_10x10(Location, List),
  {noreply, State};
handle_info(Info, State) ->
  utils_log:debug("[~p, ~p] handle_info Info: ~p", [?MODULE, ?LINE, Info]),
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% update matrix
%% 7, 8, 9       y2x0, y2x1, y2x2
%% 4, 5, 6   ->  y1x0, y1x1, y1x2
%% 1, 2, 3       y0x0, y0x1, y0x2
update_10x10({_Z, Y, X}, List) ->
  loop(Y, X, List).

loop(Y, X, List) ->
  loop_y(Y, X, List, 0, 0).

%% update y
loop_y(_Y, _X, _List, 10, _IndexX) ->
  ok;
loop_y(Y, X, List, IndexY, IndexX) ->
  loop_x(Y, X, List, IndexY, IndexX),
  loop_y(Y, X, List, IndexY + 1, IndexX).

%% update x
loop_x(_Y, _X, _List, _IndexY, 10) ->
  ok;
loop_x(Y, X, List, IndexY, IndexX) when IndexY * 10 + IndexX < length(List) ->
  Value = lists:nth(IndexY * 10 + IndexX + 1, List),
  Location = {0, Y + IndexY, X + IndexX},
  matrix_node:set_node_state(Location, Value),
  if
    (Value rem 100) >= 80 ->
      matrix_node:handle_next(Location);
    true ->
      ok
  end,
  loop_x(Y, X, List, IndexY, IndexX + 1).
