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


-define(RepoDir,"host_specs").
-define(Git,"https://github.com/joq62/host_specs.git").
-define(ConnectModule,"main").
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=setup(),
    ok=test1(),
    loop(false),

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
    
    ok=host:update_repo_dir(?RepoDir),
    ok=host:update_git_path(?Git),
    
    %% Detect that no local repo 
    file:del_dir_r(?RepoDir),
    false=filelib:is_dir(?RepoDir),
    %% Filure test
    {error,_,_,_,_}=host:all_filenames(),
    {error,_,_,_,_}=host:read_file("c200.host"),
    {error,_,_,_,_}=host:update_repo(),
    
    %and do clone 
    ok=host:clone(),
    true=filelib:is_dir(?RepoDir),
    {ok,AllFileNames}=host:all_filenames(),
    ["c200.host","c201.host","c202.host","c230.host"]=lists:sort(AllFileNames),
    

    {ok,[Map]}=host:read_file("c200.host"),
    "192.168.1.200"=maps:get(ip,Map),
    
    ["c200","c201","c202","c230"]=lists:sort(host:all_hosts()),
    {ok,"c200"}=host:get_hostname("c200.host"),
    {ok,"192.168.1.200"}=host:get_ip("c200.host"),
    {ok,22}=host:get_ssh("c200.host"),
    {ok,"ubuntu"}=host:get_userid("c200.host"),
    {ok,_}=host:get_passwd("c202.host"),
    {ok,
     [{conbee,[{conbee_addr,"172.17.0.2"},
	       {conbee_port,80},
	       {conbee_key,"4B3F1542C5"}
	      ]
      }
     ]
    }=host:get_application_config("c201.host"),


    AllHostNames=host:all_hosts(),
    CookieStr=atom_to_list(erlang:get_cookie()),
    NodeName=?ConnectModule++"_"++CookieStr,
    ['main_a@c200','main_a@c201','main_a@c202','main_a@c230']=lists:sort([list_to_atom(NodeName++"@"++HostName)||HostName<-AllHostNames]),

    {error,_,_,_,_}=host:read_file("glurk.host"),
    {error,["Already updated ",?RepoDir]}=host:update_repo(),
    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
loop(RepoState)->
  %  io:format("Start ~p~n",[{time(),?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("get all filenames ~p~n",[{host:all_filenames(),?MODULE,?LINE}]),
    NewState=case host:is_repo_updated() of
		 true->
		     case RepoState of
			 false->
			     io:format("RepoState false-> true ~p~n",[{host:is_repo_updated(),?MODULE,?LINE}]),
			     io:format("get all filenames ~p~n",[{host:all_filenames(),?MODULE,?LINE}]),
			     true;
			 true->
			     RepoState
		     end;
		 false->
		     case RepoState of
			 true->
			     io:format("RepoState true->false ~p~n",[{host:is_repo_updated(),?MODULE,?LINE}]),
			     io:format("host:update_repo()~p~n",[{host:update_repo(),?MODULE,?LINE}]),
			     host:update_repo(),
			     io:format("get all filenames ~p~n",[{host:all_filenames(),?MODULE,?LINE}]),
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
    pong=host:ping(),   
    ok.
