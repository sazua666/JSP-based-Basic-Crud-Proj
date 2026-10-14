FROM tomcat:9.0-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/lib
COPY *.jsp *.html *.css /usr/local/tomcat/webapps/ROOT/
COPY mysql-connector-java-8.0.20.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/
RUN cp /usr/local/tomcat/webapps/ROOT/indexv3.html /usr/local/tomcat/webapps/ROOT/index.html
EXPOSE 8080
CMD ["catalina.sh", "run"]
