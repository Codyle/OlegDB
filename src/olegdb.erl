%%% The MIT License (MIT)
%%% 
%%% Copyright (c) 2014 Quinlan Pfiffer, Kyle Terry
%%% 
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%% 
%%% The above copyright notice and this permission notice shall be included in
%%% all copies or substantial portions of the Software.
%%% 
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%%% THE SOFTWARE.
-module(olegdb).
-include("olegdb.hrl").
-export([main/0]).

-define(LISTEN_PORT, 8080).

server_manager(Port) ->
    case gen_tcp:listen(Port, [binary, {active, false}, {reuseaddr, true}]) of
        {ok, Sock} ->
            io:format("[-] Listening on port ~p~n", [?LISTEN_PORT]),
            do_accept(Sock);
        {error, Reason} ->
            io:format("[X] Could not listen: ~p~n", [Reason])
    end.

%% Responsible for accepting new connections and spawning request handlers.
do_accept(Sock) ->
    case gen_tcp:accept(Sock) of
        {ok, Accepted} ->
            io:format("[-] Connection accepted!~n"),
            spawn(fun() -> request_handler(Accepted) end),
            do_accept(Sock);
        {error, Error} ->
            io:format("[X] Could not accept a connection. Error: ~p~n", [Error])
    end.

request_handler(Accepted) ->
    % Read in all data, timeout after 60 seconds
    case gen_tcp:recv(Accepted, 0, 60000) of
        {ok, Data} ->
            case gen_tcp:send(Accepted, route(Data)) of
                ok -> request_handler(Accepted);
                {error, Reason} ->
                    io:format("[-] Could not send to socket: ~p~n", [Reason])
            end;
        {error, closed} ->
            ok;
        {error, timeout} ->
            io:format("[-] Client timed out.~n"),
            ok
    end.

route(Bits) ->
    case Bits of
        <<"GET", _/binary>> ->
            Header = ol_parse:parse_http(Bits),
            case ol_database:ol_unjar(Header) of
                {ok, Data} -> ol_http:get_response(Data);
                _ -> ol_http:not_found_response()
            end;
        <<"POST", _/binary>> ->
            Header = ol_parse:parse_http(Bits),
            case ol_database:ol_jar(Header) of
                ok -> ol_http:post_response();
                _ -> ol_http:not_found_response()
            end;
        <<"DELETE", _/binary>> ->
            Header = ol_parse:parse_http(Bits),
            case ol_database:ol_scoop(Header) of
                ok -> ol_http:deleted_response();
                _ -> ol_http:not_found_response()
            end;
        _ ->
            ol_http:not_found_response()
    end.

main() ->
    io:format("[-] Starting server.~n"),
    ol_database:start(),
    server_manager(?LISTEN_PORT).
