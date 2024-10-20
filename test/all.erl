%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(all).      
 
-export([start/0]).

-define(StartCtrl,"./_build/default/rel/ctrl/bin/ctrl daemon").

-define(Vm,node()).
-define(CompileServerVm,?Vm).
-define(App,"ctrl").
-define(LogFile,"logs/test_ctrl/log.logs/test_logfile.1").


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("").
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=setup(),


    timer:sleep(2000),
    io:format("Test OK !!! ~p~n",[?MODULE]),
 %   LogStr=os:cmd("cat "++?LogFile),
 %   L1=string:lexemes(LogStr,"\n"),
 %   [io:format("~p~n",[Str])||Str<-L1],


%    timer:sleep(4000),
%    init:stop(),
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    
    ok=application:start(ctrl),
    timer:sleep(2000),
    pong=log:ping(),
    pong=rd:ping(),
    pong=application_server:ping(),
    pong=host_server:ping(),
    pong=main_controller:ping(),
    ok.
