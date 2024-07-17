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
    ok=host_server_test(),
    ok=deployment_server_test(),
    ok=application_server_test(),    
    ok=controller_test(),
    timer:sleep(2000),
    io:format("Test OK !!! ~p~n",[?MODULE]),
    LogStr=os:cmd("cat "++?LogFile),
    L1=string:lexemes(LogStr,"\n"),
    [io:format("~p~n",[Str])||Str<-L1],

    rpc:call(?Vm,init,stop,[],5000),
    timer:sleep(4000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
controller_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    %% Clean up before test 
    
    rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),
    rpc:call(?Vm,application_server,unload_app,["adder3.application"],5000),

    %%


    %Load and start adder3
    {error,["Not started ","adder3.application"]}=rpc:call(?Vm,controller,stop_unload,["adder3.application"],3*5000),
    ok=rpc:call(?Vm,controller,load_start,["adder3.application"],3*5000),
    AppVm=adder3@c50,
    42=rpc:call(AppVm,adder3,add,[20,22],5000),
    
    {error,["Already loaded ","adder3.application"]}=rpc:call(?Vm,controller,load_start,["adder3.application"],3*5000),
    ok=rpc:call(?Vm,controller,stop_unload,["adder3.application"],3*5000),
    pang=net_adm:ping(AppVm),
    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
application_server_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    %% Clean up before test 
   rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),
   rpc:call(?Vm,application_server,unload_app,["adder3.application"],5000),

    pong=rpc:call(?Vm,application_server,ping,[],5000),
    {ok,AllFilenames}=rpc:call(?Vm,application_server,all_filenames,[],5000),
    ["adder.application_old","adder3.application",
     "divi.application_old","kvs.application",
     "kvs.application_old","log2.application_old",
     "log2.application~","main.application_old",
     "phoscon.application_old","zigbee.application_old"]=lists:sort(AllFilenames),
    {ok,"Repo is up to date"}=rpc:call(?Vm,application_server, update,[],5000),

    %Load and start adder3

    {error,["Not loaded ","adder3.application"]}=rpc:call(?Vm,application_server,start_app,["adder3.application"],5000),
    {error,["Not started ","adder3.application"]}=rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),
    {error,["Not loaded ","adder3.application"]}=rpc:call(?Vm,application_server,unload_app,["adder3.application"],5000),
    
    pong=rpc:call(?Vm,application_server,ping,[],5000),

    ok=rpc:call(?Vm,application_server,load_app,["adder3.application"],2*5000),
    {error,["Not started ","adder3.application"]}=rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),

    ok=rpc:call(?Vm,application_server,start_app,["adder3.application"],3*5000),
    AppVm=adder3@c50,
    42=rpc:call(AppVm,adder3,add,[20,22],5000),
    
    {error,["Already loaded ","adder3.application"]}=rpc:call(?Vm,application_server,load_app,["adder3.application"],5000),
    {error,[" Application started , needs to be stopped ","adder3.application"]}=rpc:call(?Vm,application_server,unload_app,["adder3.application"],5000),

    ok=rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),
    pang=net_adm:ping(AppVm),
    {error,["Not started ","adder3.application"]}=rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),
    {error,["Already loaded ","adder3.application"]}=rpc:call(?Vm,application_server,load_app,["adder3.application"],5000),
    ok=rpc:call(?Vm,application_server,unload_app,["adder3.application"],5000),
    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
deployment_server_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    pong=rpc:call(?Vm,deployment_server,ping,[],5000),
    {ok,AllFilenames}=rpc:call(?Vm,deployment_server,all_filenames,[],5000),
    ["adder3.deployment","kvs.deployment","log2.deployment","log2.deployment~","phoscon_zigbee.deployment"]=lists:sort(AllFilenames),
    [{"adder3.application","c50"}]=lists:sort(rpc:call(?Vm,deployment_server, get_applications_to_deploy,[],5000)),
   
    {ok,"Repo is up to date"}=rpc:call(?Vm,deployment_server, update,[],5000),
  
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
host_server_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    pong=rpc:call(?Vm,host_server,ping,[],5000),
   {ok,AllFilenames}=rpc:call(?Vm,host_server,all_filenames,[],5000),
    ["c200.host","c201.host","c202.host","c230.host","c50.host"]=lists:sort(AllFilenames),
    ['ctrl@c200','ctrl@c201','ctrl@c202','ctrl@c230','ctrl@c50']=lists:sort(rpc:call(?Vm,host_server, get_host_nodes,[],5000)),
    []=rpc:call(?Vm,host_server, get_application_config,[],5000),
    {ok,"Repo is up to date"}=rpc:call(?Vm,host_server, update,[],5000),
  
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

erlport_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    {ok, P} = rpc:call(?Vm,python,start,[],5000),
    Msg=rpc:call(?Vm,python,call,[P, version, version, []]),
    io:format("Msg ~p~n",[{Msg,?MODULE,?LINE,?FUNCTION_NAME}]),
    ok.

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
    
%    io:format("~p~n",[os:cmd("cat "++?LogFile)]),
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.
