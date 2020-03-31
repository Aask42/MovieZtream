FROM alpine:latest

MAINTAINER Carlos Doki (carlosdoki@gmail.com)

RUN apk update && apk add unzip openjdk8 iproute2 curl jq
RUN mkdir -p /run/lock && mkdir -p /tomcat
ADD user.dat /

WORKDIR /tomcat

# INSTALL TOMCAT
RUN curl http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.51/bin/apache-tomcat-8.5.51.tar.gz -O && \
    tar xvzf apache-tomcat-8*tar.gz --strip-components=1 && \
    rm apache-tomcat-*.tar.gz
#    ln -s /apache-tomcat-8.5.51 /tomcat
ENV CATALINA_HOME /tomcat

RUN rm -Rf /tomcat/conf/server.xml && rm -Rf /tomcat/conf/tomcat-users.xml
ADD server.xml /tomcat/conf/
ADD tomcat-users.xml /tomcat/conf/

WORKDIR /

RUN export access_token=$(curl -X POST -d @user.dat https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token | jq .access_token ) && \
    export header=$( echo "Authorization: Bearer ${access_token/$\"/}" | sed -e "s/\"//g")  && \
    export javaagent=$(curl -s https://download.appdynamics.com/download/downloadfilelatest/ | jq  ".[] | .download_path" |grep sun-jvm | sed -e "s/\"//g") && \
    curl -L -O -H "$header" $javaagent && mv AppServerAgent-*.zip AppServerAgent.zip && \
    unzip /AppServerAgent.zip -d /tomcat/appagent && \
    rm AppServerAgent.zip

#Machine Agent Install
ENV MACHINE_AGENT_HOME /machine_agent
RUN export access_token=$(curl -X POST -d @user.dat https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token | jq .access_token ) && \
    export header=$( echo "Authorization: Bearer ${access_token/$\"/}" | sed -e "s/\"//g")  && \
    export machine=$(curl -s https://download.appdynamics.com/download/downloadfilelatest/ | jq  ".[] | .download_path" |grep machineagent-bundle-64bit-linux* | sed -e "s/\"//g") && \
    curl -L -O -H "$header" $machine && mv machine*.zip MachineAgent.zip && \
    unzip MachineAgent.zip -d ${MACHINE_AGENT_HOME} && \
    rm MachineAgent.zip
ADD analytics-agent.properties /
RUN mv /analytics-agent.properties ${MACHINE_AGENT_HOME}/monitors/analytics-agent/conf

RUN mkdir /apps
ADD apps /apps/
ADD startup.sh /
ADD env.sh /

RUN mkdir -p /appdynamics/jmeter
ADD jmeter /appdynamics/jmeter
ADD start-machine-agent.sh /
RUN chmod +x /startup.sh && chmod +x /start-machine-agent.sh && chmod +x /env.sh && rm -f user.dat
WORKDIR /

CMD ["/bin/sh","/startup.sh"]

EXPOSE 80	
EXPOSE 8080
EXPOSE 8009

