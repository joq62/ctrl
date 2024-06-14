%%%-------------------------------------------------------------------
%% @doc catalog public API
%% @end
%%%-------------------------------------------------------------------

-module(catalog_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    catalog_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
