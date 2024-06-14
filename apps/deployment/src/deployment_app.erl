%%%-------------------------------------------------------------------
%% @doc deployment public API
%% @end
%%%-------------------------------------------------------------------

-module(deployment_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    deployment_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
