%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author captcha
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Sep 2017 下午4:13
%%%-------------------------------------------------------------------
-module(matrix_node_state).
-author("captcha").

%% API
-export([
    get_state/1,
    get_zyx/1
]).

%% @doc
%% according to X, Y, Z get a key for save data
%% @end
-spec get_state(tuple()) -> binary().
get_state({Z, Y, X}) ->
    <<Z:16/integer, Y:16/integer, X:16/integer>>.

%% @doc
%% according to Key get x, y, z
%% @end
-spec get_zyx(binary()) -> tuple().
get_zyx(<<Z:16/integer, Y:16/integer, X:16/integer>>) ->
    {Z, Y, X};
get_zyx(Key) ->
    utils_log:debug("[~p, ~p] get_zyx Key : ~p", [?MODULE, ?LINE, Key]),
    {0, 0, 0}.
