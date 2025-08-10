-- create test user
create user 'test_user'@'%' identified by 'password';
grant all privileges on test.* to 'test_user'@'%';

-- create a directory to store the certificates
mkdir -p /etc/mysql/ssl
-- chown -R root:root /etc/mysql/ssl
cd /etc/mysql/ssl
cd ~/repos/mariadb
chown 999:999 ssl/ca-cert.pem ssl/server-cert.pem ssl/server-key.pem
chmod 644 ssl/ca-cert.pem ssl/server-cert.pem
chmod 600 ssl/server-key.pem

-- generate a CA certificate:
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 365000 -key ca-key.pem -out ca-cert.pem

-- server certificate
openssl req -newkey rsa:2048 -days 365000 -nodes -keyout server-key.pem -out server-req.pem
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 365000 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem

-- verify the certificates:
openssl verify -CAfile ca-cert.pem server-cert.pem

show variables like '%ssl%';

-- alter user
alter user 'test_user'@'%' require ssl;

-- copy ca-cert.pem from server to client
mkdir -p /etc/mysql/ssl/
scp root@mariadb:/etc/mysql/ssl/ca-cert.pem /etc/mysql/ssl/

-- to login to the database, we can use
mariadb -u test_user -ppassword -P 3336 --ssl-ca ssl/ca-cert.pem
mariadb --ssl-ca=/etc/mysql/ssl/ca-cert.pem --ssl-verify-server-cert -h node1 -u test_user

-- or add these two lines to the client configuration file under mariadb-client tag:
ssl-ca=/etc/mysql/ssl/ca-cert.pem
ssl-verify-server-cert

-- and use the simple syntax:
mariadb -h node1 -u test_user -p
