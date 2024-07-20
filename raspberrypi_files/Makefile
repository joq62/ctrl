all:
	rm -rf  *~ */*~ system_boot;
	git clone https://github.com/joq62/system_boot.git;
	echo Done;
test:
	cd /home/ubuntu;
	erl -pa system_boot/ebin -sname system_boot_a -setcookie a -run system_boot start
start:
	cd /home/ubuntu;
	erl -pa system_boot/ebin -sname system_boot_a -setcookie a -run system_boot start -hidden -noinput &
