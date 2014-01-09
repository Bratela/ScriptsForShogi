require 'net/http'
require 'pg'

conn = PGconn.connect("127.0.0.1", "5432", "", "", "maindb", "generall", "123456")
100.times do |x|
	uri = URI('http://www.playok.com/ru/game.phtml/13'+"%05d" % x+'.txt?sg')
	result = Net::HTTP.get(uri)
	black = /Gote \"([^\"]+)\"/
	white = /Sente \"([^\"]+)\"/
	p1 = result.scan(black)[0][0]
	p2 = result.scan(white)[0][0]
	begin
		conn.exec("INSERT INTO users (login) VALUES ('"+p1+"')");
		p p1+" added"
	rescue  PGError
		p p1+" exists";
	end
	begin
		conn.exec("INSERT INTO users (login) VALUES ('"+p2+"')");
		p p2+" added"
	rescue  PGError
		p p2+" exists";
	end
end
