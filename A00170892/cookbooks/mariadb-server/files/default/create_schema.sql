CREATE database database1;
USE database1;
CREATE TABLE WebServer(
id INT NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
 name VARCHAR(30),
 ip VARCHAR(30));
INSERT INTO WebServer (name,ip) VALUES ('WebServer1','192.168.56.103');
INSERT INTO WebServer (name,ip) VALUES ('WebServer2','192.168.56.104');
GRANT ALL PRIVILEGES ON *.* to 'WebServer1'@'192.168.56.103' IDENTIFIED by 'WebServer1';
GRANT ALL PRIVILEGES ON *.* to 'WebServer2'@'192.168.56.104' IDENTIFIED by 'WebServer2';
