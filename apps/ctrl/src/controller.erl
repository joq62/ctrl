%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2023, c50
%%% @doc
%%% 
%%% @end
%%% Created : 18 Apr 2023 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(controller). 
 
-behaviour(gen_server).
%%--------------------------------------------------------------------
%% Include 
%%
%%--------------------------------------------------------------------

-include("log.api").

-include("controller.hrl").
-include("controller.rd").

-include("specs.hrl").




%% API
-export([
	connect/0
	]).

-export([
	 reconciliate/0,
	 reconciliate/2,
	 load_start/1,
	 stop_unload/1,
	 
	 add_application/1,
	 delete_application/1,

	 get_application_config/1
	]).

%% OaM 
-export([


	]).

%% admin

-export([
	 start/0,
	 ping/0,
	 stop/0
	]).

-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3, format_status/2]).

-define(SERVER, ?MODULE).
	

-record(state, {
		connected_nodes,
		not_connected_nodes,
		load_start_result,
		stop_unload_result
		
	       }).

%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% This a loop that starts after the interval ReconcilationInterval 
%% The loop checks what to start or stop 
%% 
%% @end
%%--------------------------------------------------------------------
-spec connect() -> 
	  ok .
connect() ->
    gen_server:cast(?SERVER,{connect}).

%%--------------------------------------------------------------------
%% @doc
%% This a loop that starts after the interval ReconcilationInterval 
%% The loop checks what to start or stop 
%% 
%% @end
%%--------------------------------------------------------------------
-spec reconciliate(LoadStartResult::term(),StopUnloadResult::term()) -> 
	  ok .
reconciliate(LoadStartResult,StopUnloadResult) ->
    gen_server:cast(?SERVER,{reconciliate,LoadStartResult,StopUnloadResult}).

%%--------------------------------------------------------------------
%% @doc
%% This a loop that starts after the interval ReconcilationInterval 
%% The loop checks what to start or stop 
%% 
%% @end
%%--------------------------------------------------------------------
-spec reconciliate() -> 
	  ok .
reconciliate() ->
    gen_server:cast(?SERVER,{reconciliate}).

%%--------------------------------------------------------------------
%% @doc
%% Add application with ApplicationId to be deployed 
%% 
%% @end
%%--------------------------------------------------------------------
-spec get_application_config(Application::atom()) -> 
	  {ok,ApplicationConfig::term()}|{error, Error :: term()}.
get_application_config(Application) ->
    gen_server:call(?SERVER,{get_application_config,Application},infinity).


%%--------------------------------------------------------------------
%% @doc
%% Add application with ApplicationId to be deployed 
%% 
%% @end
%%--------------------------------------------------------------------
-spec load_start(ApplicationFileName::string()) -> 
	  ok | {error, Error :: term()}.
load_start(ApplicationFileName) ->
    gen_server:call(?SERVER,{load_start,ApplicationFileName},infinity).
%%--------------------------------------------------------------------
%% @doc
%% Add application with ApplicationId to be deployed 
%% 
%% @end
%%--------------------------------------------------------------------
-spec stop_unload(ApplicationFileName::string()) -> 
	  ok | {error, Error :: term()}.
stop_unload(ApplicationFileName) ->
    gen_server:call(?SERVER,{stop_unload,ApplicationFileName},infinity).

%%--------------------------------------------------------------------
%% @doc
%% Add application with ApplicationId to be deployed 
%% 
%% @end
%%--------------------------------------------------------------------
-spec add_application(ApplicationId::string()) -> 
	  ok | {error, Error :: term()}.
add_application(ApplicationId) ->
    gen_server:call(?SERVER,{add_application,ApplicationId},infinity).
%%--------------------------------------------------------------------
%% @doc
%% Delete application ApplicationId from the deployment list 
%% 
%% @end
%%--------------------------------------------------------------------
-spec delete_application(ApplicationId::string()) -> 
	  ok | {error, Error :: term()}.
delete_application(ApplicationId) ->
    gen_server:call(?SERVER,{delete_application,ApplicationId},infinity).


%%--------------------------------------------------------------------
%% @doc
%%  
%% 
%% @end
%%--------------------------------------------------------------------
start()->
    application:start(?MODULE).


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
-spec ping() -> pong | Error::term().
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%% @end
%%--------------------------------------------------------------------
-spec start_link() -> {ok, Pid :: pid()} |
	  {error, Error :: {already_started, pid()}} |
	  {error, Error :: term()} |
	  ignore.
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


%stop()-> gen_server:cast(?SERVER, {stop}).
stop()-> gen_server:stop(?SERVER).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%% @end
%%--------------------------------------------------------------------
-spec init(Args :: term()) -> {ok, State :: term()} |
	  {ok, State :: term(), Timeout :: timeout()} |
	  {ok, State :: term(), hibernate} |
	  {stop, Reason :: term()} |
	  ignore.

init([]) ->
    
   
    {ok, #state{
	    connected_nodes=[],
	    not_connected_nodes=[],
	    load_start_result=undefined,
	    stop_unload_result=undefined	   
	    
	   },0}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%% @end
%%--------------------------------------------------------------------
-spec handle_call(Request :: term(), From :: {pid(), term()}, State :: term()) ->
	  {reply, Reply :: term(), NewState :: term()} |
	  {reply, Reply :: term(), NewState :: term(), Timeout :: timeout()} |
	  {reply, Reply :: term(), NewState :: term(), hibernate} |
	  {noreply, NewState :: term()} |
	  {noreply, NewState :: term(), Timeout :: timeout()} |
	  {noreply, NewState :: term(), hibernate} |
	  {stop, Reason :: term(), Reply :: term(), NewState :: term()} |
	  {stop, Reason :: term(), NewState :: term()}.


handle_call({get_application_config,Application}, _From, State) ->
  %  io:format(" ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]),
    Result=try lib_controller:get_application_config(Application) of
	       {ok,R}->
		    {ok,R};
	       {error,Reason}->
		   {error,Reason}
	   catch
	       Event:Reason:Stacktrace ->
		   {Event,Reason,Stacktrace,?MODULE,?LINE}
	   end,
    Reply=case Result of
	       {ok,ApplicationConfig}->
		  {ok,ApplicationConfig};
	      ErrorEvent->
		  ?LOG_WARNING("Failed to get application config for Application",[Application,ErrorEvent]),
		  ErrorEvent
	  end,
    {reply, Reply, State};

handle_call({load_start,ApplicationFileName}, _From, State) ->
  %  io:format(" ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]),
    Result=try lib_controller:load_start(ApplicationFileName) of
	       ok->
		   ok;
	       {error,Reason}->
		   {error,Reason}
	   catch
	       Event:Reason:Stacktrace ->
		   {Event,Reason,Stacktrace,?MODULE,?LINE}
	   end,
    Reply=case Result of
	      ok->
		  ?LOG_NOTICE("Started Application",[ApplicationFileName]),
		  ok;
	      ErrorEvent->
		  ?LOG_WARNING("Failed to start Application",[ApplicationFileName,[ErrorEvent]]),
		  ErrorEvent
	  end,
    {reply, Reply, State};

handle_call({stop_unload,ApplicationFileName}, _From, State) ->
  %  io:format(" ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]),
    Result=try lib_controller:stop_unload(ApplicationFileName) of
	       ok->
		   ok;
	       {error,Reason}->
		   {error,Reason}
	   catch
	       Event:Reason:Stacktrace ->
		   {Event,Reason,Stacktrace,?MODULE,?LINE}
	   end,
    Reply=case Result of
	      ok->
		  ?LOG_NOTICE("Stopped Application",[ApplicationFileName]),
		  ok;
	      ErrorEvent->
		  ?LOG_WARNING("Failed to stop  Application",[ApplicationFileName,ErrorEvent]),
		  ErrorEvent
	  end,
    {reply, Reply, State};

handle_call({read_state}, _From, State) ->
    Reply=State,
    {reply, Reply, State};

handle_call({ping}, _From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call(UnMatchedSignal, From, State) ->
    ?LOG_WARNING("Unmatched signal",[UnMatchedSignal]),
    io:format("unmatched_signal ~p~n",[{UnMatchedSignal, From,?MODULE,?LINE}]),
    Reply = {error,[unmatched_signal,UnMatchedSignal, From]},
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%% @end
%%--------------------------------------------------------------------
handle_cast({connect}, State) ->
    spawn(fun()->lib_controller:connect(?Sleep) end),
    {noreply, State};


handle_cast({reconciliate,LoadStartResult,StopUnloadResult}, State) ->
    if
	{LoadStartResult,StopUnloadResult}
	=:={State#state.load_start_result,State#state.stop_unload_result}->
	    no_chnage,
	    NewState=State;
	true->
	    case {LoadStartResult,StopUnloadResult} of
		{[],[]}->
		    ?LOG_NOTICE("System is in wanted state ",[]);
		{LoadStartResult,[]}->
		    ?LOG_NOTICE("Load and started result",[LoadStartResult]);
		{[],StopUnloadResult}->
		    ?LOG_NOTICE("Stop and unload result",[StopUnloadResult]);			
		{LoadStartResult,StopUnloadResult}->
		    ?LOG_NOTICE("Load and started result",[LoadStartResult]),
		    ?LOG_NOTICE("Stop and unload result",[StopUnloadResult])
	    end,
	    NewState=State#state{load_start_result=LoadStartResult,
				 stop_unload_result=StopUnloadResult}
    end,
    spawn(fun()->lib_reconciliate:start() end),
    {noreply, NewState};

handle_cast({reconciliate}, State) ->
    spawn(fun()->lib_reconciliate:start() end),
    {noreply, State};

handle_cast({stop}, State) ->
    
    {stop,normal,ok,State};

handle_cast(UnMatchedSignal, State) ->
    ?LOG_WARNING("Unmatched signal",[UnMatchedSignal]),
    io:format("unmatched_signal ~p~n",[{UnMatchedSignal,?MODULE,?LINE}]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%% @end
%%--------------------------------------------------------------------
-spec handle_info(Info :: timeout() | term(), State :: term()) ->
	  {noreply, NewState :: term()} |
	  {noreply, NewState :: term(), Timeout :: timeout()} |
	  {noreply, NewState :: term(), hibernate} |
	  {stop, Reason :: normal | term(), NewState :: term()}.

handle_info({nodedown,Node}, State) ->
    ?LOG_WARNING("nodedown,Node ",[Node]), 
    {noreply, State};


handle_info(timeout, State) ->

    Self=self(),
    spawn_link(fun()->timeout_check_wanted_state_loop(Self) end),
    
    
    
    %% Fix log
    file:del_dir_r(?MainLogDir),
    file:make_dir(?MainLogDir),
    [NodeName,_HostName]=string:tokens(atom_to_list(node()),"@"),
    NodeNodeLogDir=filename:join(?MainLogDir,NodeName),
    ok=log:create_logger(NodeNodeLogDir,?LocalLogDir,?LogFile,?MaxNumFiles,?MaxNumBytes),

    AllHostNodes=host_server:get_host_nodes(),
    ConnectResult=[{N,net_adm:ping(N)}||N<-AllHostNodes],
    ConnectedNodes=[Node||{Node,pong}<-ConnectResult],
    NotConnectedNodes=[Node||{Node,pang}<-ConnectResult],
    ?LOG_NOTICE("Connected controller nodes ",[ConnectedNodes]),   
    ?LOG_WARNING("Not connected controller nodes ",[NotConnectedNodes]),    
    lib_controller:trade_resources(),
    ?LOG_NOTICE("Server started ",[?MODULE]),
    NewState=State#state{connected_nodes=ConnectedNodes,
			 not_connected_nodes=NotConnectedNodes},
    {noreply, NewState};


handle_info({timeout,check_wanted_state}, State) ->

    io:format("re-connect all ctrl nodes ~p~n",[{?MODULE,?LINE}]),
    AllHostNodes=host_server:get_host_nodes(),
    ConnectResult=[{N,net_adm:ping(N)}||N<-AllHostNodes],
    ConnectedNodes=[Node||{Node,pong}<-ConnectResult],
    NotConnectedNodes=[Node||{Node,pang}<-ConnectResult],
    
    io:format("Check applications to stop  and stop them ~p~n",[{?MODULE,?LINE}]),
    {ok,ApplicationSpecFilesToStop}=application_server:applications_to_stop(),
    io:format("ApplicationSpecFilesToStop ~p~n",[{ApplicationSpecFilesToStop,?MODULE,?LINE}]),
    case ApplicationSpecFilesToStop of
	[]->
	    io:format(" ~p~n",[{?MODULE,?LINE}]),
	    ok;
	_ ->
	    io:format(" ~p~n",[{?MODULE,?LINE}]),
	    StopResult=[{File,application_server:stop_unload(File)}||File<-ApplicationSpecFilesToStop],
	    ?LOG_NOTICE("Stopped applications ",[StopResult])
    end,   
    io:format(" ~p~n",[{?MODULE,?LINE}]),
    io:format("Check applications to start and start them ~p~n",[{?MODULE,?LINE}]),
    {ok,ApplicationSpecFilesToStart}=application_server:applications_to_start(),
    case ApplicationSpecFilesToStart of
	[]->
	    ok;
	_->
	    StartResult=[application_server:load_start(File)||File<-ApplicationSpecFilesToStart],
	    ?LOG_NOTICE("Started  applications ",[StartResult])
    end,   


    lib_controller:trade_resources(),
    
    NewState=State#state{connected_nodes=ConnectedNodes,
			 not_connected_nodes=NotConnectedNodes},

    {noreply, NewState};

handle_info(Info, State) ->
    ?LOG_WARNING("Unmatched signal",[Info]),
    io:format("unmatched_signal ~p~n",[{Info,?MODULE,?LINE}]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%% @end
%%--------------------------------------------------------------------
-spec terminate(Reason :: normal | shutdown | {shutdown, term()} | term(),
		State :: term()) -> any().
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%% @end
%%--------------------------------------------------------------------
-spec code_change(OldVsn :: term() | {down, term()},
		  State :: term(),
		  Extra :: term()) -> {ok, NewState :: term()} |
	  {error, Reason :: term()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called for changing the form and appearance
%% of gen_server status when it is returned from sys:get_status/1,2
%% or when it appears in termination error logs.
%% @end
%%--------------------------------------------------------------------
-spec format_status(Opt :: normal | terminate,
		    Status :: list()) -> Status :: term().
format_status(_Opt, Status) ->
    Status.

%%%===================================================================
%%% Internal functions
%%%===================================================================

timeout_check_wanted_state_loop(Parent)->
    io:format("timeout_check_wanted_state_loop Parent ~p~n",[{Parent,?CheckWantedStateInterval}]),
%    timer:sleep(?CheckWantedStateInterval),
    timer:sleep(10000),
    Parent!{timeout,check_wanted_state},
    timeout_check_wanted_state_loop(Parent).

