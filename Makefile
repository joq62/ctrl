all:
	#INFO: with_ebin_commit STARTED
	#INFO: Cleaning up to prepare build STARTED	 
	#INFO: Deleting crash reports
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	#INFO: Deleting euinit test applications dirs
	rm -rf ctrl_dir;
	rm -rf ebin;
	rm -rf Mnesia.*;
	rm -rf test_ebin;
	#INFO: Deleting tilde files and beams
	rm -rf *~ */*~ */*/*~;
	rm -rf apps/*/src/*.beam;
	rm -rf test/*.beam test/*/*.beam;
	rm -rf *.beam;
	#INFO: Deleting files and dirs created during builds
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock
	#INFO: Compile application
	rm -rf common_include;
	cp -r ~/erlang/simple_system/common_include .
	rm -rf release
	rebar3 compile
	rebar3 release;
	rebar3 as prod tar;
	mkdir release;
	cp _build/prod/rel/ctrl/*.tar.gz release/ctrl.tar.gz;
	rm -rf _build*;
	git status
	echo Ok there you go!
	#INFO: no_ebin_commit ENDED SUCCESSFUL
clean:
	#INFO: clean STARTED
	#INFO: with_ebin_commit STARTED
	#INFO: Cleaning up to prepare build STARTED	 
	#INFO: Deleting crash reports
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	#INFO: Deleting euinit test applications dirs
	rm -rf ctrl_dir;
	rm -rf ebin;
	rm -rf Mnesia.*;
	rm -rf test_ebin;
	#INFO: Deleting tilde files and beams
	rm -rf *~ */*~ */*/*~;
	rm -rf apps/*/src/*.beam;
	rm -rf test/*.beam test/*/*.beam;
	rm -rf *.beam;
	#INFO: Deleting files and dirs created during builds
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock
	#INFO: Deleting files and dirs created during execution/runtime 
	rm -rf logs;
	rm -rf *_a;
	#INFO: clean ENDED SUCCESSFUL
eunit: 
	#INFO: eunit STARTED
	#INFO: with_ebin_commit STARTED
	#INFO: Cleaning up to prepare build STARTED	 
	#INFO: Deleting crash reports
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	#INFO: Deleting euinit test applications dirs
	rm -rf ctrl_dir;
	rm -rf ebin;
	rm -rf Mnesia.*;
	rm -rf test_ebin;
	#INFO: Deleting tilde files and beams
	rm -rf *~ */*~ */*/*~;
	rm -rf apps/*/src/*.beam;
	rm -rf test/*.beam test/*/*.beam;
	rm -rf *.beam;
	#INFO: Deleting files and dirs created during builds
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock
	#INFO: Deleting files and dirs created during execution/runtime 
	rm -rf logs;
	rm -rf *_a;
	#INFO: Creating eunit test code using test_ebin dir;
	mkdir test_ebin;
	rm -rf common_include;
	cp -r ~/erlang/simple_system/common_include .
	#rm test/dependent_apps.erl;
	#cp /home/joq62/erlang/dev_support/dependent_apps.erl test;
	erlc -I include -I common_include -o test_ebin test/*.erl;
	#INFO: Creating Common applications needed for testing
	#INFO: Compile application
	rm -rf release;
	rebar3 compile
	rebar3 release;
	rebar3 as prod tar;
	mkdir release;
	cp _build/prod/rel/ctrl/*.tar.gz release/ctrl.tar.gz;
	rm -rf _build*;
	#INFO: Starts the eunit testing .................
	erl -pa test_ebin\
	 -sname test_ctrl_a\
	 -run $(m) start\
	 -setcookie a
rasp:
	#INFO: eunit STARTED
	#INFO: Cleaning up to prepare build STARTED
	#INFO: Deleting crash reports
	rm -rf erl_cra* rebar3_crashreport_GLURK;
	#INFO: Deleting files and dirs created during builds
	rm -rf rebar.lock
	#INFO: Deleting files and dirs created during execution/runtime 
	rm -rf logs;
	rm -rf *_a;
	#INFO: Creating eunit test code using test_ebin dir;
	rm -rf test_ebin;
	mkdir test_ebin;
	cp test/*.app test_ebin;
	#rm test/dependent_apps.erl;
	#cp /home/joq62/erlang/dev_support/dependent_apps.erl test;
	erlc -I include -I common_include -o test_ebin test/*.erl;
#	erlc -I include\
#	 -I /home/joq62/erlang/include\
#	 -I ../log_service/include\
#	 -o test_ebin ../log_service/src/*.erl;
	#INFO: Creating Common applications needed for testing
	#INFO: Compile application
	rm -rf ebin;
	mkdir ebin;		
	rebar3 compile;	
	cp _build/default/lib/*/ebin/* ebin;
#	rm -rf _build*;
	#INFO: Starts the eunit testing .................
	erl -pa ebin -pa priv\
	 -pa test_ebin\
	 -sname rd_a\
	 -run $(m) start\
	 -setcookie a
