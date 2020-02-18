#!/bin/sh
CWD=${PWD}

if [ -z "${CONTROLLER}" ]; then
	export CONTROLLER="192.168.56.91";
fi

if [ -z "${APPD_PORT}" ]; then
	export APPD_PORT=8090;
fi

-Dappdynamics.controller.hostName=${CONTROLLER} -Dappdynamics.agent.accountAccessKey=${CONTROLLER_KEY} -Dappdynamics.controller.port=${APPD_PORT} -Dappdynamics.agent.applicationName=${APP_NAME} -Dappdynamics.sim.enabled=true -Dappdynamics.controller.ssl.enabled=${CONTROLLER_SSL}

JAVA_OPTS="-Dappdynamics.controller.hostName=${CONTROLLER} -Dappdynamics.controller.port=${APPD_PORT}" -Dappdynamics.controller.ssl.enabled=${CONTROLLER_SSL} -Dappdynamics.agent.accountAccessKey=${CONTROLLER_KEY};

JAVA_OPTS="${JAVA_OPTS} -Xmx512m -XX:MaxPermSize=128m";

echo $JAVA_OPTS;

cd ${CATALINA_HOME}/bin;

java ${JAVA_OPTS} -jar ${AGENT_HOME}/db-agent.jar

cd ${CWD}
