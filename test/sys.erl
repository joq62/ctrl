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
-module(sys).      
 
-export([start/0]).

-define(TargetDir,"ctrl_dir").
-define(Vm,ctrl@c50).
-define(TarFile,"ctrl.tar.gz").
-define(App,"ctrl").
-define(TarSrc,"release"++"/"++?TarFile).
-define(StartCmd,"./"++?TargetDir++"/"++"bin"++"/"++?App).

-define(LogFile,"ctrl_dir/logs/ctrl/log.logs/test_logfile.1").

-define(AppVm,adder3@c50).
-define(AdderApp,adder3).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=setup(),
    ok=load_start_release(),
 %   ok=host_server_test(),
 %   ok=deployment_server_test(),
 %   ok=application_server_test(),    
 %   ok=controller_test(),

    ok=reconciliation_test(),

    timer:sleep(2000),
    io:format("Test OK !!! ~p~n",[?MODULE]),
    LogStr=os:cmd("cat "++?LogFile),
    L1=string:lexemes(LogStr,"\n"),
    [io:format("~p~n",[Str])||Str<-L1],

  %  rpc:call(?Vm,init,stop,[],5000),
  %  timer:sleep(4000),
  %  init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
reconciliation_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

   
    LogStr=os:cmd("cat "++?LogFile),
    L1=string:lexemes(LogStr,"\n"),
    [io:format("~p~n",[Str])||Str<-L1],
    loop(L1),
    

    ok.


loop(State)->
    
    LogStr=os:cmd("cat "++?LogFile),
    L1=string:lexemes(LogStr,"\n"),
    if
	L1=:=State->
	    NewState=State;
	true->
	    NewState=L1,
	    [io:format("~p~n",[Str])||Str<-L1,
				      false==lists:member(Str,State)]
    end,
    timer:sleep(5000),
    loop(NewState).

deploy([],Acc)->
    Acc;
deploy([Filename|T],Acc)->
    Result=rpc:call(?Vm,controller,load_start,[Filename],3*5000),
    deploy(T,[{Result,Filename}|Acc]).



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


load_start_release()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    %% Delete ad_rel dir used for tar, stop Vm
    file:del_dir_r(?TargetDir),
    rpc:call(?Vm,init,stop,[],3000),
    timer:sleep(2000),
    
    %%
    ok=file:make_dir(?TargetDir),
    []=os:cmd("tar -zxf "++?TarSrc++" -C "++?TargetDir),
    
    %%
    []=os:cmd(?StartCmd++" "++"daemon"),
    timer:sleep(1000),
    pong=net_adm:ping(?Vm),
    pong=rpc:call(?Vm,rd,ping,[],5000),
    pong=rpc:call(?Vm,log,ping,[],5000),
    pong=rpc:call(?Vm,deployment_server,ping,[],2*5000),
    pong=rpc:call(?Vm,host_server,ping,[],5000),
    pong=rpc:call(?Vm,application_server,ping,[],3*5000),  
    pong=rpc:call(?Vm,git_handler,ping,[],5000),  
    pong=rpc:call(?Vm,controller,ping,[],10*5000),


    AllApps=rpc:call(?Vm,application,which_applications,[],6000),
    io:format("AllApps ~p~n",[{AllApps,?MODULE,?LINE,?FUNCTION_NAME}]),
    {ok,Cwd}=rpc:call(?Vm,file,get_cwd,[],6000),
    io:format("Cwd ~p~n",[{Cwd,?MODULE,?LINE,?FUNCTION_NAME}]),
    {ok,Filenames}=rpc:call(?Vm,file,list_dir,[Cwd],6000),
    io:format("Filenames ~p~n",[{Filenames,?MODULE,?LINE,?FUNCTION_NAME}]),
    AbsName=rpc:call(?Vm,code,where_is_file,["python.beam"],6000),
    io:format("AbsName ~p~n",[{AbsName,?MODULE,?LINE,?FUNCTION_NAME}]),
     %% Clean up before test 
    
    rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),
    rpc:call(?Vm,application_server,unload_app,["adder3.application"],5000),

    %%


%    io:format("~p~n",[os:cmd("cat "++?LogFile)]),
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok=application:start(rd),
    ok=initial_trade_resources(),
    
    ok.


initial_trade_resources()->
    [rd:add_local_resource(ResourceType,Resource)||{ResourceType,Resource}<-[]],
    [rd:add_target_resource_type(TargetType)||TargetType<-[controller,adder3]],
    rd:trade_resources(),
    timer:sleep(3000),
    ok.
