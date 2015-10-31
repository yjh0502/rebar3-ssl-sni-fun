-module(test).

-compile([export_all]).

start() ->
    ssl:start(),
    {ok, ListenSocket} = ssl:listen(23468, [{reuseaddr, true}, {sni_fun, fun ?MODULE:sni_fun/1}]),
    spawn_link(fun() -> loop(ListenSocket) end).

start_hang() ->
    ssl:start(),
    {ok, ListenSocket} = ssl:listen(23468, [{reuseaddr, true}, {sni_fun, fun ?MODULE:sni_log_fun/1}]),
    spawn_link(fun() -> loop(ListenSocket) end).

loop(ListenSocket) ->
    {ok, Socket} = ssl:transport_accept(ListenSocket),
    ok = ssl:ssl_accept(Socket),
    ssl:send(Socket, <<"hello\n">>),
    ssl:close(Socket),
    loop(ListenSocket).

sni_fun(_Hostname) ->
    [
        {certfile, "key/cert.pem"},
        {keyfile, "key/key.pem"}
    ].

sni_log_fun(Hostname) ->
    io:format("hostname: ~p~n", [Hostname]),
    sni_fun(Hostname).
