#!/bin/bash
rm -rf erl_cra* rebar3_crashreport 
rm -rf *~ */*~ */*/*~ */*/*/*~ 
rm -rf ctrl_dir 
rm -rf ebin 
rm -rf test_ebin 
rm -rf apps/*/src/*.beam 
rm -rf test/*.beam test/*/*.beam 
rm -rf *.beam 
rm -rf _build 
rm -rf ebin 
rm -rf rebar.lock
rm -rf release
rebar3 compile
rebar3 release 
rebar3 as prod tar 
mkdir release 
cp _build/prod/rel/ctrl/*.tar.gz release/ctrl.tar.gz 
mkdir ctrl_dir
tar -zxf release/ctrl.tar.gz -C ctrl_dir
./ctrl_dir/bin/ctrl foreground
