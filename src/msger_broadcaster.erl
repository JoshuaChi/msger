-module(msger_broadcaster).
-behaviour(gen_server).

-export([add/1, remove/1, send/2]).
-export([start/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


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
  mnesia:wait_for_tables([
		user, 
		user_friends, 
		user_resources], 3000),
	{ok, []}.

handle_call({add, Con}, _From, State) ->
	{reply, ok, State ++ [Con]};

handle_call({remove, Con}, _From, State) -> 
	{reply, ok, State -- [Con]};

handle_call({msg, FromCon, Msg}, _From, State) -> 
	lists:map(
		fun(C) -> 
			if 
				C == FromCon ->
					do_nothing;
				true -> 
					C:send(Msg) 
			end
		end, State),
	{reply, ok, State};

handle_call(_Msg, _From, State) -> {reply, ok, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) ->  {noreply, State}.

terminate(_Reason, State) -> 
	lists:map(fun(C) -> C:close() end, State),
	ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.


