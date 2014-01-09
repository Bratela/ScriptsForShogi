#sudo apt-get install libpq-dev
#sudo gem install pg

require 'pg'

conn = PGconn.connect("127.0.0.1", "5432", "", "", "maindb", "generall", "123456")
begin
conn.exec("INSERT INTO users (login) VALUES ('generall')");
rescue  PGError
p "duplication"
end 
conn.exec("INSERT INTO users (login) VALUES ('Gorkoff')");
conn.exec("INSERT INTO users (login) VALUES ('generall')");
#conn.exec("insert into game (whitename, blackname,id) VALUES ('generall', 'Gorkoff', 1)")
