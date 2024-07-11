%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2024, c50
%%% @doc
%%%
%%% @end
%%% Created : 11 Jan 2024 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(lib_host).
  
-include("host.hrl").

 
%% API
-export([
	 get_host_nodes/1
	]).


-export([
	 all_hosts/1,
	 get/3,
	 init/2,
	 update/2,
	 timer_to_call_update/1
	]).



%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
get_host_nodes(RepoDir)->
    Result=case git_handler:all_filenames(RepoDir) of
	       {ok,AllFileNames}->
		   get_host_nodes(AllFileNames,RepoDir,[]);
	       Error ->
		    Error
	   end,   
    Result.
	
get_host_nodes([],_,Acc)->
    Acc;
get_host_nodes([FileName|T],RepoDir,Acc)->
    {ok,[Info]}=git_handler:read_file(RepoDir,FileName), 
    HostNode=maps:get(host_node,Info),
    get_host_nodes(T,RepoDir,[HostNode|Acc]).
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
all_hosts(RepoDir)->
    Result=case git_handler:all_filenames(RepoDir) of
	       {ok,AllFileNames}->
		   get_hostnames(AllFileNames,RepoDir,[]);
	       Error ->
		    Error
	   end,   
    Result.
	
get_hostnames([],_,Acc)->
    Acc;
get_hostnames([FileName|T],RepoDir,Acc)->
    {ok,[Info]}=git_handler:read_file(RepoDir,FileName), 
    HostName=maps:get(hostname,Info),
    get_hostnames(T,RepoDir,[HostName|Acc]).

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
get(Type,FileName,RepoDir)->
    Result=case git_handler:read_file(RepoDir,FileName) of
	       {ok,[Info]}->
		   {ok,maps:get(Type,Info)};
	       Error ->
		    Error
	   end,   
    Result.
	

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
timer_to_call_update(Interval)->
  %  io:format(" ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    timer:sleep(Interval),
    rpc:cast(node(),host_server,check_update_repo,[]).

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
update(RepoDir,GitPath)->
   % io:format(" ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    Result=case git_handler:is_repo_updated(RepoDir) of
	       {error,["RepoDir doesnt exists, need to clone"]}->
		   ok=git_handler:clone(RepoDir,GitPath),
		   {ok,"Cloned the repo"};
	       false ->
		   io:format(" ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
		   ok=git_handler:update_repo(RepoDir),
		   {ok,"Pulled a new update of the repo"};
	       true ->
		   {ok,"Repo is up to date"}
	   end,
    Result.

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
init(RepoDir,GitPath)->
    case git_handler:is_repo_updated(RepoDir) of
	{error,["RepoDir doesnt exists, need to clone"]}->
	    ok=git_handler:clone(RepoDir,GitPath);
	false ->
	    ok=git_handler:update_repo(RepoDir);
	true ->
	    ok
    end,
    ok.


%%%===================================================================
%%% Internal functions
%%%===================================================================
