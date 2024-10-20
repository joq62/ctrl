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
-define(LogFile,"logs/ctrl/log.logs/test_logfile.1").

-define(AdderVm,adder3@c50).
-define(AdderApp,adder3).
-define(AdderApplication,"adder3").
-define(AdderGitPath,"https://github.com/joq62/adder3.git").
-define(AdderApplicationDir,"adder3").
-define(AdderReleaseFile,"adder3/_build/default/rel/adder3/bin/adder3").


-define(TemplateVm,temp@c50).
-define(TemplateApp,temp).
-define(TemplateApplication,"temp").
-define(TemplateGitPath,"https://github.com/joq62/template.git").
-define(TemplateApplicationDir,"template").
-define(TemplateReleaseFile,"template/_build/default/rel/temp/bin/temp").

%% 
-define(AddTestVm,add_test@c50).
-define(AddTestApp,add_test).
-define(AddTestApplication,"add_test").
-define(AddTestGitPath,"https://github.com/joq62/add_test.git").
-define(AddTestApplicationDir,"add_test").
-define(AddTestReleaseFile,"add_test/_build/default/rel/add_test/bin/add_test").

-define(KvsTestVm,kvs_test@c50).
-define(KvsTestApp,kvs_test).
-define(KvsTestApplication,"kvs_test").
-define(KvsTestGitPath,"https://github.com/joq62/kvs_test.git").
-define(KvsTestApplicationDir,"kvs_test").
-define(KvsTestReleaseFile,"kvs_test/_build/default/rel/kvs_test/bin/kvs_test").




-define(KvsVm,kvs@c50).
-define(KvsApp,kvs).
-define(KvsApplication,"kvs").
-define(KvsGitPath,"https://github.com/joq62/kvs2.git").
-define(KvsApplicationDir,"kvs2").
-define(KvsReleaseFile,"kvs2/_build/default/rel/kvs/bin/kvs").


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
%    ok=rpc:call(?Vm,test_git_handler,start,[],3*5000), 
    ok=rpc:call(?Vm,test_application_server,start,[],3*5000), 

 %   ok=compile_template_test(),
 %   ok=add_test_test(),
 %   ok=kvs_test_test(),

    %%
 %   ok=host_server_test(),
 %   ok=deployment_server_test(),
 %   ok=application_server_test(),  
 %   ok=compiler_server_test(),
 %   ok=controller_test(),

  %  ok=reconciliation_test(),

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
add_test_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    pong=rpc:call(?CompileServerVm,compiler_server,ping,[],5000),
    {ok,Cwd}=rpc:call(?CompileServerVm,file,get_cwd,[],5000),
    io:format("Cwd ~p~n",[Cwd]),

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AddTestApplicationDir=filename:join(Cwd,?AddTestApplicationDir),
    AddTestReleaseFile=filename:join(Cwd,?AddTestReleaseFile),
    AddTestCloneResult=rpc:call(?CompileServerVm,compiler_server,git_clone,[?AddTestGitPath,AddTestApplicationDir],5*5000),
    io:format("AddTestCloneResult ~p~n",[AddTestCloneResult]),
    AddTestCompileResult=rpc:call(?CompileServerVm,compiler_server,compile,[AddTestApplicationDir],5*5000),
    io:format("AddTestCompileResult ~p~n",[AddTestCompileResult]),
    AddTestReleaseResult=rpc:call(?CompileServerVm,compiler_server,release,[AddTestApplicationDir],5*5000),
    io:format("AddTestReleaseResult ~p~n",[AddTestReleaseResult]),

    AddTestStartResult=rpc:call(?CompileServerVm,compiler_server,start_application,[AddTestReleaseFile,"daemon"],5*5000),
    io:format("AddTestStartResult ~p~n",[AddTestStartResult]),
    42=rpc:call(?AddTestVm,add_test,add,[20,22],5000),

    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
kvs_test_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    pong=rpc:call(?CompileServerVm,compiler_server,ping,[],5000),
    {ok,Cwd}=rpc:call(?CompileServerVm,file,get_cwd,[],5000),
    io:format("Cwd ~p~n",[Cwd]),

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    KvsTestApplicationDir=filename:join(Cwd,?KvsTestApplicationDir),
    KvsTestReleaseFile=filename:join(Cwd,?KvsTestReleaseFile),
    KvsTestCloneResult=rpc:call(?CompileServerVm,compiler_server,git_clone,[?KvsTestGitPath,KvsTestApplicationDir],5*5000),
    io:format("KvsTestCloneResult ~p~n",[KvsTestCloneResult]),
    KvsTestCompileResult=rpc:call(?CompileServerVm,compiler_server,compile,[KvsTestApplicationDir],5*5000),
    io:format("KvsTestCompileResult ~p~n",[KvsTestCompileResult]),
    KvsTestReleaseResult=rpc:call(?CompileServerVm,compiler_server,release,[KvsTestApplicationDir],5*5000),
    io:format("KvsTestReleaseResult ~p~n",[KvsTestReleaseResult]),

    KvsTestStartResult=rpc:call(?CompileServerVm,compiler_server,start_application,[KvsTestReleaseFile,"daemon"],5*5000),
    io:format("KvsTestStartResult ~p~n",[KvsTestStartResult]),
    42=rpc:call(?KvsTestVm,kvs_test,add,[20,22],5000),

    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
compile_template_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    pong=rpc:call(?CompileServerVm,compiler_server,ping,[],5000),
    {ok,Cwd}=rpc:call(?CompileServerVm,file,get_cwd,[],5000),
    io:format("Cwd ~p~n",[Cwd]),

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TemplateApplicationDir=filename:join(Cwd,?TemplateApplicationDir),
    TemplateReleaseFile=filename:join(Cwd,?TemplateReleaseFile),
    TemplateCloneResult=rpc:call(?CompileServerVm,compiler_server,git_clone,[?TemplateGitPath,TemplateApplicationDir],5*5000),
    io:format("TemplateCloneResult ~p~n",[TemplateCloneResult]),
    TemplateCompileResult=rpc:call(?CompileServerVm,compiler_server,compile,[TemplateApplicationDir],5*5000),
    io:format("TemplateCompileResult ~p~n",[TemplateCompileResult]),
    TemplateReleaseResult=rpc:call(?CompileServerVm,compiler_server,release,[TemplateApplicationDir],5*5000),
    io:format("TemplateReleaseResult ~p~n",[TemplateReleaseResult]),

    TemplateStartResult=rpc:call(?CompileServerVm,compiler_server,start_application,[TemplateReleaseFile,"daemon"],5*5000),
    io:format("TemplateStartResult ~p~n",[TemplateStartResult]),
    42=rpc:call(?TemplateVm,temp,add,[20,22],5000),

    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
compiler_server_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    pong=rpc:call(?CompileServerVm,compiler_server,ping,[],5000),
    {ok,Cwd}=rpc:call(?CompileServerVm,file,get_cwd,[],5000),
    io:format("Cwd ~p~n",[Cwd]),



    %%%%%%%%%%%%%%%%%%%
    KvsApplicationDir=filename:join(Cwd,?KvsApplicationDir),
    KvsReleaseFile=filename:join(Cwd,?KvsReleaseFile),
    KvsCloneResult=rpc:call(?CompileServerVm,compiler_server,git_clone,[?KvsGitPath,KvsApplicationDir],5*5000),
    io:format("KvsCloneResult ~p~n",[KvsCloneResult]),
    KvsCompileResult=rpc:call(?CompileServerVm,compiler_server,compile,[KvsApplicationDir],5*5000),
    io:format("KvsCompileResult ~p~n",[KvsCompileResult]),
    KvsReleaseResult=rpc:call(?CompileServerVm,compiler_server,release,[KvsApplicationDir],5*5000),
    io:format("KvsReleaseResult ~p~n",[KvsReleaseResult]),

    KvsStartResult=rpc:call(?CompileServerVm,compiler_server,start_application,[KvsReleaseFile,"daemon"],5*5000),
    io:format("KvsStartResult ~p~n",[KvsStartResult]),    

    pong=net_adm:ping(?KvsVm),
    rpc:call(?KvsVm,mnesia,system_info,[],5000),

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AdderApplicationDir=filename:join(Cwd,?AdderApplicationDir),
    AdderReleaseFile=filename:join(Cwd,?AdderReleaseFile),
    AdderCloneResult=rpc:call(?CompileServerVm,compiler_server,git_clone,[?AdderGitPath,AdderApplicationDir],5*5000),
    io:format("AdderCloneResult ~p~n",[AdderCloneResult]),
    AdderCompileResult=rpc:call(?CompileServerVm,compiler_server,compile,[AdderApplicationDir],5*5000),
    io:format("AdderCompileResult ~p~n",[AdderCompileResult]),
    AdderReleaseResult=rpc:call(?CompileServerVm,compiler_server,release,[AdderApplicationDir],5*5000),
    io:format("AdderReleaseResult ~p~n",[AdderReleaseResult]),

    AdderStartResult=rpc:call(?CompileServerVm,compiler_server,start_application,[AdderReleaseFile,"daemon"],5*5000),
    io:format("AdderStartResult ~p~n",[AdderStartResult]),
    42=rpc:call(?AdderVm,adder3,add,[20,22],5000),

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

    %% check read application configs

    {ok,[{value1,v11},{value2,12}]}=rpc:call(?Vm,controller,get_application_config,[app1],5000),
    {ok,[{value1,v21},{value2,22}]}=rpc:call(?Vm,controller,get_application_config,[app2],5000),

   {ok,[]}=rpc:call(?Vm,controller,get_application_config,[glurk],5000),



    %Load and start adder3
    {error,["Not started ","adder3.application"]}=rpc:call(?Vm,controller,stop_unload,["adder3.application"],5*5000),
    ok=rpc:call(?Vm,controller,load_start,["adder3.application"],5*5000),
    AppVm=adder3@c50,
    42=rpc:call(AppVm,adder3,add,[20,22],5000),
    
    {error,["Already loaded ","adder3.application"]}=rpc:call(?Vm,controller,load_start,["adder3.application"],5*5000),
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
    [
     "adder3.application",
     "kvs.application",
     "phoscon.application",
     "zigbee.application"
    ]=lists:sort(AllFilenames),
    {ok,"Repo is up to date"}=rpc:call(?Vm,application_server, update,[],5000),

    %Load and start adder3

    {error,["Not loaded ","adder3.application"]}=rpc:call(?Vm,application_server,start_app,["adder3.application"],5000),
    {error,["Not started ","adder3.application"]}=rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),
    {error,["Not loaded ","adder3.application"]}=rpc:call(?Vm,application_server,unload_app,["adder3.application"],5000),
    
    pong=rpc:call(?Vm,application_server,ping,[],5000),

    ok=rpc:call(?Vm,application_server,load_app,["adder3.application"],5*5000),
    {error,["Not started ","adder3.application"]}=rpc:call(?Vm,application_server,stop_app,["adder3.application"],5000),

    ok=rpc:call(?Vm,application_server,start_app,["adder3.application"],5*5000),
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
    [
     "adder3.deployment",
     "kvs.deployment",
     "phoscon_zigbee.deployment"
    ]=lists:sort(AllFilenames),
   
   [
    {"adder3.application","c50"},
    {"kvs.application","c50"}
   ]=lists:sort(rpc:call(?Vm,deployment_server, get_applications_to_deploy,[],5000)),
   
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
    
    [
     {app1,[{value1,v11},{value2,12}]},
     {app2,[{value1,v21},{value2,22}]},
     {conbee,[{conbee_addr,"172.17.0.2"},
	      {conbee_port,80},
	      {conbee_key,"Glurk"}]}
    ]=rpc:call(?Vm,host_server,get_application_config,[],5000),

   
    {ok,"Repo is up to date"}=rpc:call(?Vm,host_server, update,[],5000),
  
    ok.


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    
    os:cmd("rm -rf Mnesia.*"),
    ok=application:start(log),
    file:make_dir(?MainLogDir),
    [NodeName,_HostName]=string:tokens(atom_to_list(node()),"@"),
    NodeNodeLogDir=filename:join(?MainLogDir,NodeName),
    ok=log:create_logger(NodeNodeLogDir,?LocalLogDir,?LogFile,?MaxNumFiles,?MaxNumBytes),

    ok=application:start(rd),
    
    %% Application to test
    ok=application:start(application_server),
    pong=rpc:call(node(),application_server,ping,[],3*5000),  
    ok=application:start(ctrl),
    pong=rpc:call(node(),controller,ping,[],3*5000), 


    ok.
