%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at https://mozilla.org/MPL/2.0/. */
%%%-------------------------------------------------------------------
%%% @author captcha
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Sep 2017 下午1:56
%%%-------------------------------------------------------------------
-module(utils_tool).
-author("captcha").

-define(EPOCH_DIFF, 62167219200).

%% API
%% System Level
-export([uuid/0]).
-export([seconds/0, local_milli_seconds/0, milli_seconds/0]).
-export([utc_now/0, utc/1, epoch_utc_now/0, epoch_utc/1, epoch_now/0, epoch_micro_ts/0]).

%% Language Level
-export([to_binary/1, to_integer/1, to_list/1, to_atom/1]).
-export([hash_to_string/1, md5_hex/1]).
-export([proplists_delete/2]).
-export([delete_nth_list/2]).
-export([get_list_len/1]).
-export([extract_values/2, extract_values/3, create_string/1]).
-export([list_to_string/2]).
%%% ==================================================================
%%% SYSTEM LEVEL
%%% ==================================================================
%%  @doc
%%  功能：生成uuid
%%  @end
-spec uuid() -> binary().
uuid() ->
    list_to_binary(uuid:to_string(uuid:uuid1())).

%%  @doc
%%  功能：系统时间（单位：秒）
%%  @end
-spec seconds() -> integer().
seconds() ->
    erlang:system_time(seconds).


local_milli_seconds() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    1000000000 * MegaSecs + Secs * 1000 + MicroSecs div 1000.

%%  @doc
%%  功能：系统时间（单位：毫秒）
%%  @end
-spec milli_seconds() -> integer().
milli_seconds() ->
    erlang:system_time(milli_seconds).

epoch_now() ->
    TS = {_, _, Micro} = os:timestamp(),
    {{Y, M, D}, {H, MM, S}} = calendar:now_to_local_time(TS),
    iolist_to_binary(io_lib:format("~4.4.0w-~2.2.0w-~2.2.0wT~2.2.0w:~2.2.0w:~2.2.0w.~3.3.0wZ", [Y, M, D, H, MM, S, trunc(Micro / 1000)])).

utc_now() ->
    utc(os:timestamp()).

utc(Now = {_, _, Micro}) ->
    {{Y, M, D}, {H, MM, S}} = calendar:now_to_universal_time(Now),
    iolist_to_binary(io_lib:format("~4.4.0w-~2.2.0w-~2.2.0wT~2.2.0w:~2.2.0w:~2.2.0w.~3.3.0wZ", [Y, M, D, H, MM, S, trunc(Micro / 1000)])).

epoch_utc_now() ->
    epoch_utc(os:timestamp()).

epoch_utc(Now) ->
    calendar:datetime_to_gregorian_seconds(calendar:now_to_universal_time(Now)) - ?EPOCH_DIFF.

epoch_micro_ts() ->
    T = {_, _, Micro} = os:timestamp(),
    epoch_utc(T) * 1000 + trunc(Micro / 1000).

%%% ==================================================================
%%% LANGUAGE LEVEL
%%% ==================================================================
%%  @doc
%%  功能：转为binary
%%  @end
-spec to_binary(X) -> binary()
    when X :: atom()|integer()|list()|float()|binary().
to_binary(X) when is_atom(X) ->
    to_binary(atom_to_list(X));
to_binary(X) when is_integer(X) ->
    to_binary(integer_to_list(X));
to_binary(X) when is_float(X) ->
    float_to_binary(X);
to_binary(X) when is_list(X) ->
    list_to_binary(X);
to_binary(X) when is_binary(X) ->
    X.

%%  @doc
%%  功能：转为binary
%%  @end
-spec to_atom(X) -> atom()
    when X :: atom()|list()|binary().
to_atom(X) when is_binary(X) ->
    to_atom(binary_to_list(X));
to_atom(X) when is_list(X) ->
    list_to_atom(X);
to_atom(X) when is_atom(X) ->
    X.

%%  @doc
%%  功能：转为integer
%%  @end
-spec to_integer(X) -> binary()
    when X :: atom()|integer()|list()|float()|binary().
to_integer(X) when is_atom(X) ->
    to_integer(atom_to_list(X));
to_integer(X) when is_list(X) ->
    list_to_integer(X);
to_integer(X) when is_float(X) ->
    to_integer(float_to_binary(X));
to_integer(X) when is_binary(X) ->
    binary_to_integer(X);
to_integer(X) when is_integer(X) ->
    X.

%%  @doc
%%  功能：转为List
%%  @end
-spec to_list(X) -> binary()
    when X :: atom()|integer()|list()|float()|binary().
to_list(X) when is_atom(X) ->
    atom_to_list(X);
to_list(X) when is_binary(X) ->
    binary_to_list(X);
to_list(X) when is_integer(X) ->
    integer_to_list(X);
to_list(X) when is_float(X) ->
    float_to_list(X);
to_list(X) when is_list(X) ->
    X.

hash_to_string(HashBin) when is_binary(HashBin) ->
    lists:flatten(lists:map(
        fun(X) -> io_lib:format("~2.16.0b", [X]) end,
        binary_to_list(HashBin))).

md5_hex(S) ->
    Md5_bin = erlang:md5(S),
    Md5_list = binary_to_list(Md5_bin),
    lists:flatten(list_to_hex(Md5_list)).

list_to_hex(L) ->
    lists:map(fun(X) -> int_to_hex(X) end, L).

int_to_hex(N) when N < 256 ->
    [hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 ->
    $0 + N;
hex(N) when N >= 10, N < 16 ->
    $a + (N - 10).

-spec proplists_delete(Key, Proplists) -> NewProplists when
    Key :: atom() | [atom()],
    Proplists :: [{atom(), any()}],
    NewProplists :: [{atom(), any()}].
proplists_delete(Key, Proplists) when is_atom(Key) ->
    proplists:delete(Key, Proplists);
proplists_delete([], Proplists) ->
    Proplists;
proplists_delete([Key | KeyList], Proplists) ->
    proplists_delete(KeyList, proplists:delete(Key, Proplists)).


%% @doc delete the nth element of list
-spec delete_nth_list(integer(), list()) -> {list(), integer()}.
delete_nth_list(N, List) ->
    delete_nth_list(N, List, [], 1).

delete_nth_list(_N, [], NList, _Acc) ->
    lists:reverse(NList);

delete_nth_list(N, [H | T], NList, Acc) when Acc =/= N ->
    delete_nth_list(N, T, [H | NList], Acc + 1);

delete_nth_list(N, [_H | T], NList, Acc) when Acc =:= N ->
    delete_nth_list(N, T, NList, Acc + 1).

get_list_len(Server_list) ->
    get_list_len(Server_list, 0).

get_list_len([], Acc) ->
    Acc;

get_list_len([_H | T], Acc) ->
    get_list_len(T, Acc + 1).

extract_values(Fields, Proplist) ->
    extract_values(Fields, Proplist, undefined).

extract_values(Fields, Proplist, Default) ->
    extract_values(Fields, Proplist, Default, []).

extract_values([], _, _, Ret) ->
    Ret;
extract_values([Field | Rest], Proplist, Default, Ret) ->
    Value = proplists:get_value(Field, Proplist, Default),
    extract_values(Rest, Proplist, Default, Ret ++ [Value]).

create_string(Keywords) ->
    create_string(Keywords, "").

create_string([], Return) ->
    Return;
create_string([Keyword | Rest], Return) ->
    create_string(Rest, Return ++ to_list(Keyword)).

%%  @doc
%%  Function: list_to_string with special seperator
%%  @end
-spec list_to_string(List :: list(), Seperator :: string()) -> string().
list_to_string(List, Seperator) ->
    string:join([I || I <- List], Seperator).


