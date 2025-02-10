FROM tomcat:10-jdk21
LABEL project="vprofile"
LABEL name="zarrcloud"

RUN rm -rf /usr/local/tomcat/webapps/*

EXPOSE 8080