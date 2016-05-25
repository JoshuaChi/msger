-module(msger_broadcaster).
-behaviour(gen_server).

-export([add/1, remove/1, send/2]).
-export([start/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {connections=[]}).

add(Con) -> 
	gen_server:call(?MODULE, {add, Con}).
remove(Con) -> 
	gen_server:call(?MODULE, {remove, Con}).
send(FromCon, Msg) -> 
  io:format("Sending:~p~n", [Msg]),
	gen_server:call(?MODULE, {msg, FromCon, Msg}).

%
% genserver
%

start() -> 
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  process_flag(trap_exit, true),
	{ok, #state{}}.

handle_call({add, Con}, _From, #state{connections=Connections}) ->
	NewConns = Connections ++ [Con],
	{reply, ok, #state{connections=NewConns} };

handle_call({remove, Con}, _From, #state{connections=Connections}) -> 
  NewConns = Connections -- [Con],
	{reply, ok, #state{connections=NewConns} };

handle_call({msg, FromCon, Msg}, _From, #state{connections=Connections}=State) -> 
  io:format("I am handing message:~p, Connections:~p~n", [Msg, Connections]),
	[UserName, ResourceId] = parseConn(FromCon),
	io:format("UserName:~p, ResourceId: ~p, Msg: ~p~n", [UserName, ResourceId, Msg]),		
	Message=lists:concat(["{\"user\":\"", UserName, "\", \"resource\":\"", ResourceId, "\", \"data\": \"", binary_to_list(Msg), "\"}"]),
	io:format("Message:~p~n", [Message]),
	lists:map(
		fun(C) -> 
			if 
				C == FromCon ->
					do_nothing;
				true ->
					C:send(Message)
			end
		end, Connections),
	io:format("State:~p~n", [State]),
	{reply, ok, State};

handle_call(_Msg, _From, State) -> {reply, ok, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) ->  {noreply, State}.

terminate(_Reason, State) -> 
	lists:map(fun(C) -> C:close() end, State),
	ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

parseConn(Conn) ->
	io:format("Iam here: ~p~n", [Conn]),
	case Conn of
		{sockjs_session,{_, List}} ->
			Path = proplists:get_value(path, List),
			[_, ResourceId, UserName, _] = string:tokens(Path, "/");
		_ ->
			UserName="", 
			ResourceId=""
	end,
	[UserName, ResourceId].


