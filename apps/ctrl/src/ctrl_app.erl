%%%-------------------------------------------------------------------
%% @doc ctrl public API
%% @end
%%%-------------------------------------------------------------------

-module(ctrl_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ctrl_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
