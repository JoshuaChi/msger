-module(msger_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ConnectEvents = sockjs_handler:init_state(
                    <<"/connect">>, fun connect_callback/3, state, [{response_limit, 4096}]),
											
    Dispatch = cowboy_router:compile([
        {'_', [
					{"/", cowboy_static, {priv_file, msger, "index.html"}},
					{"/[...]", cowboy_static, {priv_dir, msger, "",
						[{mimetypes, cow_mimetypes, all}]}},
          {"/login/", msger_login_handler, []},
          {"/connect/[...]", sockjs_cowboy_handler, ConnectEvents}
        ]}
    ]),
    cowboy:start_http(msger_http_listener, 10000, [{port, 8080}],
        [
        {env, [{dispatch, Dispatch}]},
        {max_keepalive, 100}
        % {onrequest, fun cowboy_debug:onrequest_hook/1},
        % {onresponse, fun cowboy_debug:onresponse_hook/4}
        ]
    ),
    msger_sup:start_link().

stop(_State) ->
    ok.


%
% SockJS Events
%
connect_callback(_Con, init, _) -> 
	{ok, undefine};
connect_callback(Con, {recv, <<"I">>}, State) -> 
	ok = msger_broadcaster:add(Con),
	% lager:info("Joshua:~p", [State]),
	% Con:send(data_source:history()),
	{ok, State};
connect_callback(_Con, {recv, _Data}, State) -> 
  % lager:info("Receive Data: ~p~n", [Data]),
	{ok, State};
connect_callback(Con, closed, State) -> 
	msger_broadcaster:remove(Con),
	{ok, State}.