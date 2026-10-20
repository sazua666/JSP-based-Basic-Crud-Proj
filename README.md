# JSP-based Basic CRUD Project

A small JSP web application for managing company report records. It includes an admin registration/login page, report creation and deletion, a report list, and a feedback form. The pages use JDBC to connect to MySQL.

## Technology

- JavaServer Pages (JSP) and HTML/CSS/JavaScript
- Apache NetBeans with Java Web support
- GlassFish Server
- MySQL Server and the MySQL command-line client
- MySQL Connector/J (JDBC driver)

## Requirements

Install Git, a JDK supported by your NetBeans and GlassFish versions, NetBeans with Java Web support, GlassFish, and MySQL Server. You also need the MySQL command-line client.

## 1. Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd JSP-based-Basic-Crud-Proj
```

Replace `<YOUR_GITHUB_REPOSITORY_URL>` with the HTTPS or SSH clone URL for your GitHub repository.

## 2. Create the database and tables

Start the MySQL server, open a terminal, and connect with the MySQL CLI:

```bash
mysql -u root -p
```

Enter your MySQL root password, then run the following SQL. The tables and column names match the queries used by the JSP pages:

```sql
CREATE DATABASE pslv_db;
USE pslv_db;

CREATE TABLE admin_users (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_admin_users_username (username)
) 

CREATE TABLE REPORT_LIST (
    ID VARCHAR(50) NOT NULL,
    TITLE VARCHAR(255) NOT NULL,
    AUTHOR VARCHAR(150) NOT NULL,
    PRIMARY KEY (ID)
) 

CREATE TABLE feedback (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    company VARCHAR(150) NOT NULL,
    report TEXT NOT NULL,
    PRIMARY KEY (id)
) 


To confirm the tables were created:

```sql
SHOW TABLES;
```

Exit the MySQL prompt with `exit;`.

## 3. Set the JDBC connection values

The database URL and login details are currently hard-coded in these JSPs:

- `addreport.jsp`
- `feedbackv3.jsp`
- `login.jsp`
- `register.jsp`
- `removereport.jsp`
- `reportsv3.jsp`

In each file, change the connection settings to match your local MySQL setup. For the SQL above, the URL should be:

```java
String dbUrl = "jdbc:mysql://localhost:3306/pslv_db";
```

Set `dbUser` and `dbPass` to a MySQL account that has access to `pslv_db`. The checked-in example uses `root` and the placeholder password `password`; replace these values with your own local credentials. Do not commit real passwords. A dedicated MySQL account with permissions limited to this database is preferable to using `root`.

## 4. Add the MySQL JDBC driver to GlassFish

Download the Connector/J version appropriate for your MySQL server and Java version. Copy its JAR file into the GlassFish domain's `lib` directory, for example:

For MySQL 5.5, use Connector/J 5.1.49. For Connector/J 8.x, use a supported newer MySQL Server and keep the `com.mysql.cj.jdbc.Driver` class in the JSPs. Restart the GlassFish domain after copying the JAR so the server can load the driver.

## 5. Open and deploy in NetBeans

This repository contains the web pages and `WEB-INF/glassfish-web.xml`, but does not include NetBeans project metadata (such as `nbproject`) or a build file. Create a NetBeans web project and add these files to it:

1. In NetBeans, choose **File → New Project → Java Web → Web Application**.
2. Select your installed GlassFish server and a Java/Jakarta EE version supported by that server.
3. In the new project's **Web Pages** folder, copy the repository's JSP files, `indexv3.html`, and `stylexv3.css`.
4. Copy the repository's `WEB-INF/glassfish-web.xml` into the new project's `Web Pages/WEB-INF` folder, preserving the `WEB-INF` directory structure. It sets the application context root to `/pca2final`.
5. Build and deploy/run the web project from NetBeans.

If NetBeans offers an import workflow for an existing web application in your version, you can use it, but this repository by itself is not a complete generated NetBeans project.

## 6. Run the application

With GlassFish running, open:

```text
http://localhost:8080/pca2final/login.jsp
```

To create the first account, open the registration page:

```text
http://localhost:8080/pca2final/register.jsp
```

## Troubleshooting

- **JDBC driver class not found:** Check that the Connector/J JAR is in the GlassFish domain `lib` directory and restart GlassFish. For MySQL 5.5, verify that the JSPs use `com.mysql.jdbc.Driver` and Connector/J 5.1.49.
- **Access denied or unknown database:** Verify `dbUrl`, `dbUser`, and `dbPass` in all six JSPs, ensure MySQL is running, and confirm that `pslv_db` and its tables exist.
- **Page not found:** Confirm the project deployed successfully, the context root is `pca2final`, and the URL uses the configured GlassFish port.
