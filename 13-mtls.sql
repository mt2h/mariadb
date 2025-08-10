
-- generate a private key for the client
openssl genrsa -out client-key.pem 2048

-- create a certificate signing request (CSR)
openssl req -new -key client-key.pem -out client-req.pem

-- sign the client certificate with the CA
openssl x509 -req -in client-req.pem -days 365 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem

-- verify certificates:
openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem

-- change ownership of key and ca
chown mysql:mysql *
chmod 600 *

-- require client certificates for Users
alter user 'test_user'@'%' require x509;

-- copy clients files from server to client:
scp root@node1:/etc/mysql/ssl/client*.pem /etc/mysql/ssl/

add these lines to the client configuration file under mariadb-client tag:
ssl-cert=/etc/mysql/ssl/client-cert.pem
ssl-key=/etc/mysql/ssl/client-key.pem