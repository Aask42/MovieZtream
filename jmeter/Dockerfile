FROM alpine:latest

MAINTAINER Carlos Doki (carlosdoki@gmail.com)

RUN apk update && apk add openjdk8

#hack for centos docker bug
RUN mkdir -p /run/lock 

# Prepare appdynamics user and directory
RUN mkdir -p /appdynamics
RUN addgroup appdynamics
RUN adduser -D --ingroup appdynamics appdynamics

# Add JMeter and scripts
RUN mkdir -p /appdynamics/jmeter
RUN mkdir -p /appdynamics/jmeter/scripts
ADD /jmeter/ /appdynamics/jmeter/
ADD /scripts/ /appdynamics/jmeter/scripts/

# Add the startup script
ADD /start.sh /appdynamics/
RUN chmod a+x /appdynamics/start.sh

# Run the startup script
CMD /appdynamics/start.sh && tail -F /appdynamics/jmeter/scripts/jmeter.log

