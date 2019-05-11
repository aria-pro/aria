%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author captcha
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Sep 2017 下午2:02
%%%-------------------------------------------------------------------
-module(matrix_entry).
-author("captcha").

%% API
-export([
  split_10x10/1,
  test/0
]).

%% sort like
%% 7,8,9,
%% 4,5,6,
%% 1,2,3,

split_10x10(List) ->
  Fun = fun(I) ->
    List100 = lists:sublist(List, I, 100),
%%    utils_log:debug("[~p, ~p] split_10x10 X: ~p, List100: ~p", [?MODULE, ?LINE, I, List100]),
    Index = I div 100,
    Y = Index div 10,
    X = Index rem 10,
%%    utils_log:debug("[~p, ~p] split_10x10 index Y X: ~p", [?MODULE, ?LINE, {Index, Y, X}]),
    {Y, X, List100}
        end,
  lists:map(Fun, lists:seq(1, 10000, 100)).

%%generate_matrix(Y, X, Result) when Y =:= 0 ->
%%  Result;
%%generate_matrix(Y, X, Result) ->
%%  R = generate_matrix_(X, []),
%%%%  utils_log:debug("[~p, ~p] test R: ~p", [?MODULE, ?LINE, R]),
%%  generate_matrix(Y - 1, X, lists:merge(R, Result)).
%%
%%generate_matrix_(X, Result) when X =:= 0 ->
%%  Result;
%%generate_matrix_(X, Result) ->
%%  generate_matrix_(X - 1, [rand:uniform(100) | Result]).



test() ->
%%  List = generate_matrix(100, 100, []),
  List = lists:seq(1, 10000),
%%  utils_log:debug("[~p, ~p] test List: ~p", [?MODULE, ?LINE, List]),
  List1 = split_10x10(List),
%%  utils_log:debug("[~p, ~p] test List: ~p", [?MODULE, ?LINE, List1]),
  send(List1).

send([]) ->
  ok;
send([{Y, X, List100} | List]) ->
  erlang:send_after(10, matrix_agent_id:get_id({Y * 10, X * 10}), {data, List100}),
  send(List).