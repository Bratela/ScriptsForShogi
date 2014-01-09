
# wget "http://www.playok.com/ru/game.phtml/generall93.zip?gid=sg&uid=generall93" --tries=3 -O output.file 

require 'pg'
conn = PGconn.connect("127.0.0.1", "5432", "", "", "maindb", "generall", "123456")
res = conn.exec("SELECT login FROM users");
n = res.count
i = 0
res.each do |x|
	i+=1;
	if i%200 == 0 then
		`echo "#{i} of #{n}" > status.txt`
	end
	login = x["login"];
	`wget "http://www.playok.com/ru/game.phtml/#{login}.zip?gid=sg&uid=#{login}" --tries=3 -q -O  /home/generall/temp/#{login}.zip `
end
