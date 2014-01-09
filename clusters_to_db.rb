require 'pg'

table = "good"

conn = PGconn.connect("192.168.1.200", "5432", "", "", "shogi", "generall", "123456")

i = 0;
f = File.open("shogi_clusters_"+table+".txt").each_line do |line|  
	array = line.split
	j = 0;
	array.each do | param|
		query = "INSERT INTO clusters_"+table+" (param_id, value, param_no) VALUES ("+ i.to_s+", " + param + ", "+j.to_s+")";
		res = conn.exec(query);
		j+=1;		
	end
	i+=1;
end