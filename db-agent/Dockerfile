FROM alpine:latest

MAINTAINER Carlos Doki (carlosdoki@gmail.com)

RUN apk update && apk add unzip openjdk8 iproute2 curl jq
RUN mkdir -p /run/lock
ADD user.dat /

WORKDIR /

#Agent Install
ENV AGENT_HOME /dbagent

RUN export access_token=$(curl -X POST -d @user.dat https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token | jq .access_token ) && \
    export header=$( echo "Authorization: Bearer ${access_token/$\"/}" | sed -e "s/\"//g")  && \
    export dbagent=$(curl -s https://download.appdynamics.com/download/downloadfilelatest/ | jq  ".[] | .download_path" |grep db-agent -m 1 | sed -e "s/\"//g") && \
    curl -L -O -H "$header" $dbagent && \
    mv db-agent*.zip dbagent.zip && \
    unzip /dbagent.zip -d ${AGENT_HOME}  && \
    rm dbagent.zip 
ADD startup.sh /
RUN chmod +x /startup.sh
WORKDIR /
CMD ["/bin/sh","/startup.sh"]
