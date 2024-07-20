%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2024, c50
%%% @doc
%%%
%%% @end
%%% Created : 11 Jan 2024 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(lib_reconciliate).
   
-include("controller.hrl").
-include("log.api").
 
  
%% API
-export([
	 start/0
	]).

-export([
	 wanted_applications/0,
	 active_applications/0

	]).

%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% Creates a new workernode , load and start infra services (log and resource discovery)
%% and  the wanted application ApplicationId
%% @end
%%--------------------------------------------------------------------
start()->
 %   io:format(" START Reconcilaition ******************** ~p~n",[{?ReconciliationInterval,?MODULE,?FUNCTION_NAME,?LINE}]),

    timer:sleep(?ReconciliationInterval),

    {ok,AllApplicationFiles}=application_server:all_filenames(),
    AllDeploymentFiles=[Filename||{Filename,_}<-deployment_server:get_applications_to_deploy()],
    ApplicationsToStart=[Filename||Filename<-AllDeploymentFiles,
				    false=:=application_server:is_app_started(Filename)],
    LoadStartResult=start_applications(ApplicationsToStart,[]),

    ApplicationsToStop=[Filename||Filename<-AllApplicationFiles,
				  false=:=lists:member(Filename,AllDeploymentFiles),
				  true=:=application_server:is_app_started(Filename)],
    StopUnloadResult=stop_applications(ApplicationsToStop,[]),
 
  %  io:format(" END Reconcilaition ========================== ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
  %  rpc:cast(node(),controller,reconciliate,[])
    rpc:cast(node(),controller,reconciliate,[LoadStartResult,StopUnloadResult]).
   

start_applications([],Acc)->
    Acc;
start_applications([ApplicationFilename|T],Acc)->
    case application_server:is_app_started(ApplicationFilename) of
	true->
	    controller:stop_unload(ApplicationFilename);
	false->
	    case application_server:is_app_loaded(ApplicationFilename) of
		true->
		    application_server:unload_app(ApplicationFilename);
		false->
		    ok
	    end
    end,
    Result=controller:load_start(ApplicationFilename),
    start_applications(T,[{Result,ApplicationFilename}|Acc]).

stop_applications([],Acc)->
    Acc;
stop_applications([ApplicationFilename|T],Acc)->
    Result=case application_server:is_app_started(ApplicationFilename) of
	       true->
		   controller:stop_unload(ApplicationFilename);
	       false->
		   case application_server:is_app_loaded(ApplicationFilename) of
		       true->
			   application_server:unload_app(ApplicationFilename);
		       false->
			   ok
		   end
	   end,
    stop_applications(T,[{Result,ApplicationFilename}|Acc]).
  
%%%===================================================================
%%% Internal functions
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
wanted_applications()->
    {ok,FileNames}=deployment:all_filenames(),
    get_wanted_applications(FileNames).

get_wanted_applications(FileNames)->
    get_wanted_applications(FileNames,[]).

get_wanted_applications([],Acc)->
    Acc;
get_wanted_applications([FileName|T],Acc)->
    {ok,[Map]}=deployment:read_file(FileName),
    {ok,HostName}=net:gethostname(),
    R=[ApplicationFileName||{ApplicationFileName,WantedHostName}<-maps:get(deployments,Map),
		      HostName==WantedHostName],
    NewAcc=lists:append(R,Acc),
    get_wanted_applications(T,NewAcc).

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
active_applications()->
    ActiveNodes=get_active_workers(),
    AllApps=all_apps(),
    node_filenames(ActiveNodes,AllApps).
    
node_filenames(ActiveNodes,AllApps)->   
    node_filenames(ActiveNodes,AllApps,[]).
node_filenames([],_AllApps,Acc)->
    Acc;
node_filenames([WorkerNode|T],AllApps,Acc)->
    ApplicationInfo=rpc:call(WorkerNode,application,which_applications,[],5000),
    NodeFileNames=check_apps(ApplicationInfo,WorkerNode,AllApps),
    NewAcc=lists:append(NodeFileNames,Acc),
    node_filenames(T,AllApps,NewAcc).


check_apps(ApplicationInfo,WorkerNode,AllApps)->
    check_apps(ApplicationInfo,WorkerNode,AllApps,[]).
check_apps([],_,_,Acc)->
    Acc;
check_apps({badrpc,nodedown},_,_,Acc)->
    Acc;
check_apps([{App,_,_}|T],WorkerNode,AllApps,Acc)->
    NewAcc=case lists:member(App,AllApps) of
	       false->
		   Acc;
	       true ->
		   {ok,FileName}=catalog:which_filename(App),
		   [{WorkerNode,FileName}|Acc]
	   end,
    check_apps(T,WorkerNode,AllApps,NewAcc).
				
all_apps()->
    {ok,FileNames}=catalog:all_filenames(),
    all_apps(FileNames).
all_apps(FileNames)->
    all_apps(FileNames,[]).		
all_apps([],Acc)->	   
    Acc;
all_apps([FileName|T],Acc) ->
    NewAcc=case lists:member(FileName,?InfraApplicationFileNames) of
	       false->
		   {ok,[Map]}=catalog:read_file(FileName),
		   App=maps:get(app,Map),
		   [App|Acc];
	       true->
		   Acc
	   end,
    all_apps(T,NewAcc).

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
get_active_workers()->
    {ok,ThisHostName}=net:gethostname(),
    ActiveWorkerNodesOnThisHost=[Node||Node<-[node()|nodes()],
				 {ok,ThisHostName}==rpc:call(Node,net,gethostname,[],5000)],
    ActiveWorkerNodesOnThisHost.



