-module(msger_login_handler).

-export([init/3]).
-export([allowed_methods/2, resource_exists/2, content_types_accepted/2]).
-export([do_login/2]).

init(_, _Req, _Opts) ->
	{upgrade, protocol, cowboy_rest}.


%% Only POST is allowed as REST
allowed_methods(Req, State) ->
  {[<<"POST">>], Req, State}.

resource_exists(Req, State) ->
  {false, Req, State}.

content_types_accepted(Req, State) ->
  {[{<<"application/bson">>, do_login}], Req, State}.
    
do_login(Req, State) ->
  {ok, BinaryBody, _} = cowboy_req:body(Req),
  {Document, <<>>} = bson_binary:get_document(BinaryBody),
  UserName = bson:at(name, Document),

  Result = msger_sup:login(
    "msger_pool", 
    UserName),
		
  Body = jiffy:encode({[{<<"result">>,atom_to_binary(Result, utf8)}]}),
  
  Req2 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Req),
  Req3 = cowboy_req:set_resp_body(Body, Req2),
  {true, Req3, State}.
