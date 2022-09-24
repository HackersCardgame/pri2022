# pri2022



As root
1. run Prerequisites, tested on debian buster, bullseye ... no guarantee that you dont have to fix things since things change
2. run ./tools/install/setup.sh
3. run make in ./
4. run unittests.sh in ./
5. have a look at the code
6. make 
7. make install-client installs the client to the system
8. make install-server installs the server to the system (needs 6+ Core!) as a service you can run with systemctl
9. to get the first user with password see server/hashPassword_unittest.cpp and use mysql command to create one (puzzle)

you need the modified cb-ftp: https://github.com/HackersCardgame/cbftp-r983, needs also to be compilet, has also a prerequisistes.sh

