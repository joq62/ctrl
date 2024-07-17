%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2024, c50
%%% @doc
%%%
%%% @end
%%% Created : 11 Jan 2024 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(lib_controller).
  

-include("controller.hrl").
  
%% API
-export([
	 load_start/1,
	 stop_unload/1

	
	]).

-export([
	 connect_nodes/0,
	 connect/1
	]).

%%%===================================================================
%%% API
%%%===================================================================
connect_nodes()->
  

    AllHostNodes=host_server:get_host_nodes(),
  %  CookieStr=atom_to_list(erlang:get_cookie()),
 %   NodeName=?ConnectModule++"_"++CookieStr,
 %   NodeName=?ConnectModule,
  %  ConnectNodes=[list_to_atom(NodeName++"@"++HostName)||HostName<-AllHostNames],
    Pong=[{N,net_adm:ping(N)}||N<-AllHostNodes],
    Pong.
%%--------------------------------------------------------------------
%% @doc
%% 
%% 
%% @end
%%--------------------------------------------------------------------
connect(Sleep)->
    connect_nodes(),
    timer:sleep(Sleep),
    rpc:cast(node(),controller,connect,[]).
%%--------------------------------------------------------------------
%% @doc
%% 
%% 
%% @end
%%--------------------------------------------------------------------
load_start(ApplicationFileName)->
    Result=case application_server:load_app(ApplicationFileName) of
	       ok->
		   case application_server:start_app(ApplicationFileName) of
		       ok->
			   ok;
		       Error->
			   Error
		   end;
	       Error->
		   Error
	   end,
    Result.								 
    
%%--------------------------------------------------------------------
%% @doc
%% 
%% 
%% @end
%%--------------------------------------------------------------------
stop_unload(ApplicationFileName)->
    Result=case application_server:stop_app(ApplicationFileName) of
	       ok->
		   case application_server:unload_app(ApplicationFileName) of
		       ok->
			   ok;
		       Error->
			   Error
		   end;
	       Error->
		   Error
	   end,
    Result.


%%%===================================================================
%%% Internal functions
%%%===================================================================
