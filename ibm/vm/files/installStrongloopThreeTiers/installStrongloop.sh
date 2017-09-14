#!/bin/bash
#################################################################
# Script to install NodeJS and StrongLoop 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017.
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

LOGFILE="/var/log/install_strongloop_nodejs.log"

SAMPLE_URL=$1
MongoDB_Server=$2
DBUserPwd=$3
UseSystemCtl=$4

#update

echo "---update system---" | tee -a $LOGFILE 2>&1 
yum update -y >> $LOGFILE 2>&1 

#install node.js

echo "---start installing node.js---" | tee -a $LOGFILE 2>&1 
yum install epel-release -y                                        >> $LOGFILE 2>&1 || { echo "---Failed to install epel---" | tee -a $LOGFILE; exit 1; }
yum install nodejs -y                                              >> $LOGFILE 2>&1 || { echo "---Failed to install node.js---"| tee -a $LOGFILE; exit 1; }
echo "---finish installing node.js---" | tee -a $LOGFILE 2>&1 

#install strongloop

echo "---start installing strongloop---" | tee -a $LOGFILE 2>&1 
yum groupinstall 'Development Tools' -y                            >> $LOGFILE 2>&1 || { echo "---Failed to install development tools---" | tee -a $LOGFILE; exit 1; }
npm install -g strongloop                                          >> $LOGFILE 2>&1 || { echo "---Failed to install strongloop---" | tee -a $LOGFILE; exit 1; }
echo "---finish installing strongloop---" | tee -a $LOGFILE 2>&1 

#install sample application

echo "---start installing sample application---" | tee -a $LOGFILE 2>&1 

PROJECT_NAME=sample
SAMPLE_DIR=$HOME/$PROJECT_NAME

if [ "$SAMPLE_URL" == "not_required" ]; then

	yum install expect -y                                                                   >> $LOGFILE 2>&1 || { echo "---Failed to install Expect---" | tee -a $LOGFILE; exit 1; }

	#create project
	cd $HOME
	SCRIPT_CREATE_PROJECT=createProject.sh	
	cat << EOF > $SCRIPT_CREATE_PROJECT
#!/usr/bin/expect
set timeout 20
spawn slc loopback --skip-install $PROJECT_NAME
expect "name of your application"
send "\r"
expect "name of the directory"
send "\r"
expect "version of LoopBack"
send "\r"
expect "kind of application"
send "\r"
expect "Run the app"
send "\r"
close
EOF

	chmod 755 $SCRIPT_CREATE_PROJECT                                                        >> $LOGFILE 2>&1 || { echo "---Failed to change permission of script---" | tee -a $LOGFILE; exit 1; }
	./$SCRIPT_CREATE_PROJECT                                                                >> $LOGFILE 2>&1 || { echo "---Failed to execute script---" | tee -a $LOGFILE; exit 1; }
	rm -f $SCRIPT_CREATE_PROJECT                                                            >> $LOGFILE 2>&1 || { echo "---Failed to remove script---" | tee -a $LOGFILE; exit 1; }

	#add dependency package 
	cd $SAMPLE_DIR
	sed -i -e '/loopback-datasource-juggler/a\ \ \ \ "loopback-connector-mongodb": "^1.18.0",' package.json    >> $LOGFILE 2>&1 || { echo "---Failed to add dependency for loopback-connector-mongo---" | tee -a $LOGFILE; exit 1; }
	
	#install packages in server side
	npm install                                                                             >> $LOGFILE 2>&1 || { echo "---Failed to install packages via npm---" | tee -a $LOGFILE; exit 1; }
	
	#create data model
	MODEL_NAME=Todos
	SCRIPT_CREATE_MODEL=createModel.sh
	cat << EOF > $SCRIPT_CREATE_MODEL
#!/usr/bin/expect
set timeout 20
spawn slc loopback:model $MODEL_NAME
expect "model name"
send "\r"
expect "data-source"
send "\r"
expect "base class"
send "\r"
expect "REST API"
send "\r"
expect "plural form"
send "\r"
expect "Common model"
send "\r"
expect "Property name"
send "content\r"
expect "Property type"
send "\r"
expect "Required"
send "\r"
expect "Default value"
send "\r"
expect "Property name"
send "\r"
close
EOF

	chmod 755 $SCRIPT_CREATE_MODEL                                                          >> $LOGFILE 2>&1 || { echo "---Failed to change permission of script---" | tee -a $LOGFILE; exit 1; }
	./$SCRIPT_CREATE_MODEL                                                                  >> $LOGFILE 2>&1 || { echo "---Failed to execute script---" | tee -a $LOGFILE; exit 1; }
	rm -f $SCRIPT_CREATE_MODEL                                                              >> $LOGFILE 2>&1 || { echo "---Failed to remove script---" | tee -a $LOGFILE; exit 1; }

	#update server config
	DATA_SOURCE_FILE=server/datasources.json
	sed -i -e 's/\ \ }/\ \ },/g' $DATA_SOURCE_FILE                                          >> $LOGFILE 2>&1 || { echo "---Failed to update datasource.json---" | tee -a $LOGFILE; exit 1; }
	sed -i -e '/\ \ },/a\ \ "myMongoDB": {\n\ \ \ \ "host": "mongodb-server",\n\ \ \ \ "port": 27017,\n\ \ \ \ "url": "mongodb://sampleUser:sampleUserPwd@mongodb-server:27017/admin",\n\ \ \ \ "database": "Todos",\n\ \ \ \ "password": "sampleUserPwd",\n\ \ \ \ "name": "myMongoDB",\n\ \ \ \ "user": "sampleUser",\n\ \ \ \ "connector": "mongodb"\n\ \ }' $DATA_SOURCE_FILE    >> $LOGFILE 2>&1 || { echo "---Failed to update datasource.json---" | tee -a $LOGFILE; exit 1; }
	sed -i -e "s/mongodb-server/$MongoDB_Server/g" $DATA_SOURCE_FILE                        >> $LOGFILE 2>&1 || { echo "---Failed to update datasource.json---" | tee -a $LOGFILE; exit 1; }
	sed -i -e "s/sampleUserPwd/$DBUserPwd/g" $DATA_SOURCE_FILE                              >> $LOGFILE 2>&1 || { echo "---Failed to update datasource.json---" | tee -a $LOGFILE; exit 1; }
	
	MODEL_CONFIG_FILE=server/model-config.json
	sed -i -e '/Todos/{n;d}' $MODEL_CONFIG_FILE                                             >> $LOGFILE 2>&1 || { echo "---Failed to update model-config.json---" | tee -a $LOGFILE; exit 1; }
	sed -i -e '/Todos/a\ \ \ \ "dataSource": "myMongoDB",' $MODEL_CONFIG_FILE               >> $LOGFILE 2>&1 || { echo "---Failed to update model-config.json---" | tee -a $LOGFILE; exit 1; }

else
	#download and untar application
	yum install curl -y                                                                    >> $LOGFILE 2>&1 || { echo "---Failed to install curl---" | tee -a $LOGFILE; exit 1; }
	mkdir $SAMPLE_DIR                                                                                                                            
	curl -k -o sample.tar.gz $SAMPLE_URL                                                   >> $LOGFILE 2>&1 || { echo "---Failed to download application tarball---" | tee -a $LOGFILE; exit 1; }
	tar -xzvf sample.tar.gz -C $SAMPLE_DIR                                                 >> $LOGFILE 2>&1 || { echo "---Failed to untar the application---" | tee -a $LOGFILE; exit 1; }

	#start application
	sed -i -e "s/mongodb-server/$MongoDB_Server/g" $SAMPLE_DIR/server/datasources.json     >> $LOGFILE 2>&1 || { echo "---Failed to configure datasource with mongodb server address---" | tee -a $LOGFILE; exit 1; }
	sed -i -e "s/sampleUserPwd/$DBUserPwd/g" $SAMPLE_DIR/server/datasources.json           >> $LOGFILE 2>&1 || { echo "---Failed to configure datasource with mongo user password---" | tee -a $LOGFILE; exit 1; } 

fi

#make sample application as a service
if [ "$UseSystemCtl" == "true" ]; then
    SAMPLE_APP_SERVICE_CONF=/etc/systemd/system/nodeserver.service
    cat << EOF > $SAMPLE_APP_SERVICE_CONF
[Unit]
Description=Node.js Example Server

[Service]
ExecStart=/usr/bin/node $SAMPLE_DIR/server/server.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nodejs-example
Environment=NODE_ENV=production PORT=3000

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable nodeserver.service                                                 >> $LOGFILE 2>&1 || { echo "---Failed to enable the sample node service---" | tee -a $LOGFILE; exit 1; }
    systemctl start nodeserver.service                                                  >> $LOGFILE 2>&1 || { echo "---Failed to start the sample node service---" | tee -a $LOGFILE; exit 1; }
else
	slc run $SAMPLE_DIR &                                                               >> $LOGFILE 2>&1 || { echo "---Failed to start the application---" | tee -a $LOGFILE; exit 1; }
fi
		
echo "---finish installing sample application---" | tee -a $LOGFILE 2>&1