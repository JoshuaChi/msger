-module(msger_worker).

-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).
-export([balance_conn/1]).         

-record(state, {conns, threshold}).

-include("msger.hrl").

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

%% for mongodb, slave connection, one pool manager several Conns
init(_Args) ->
    process_flag(trap_exit, true),

    {ok, #state{conns=[]}}.

handle_call({login, UserName}, 
_From, #state{conns=_Conns}=State) ->
	  
    % PartitionCounter = case Pid of
    %   none ->
    %     io:format("collection:~p type:~p~n", [Collection, type_of(Collection)]),
    %     get_partition_counter(Collection);
    %   _ ->
    %     Pid
    %   end,
    %
    % io:format("Collection:~p, PartitionCounter:~p, PartitionThreshold:~p~n",
    %   [Collection, PartitionCounter, PartitionThreshold]),
    %
    % Partition = select_partition_with_level(Collection, PartitionCounter, PartitionThreshold, Level),
    %
    % Result = do_find(Conn, Partition, Selector, Projector, Skip, Limit),
    io:format("UserName:~p", [UserName]),
    {reply, ok, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{conns=_Conns}) ->
    % ok = mongo_connect:close(Conn),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
    
%%%---private function---%%%

% type_of(X) when is_integer(X)   -> integer;
% type_of(X) when is_float(X)     -> float;
% type_of(X) when is_list(X)      -> list;
% type_of(X) when is_tuple(X)     -> tuple;
% type_of(X) when is_bitstring(X) -> bitstring;  % will fail before e12
% type_of(X) when is_binary(X)    -> binary;
% type_of(X) when is_boolean(X)   -> boolean;
% type_of(X) when is_function(X)  -> function;
% type_of(X) when is_pid(X)       -> pid;
% type_of(X) when is_port(X)      -> port;
% type_of(X) when is_reference(X) -> reference;
% type_of(X) when is_atom(X)      -> atom;
% type_of(_X)                     -> unknown.

balance_conn(ConnList) ->
	Index = random:uniform(length(ConnList)),
	lists:nth(Index, ConnList).