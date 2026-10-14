FROM tomcat:9-jdk8-temurin

COPY appx.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
