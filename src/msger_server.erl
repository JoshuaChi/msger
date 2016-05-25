-module(msger_server).

-export([
   init/1
]).

init(Path) ->
    sockjs_handler:init_state(Path, fun handle/3, #{}, []).

handle(_Conn, E, State) ->
   io:format("ev: ~p~n", [E]),
   {ok, State}.