#! /bin/bash
echo "An AppDynamics Portal login is required to download the installer software"
echo "Email ID/UserName: "
read USER_NAME

stty -echo
echo "Password: "
read PASSWORD
stty echo
echo

echo "Controller Address: "
read CONTROLLER

echo "Controller Port (8090/443/8181): "
read APPD_PORT 

echo "Controller SSL (true/false): "
read CONTROLLER_SSL

echo "Controller KEY: "
read CONTROLLER_KEY


# Build MovieZtream image then tidy up
echo
echo "Building MovieZtream container (appdynamics/edu-movieztream)"
echo
echo
if [ "$USER_NAME" != "" ] && [ "$PASSWORD" != "" ];
then
  echo '{"username": "'$USER_NAME'" ,"password": "'$PASSWORD'","scopes": [ "download"]}' > user2.dat
else
  echo "Username or Password missing"
  exit
fi

# Build MovieZtream image then tidy up
echo
echo "Building MovieZtream container (appdynamics/edu-movieztream)"
echo
cp user.dat mz
(cd mz; docker build -t carlosdoki/edu-movieztream .)


# Build db-agent image then tidy up
echo
echo "Building db-agent container (appdynamics/edu-db-agent)"
echo
cp user.dat db-agent
(cd db-agent; docker build -t carlosdoki/edu-db-agent .)

# Build JMeter load image
echo 
echo "Building JMeter load container (appdynamics/edu-jmeter)"
echo
(cd jmeter; docker build -t carlosdoki/edu-jmeter .)

# Run the entire system

# First, run the mysql container and create the sakila database
echo "Starting the MovieZtream database on container: db..."
docker run -d --name db -e MYSQL_ROOT_PASSWORD="rootpass" mysql:5
sleep 30
docker exec -i db mysql -u root -prootpass < ./db-scripts/setup.sql
sleep 5
docker exec -i db mysql -u root -prootpass < ./db-scripts/cleanup.sql

# Next, run the db-agent container
echo "Starting the db-agent on contaioner: db-agent..."
docker run -d --name db-agent --link db:db -e CONTROLLER=$CONTROLLER  -e APPD_PORT=$APPD_PORT -e CONTROLLER_SSL=$CONTROLLER_SSL -e CONTROLLER_KEY=$CONTROLLER_KEY  carlosdoki/edu-db-agent

# Next, run the MovieZtream tomcat containers
echo "Starting MovieZtream application containers: rt, sv, ui..."
docker run -d --name rt  -e rt=true -e CONTROLLER=$CONTROLLER  -e APPD_PORT=$APPD_PORT -e CONTROLLER_SSL=$CONTROLLER_SSL -e CONTROLLER_KEY=$CONTROLLER_KEY carlosdoki/edu-movieztream
docker run -d --name sv --link db:db  -e sv=true -e CONTROLLER=$CONTROLLER  -e APPD_PORT=$APPD_PORT -e CONTROLLER_SSL=$CONTROLLER_SSL -e CONTROLLER_KEY=$CONTROLLER_KEY  carlosdoki/edu-movieztream
docker run -d -p 80:80 --name ui --link sv:sv --link rt:rt  -e ui=true -e CONTROLLER=$CONTROLLER  -e APPD_PORT=$APPD_PORT -e CONTROLLER_SSL=$CONTROLLER_SSL -e CONTROLLER_KEY=$CONTROLLER_KEY  carlosdoki/edu-movieztream

# lastly, run the JMeter load container
echo "Starting the JMeter load container: mz-load..."
docker run -d --name mz-load --link ui:ui carlosdoki/edu-jmeter

echo
echo "All containers started!"
echo

