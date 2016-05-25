-module(msger_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([login/2]).

-include("msger.hrl").

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================


init([]) ->
	Name=msger_pool,
	PoolArgs = [{name,{local,msger_pool}},
	                          {worker_module,msger_worker},
	                          {size,5},
	                          {max_overflow,1}],
	WorkerArgs = [],
	B = {msger_broadcaster, {msger_broadcaster, start, []}, permanent, 10000, worker, dynamic},
	PoolSpecs = [B, poolboy:child_spec(Name, PoolArgs, WorkerArgs)],
  % PoolSpecs = lists:map(
  %   fun({Name, SizeArgs, WorkerArgs}) ->
  %     PoolArgs = [{name, {local, Name}}, {worker_module, msger_worker}] ++ SizeArgs,
  % 			io:format("PoolArgs:~p~n", [PoolArgs]),
  % 			io:format("Name:~p|PoolArgs:~p|WorkerArgs:~p~n", [Name, PoolArgs, WorkerArgs]),
  %
  %     poolboy:child_spec(Name, PoolArgs, WorkerArgs)
  % end, Pools),
  %{RestartStrategy, MaxRestart, MaxTime}
	{ok, { {one_for_one, 5, 10}, PoolSpecs} }.

login({PoolName}, UserName) ->
    poolboy:transaction(PoolName, fun(Worker) ->
        gen_server:call(Worker, {
          login, UserName
        }, ?CLIENT_TIMEOUT)
    end, ?CLIENT_TIMEOUT).
