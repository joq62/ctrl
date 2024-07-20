#!/bin/bash
rm -rf erl_cra* rebar3_crashreport 
rm -rf *~ */*~ */*/*~ */*/*/*~
rm -rf ctrl
rm -rf ctrl_dir
git clone https://github.com/joq62/ctrl.git
mkdir ctrl_dir
tar -zxf ctrl/release/ctrl.tar.gz -C ctrl_dir
./ctrl_dir/bin/ctrl foreground
