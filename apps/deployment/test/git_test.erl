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
-module(git_test).      
 
-export([start/0]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


-define(DeploymentRepoDir,"deployment_specs_test").
-define(DeploymentGit,"https://github.com/joq62/deployment_specs_test.git").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=setup(),
    ok=test1(),
 %   loop(false),

    io:format("Test OK !!! ~p~n",[?MODULE]),
%    timer:sleep(1000),
%    init:stop(),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test1()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=deployment:update_repo_dir(?DeploymentRepoDir),
    ok=deployment:update_git_path(?DeploymentGit),
    
    %% Detect that no local repo 
    file:del_dir_r(?DeploymentRepoDir),
    false=filelib:is_dir(?DeploymentRepoDir),
    %% Filure test
    {error,_,_,_,_}=deployment:all_filenames(),
    {error,_,_,_,_}=deployment:read_file("first.deployment"),
    {error,_,_,_,_}=deployment:update_repo(),
    
    %and do clone 
    ok=deployment:clone(),
    true=filelib:is_dir(?DeploymentRepoDir),
    {ok,["first.deployment"]}=deployment:all_filenames(),
    {ok,[Map]}=deployment:read_file("first.deployment"),
  [
   {"adder.application","c200"},
   {"adder.application","c202"},
   {"adder.application","c50"},
   {"adder.application","c50"},
   {"adder.application","c50"},
   {"divi.application","c200"},
   {"divi.application","c202"},
   {"divi.application","c50"},
   {"divi.application","c50"}
  ]=lists:sort(maps:get(deployments,Map)),
    {error,_,_,_,_}=deployment:read_file("glurk.deployment"),
    {error,["Already updated ",?DeploymentRepoDir]}=deployment:update_repo(),
    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
loop(RepoState)->
  %  io:format("Start ~p~n",[{time(),?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("get all filenames ~p~n",[{deployment:all_filenames(),?MODULE,?LINE}]),
    NewState=case deployment:is_repo_updated() of
		 true->
		     case RepoState of
			 false->
			     io:format("RepoState false-> true ~p~n",[{deployment:is_repo_updated(),?MODULE,?LINE}]),
			     io:format("get all filenames ~p~n",[{deployment:all_filenames(),?MODULE,?LINE}]),
			     true;
			 true->
			     RepoState
		     end;
		 false->
		     case RepoState of
			 true->
			     io:format("RepoState true->false ~p~n",[{deployment:is_repo_updated(),?MODULE,?LINE}]),
			     io:format("deployment:update_repo()~p~n",[{deployment:update_repo(),?MODULE,?LINE}]),
			     deployment:update_repo(),
			     io:format("get all filenames ~p~n",[{deployment:all_filenames(),?MODULE,?LINE}]),
			     false;
			 false->
			     RepoState
		     end
	     end,
		    
    timer:sleep(10*1000),
    loop(NewState).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
  
    pong=log:ping(),
    pong=rd:ping(),
    pong=git_handler:ping(),    
    pong=deployment:ping(),   
    ok.
