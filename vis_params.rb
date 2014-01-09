# encoding: utf-8

require 'pg'
require "./k_means.rb"

temp_file = "stats.txt"

gnuplot = "gnuplot.cmd"

table = "bad"

conn = PGconn.connect("192.168.1.200", "5432", "", "", "shogi", "generall", "123456")

data = [];
vectors = [];
(0..33).each do |x|
	data[x] = {};
	query = "SELECT * FROM params_"+table+" WHERE param_no = " + x.to_s + "";
	res = conn.exec(query);

	n=0;
	res.each do |record|
		vectors += [[]] if vectors.size <= n
		vectors[n][x] = record["value"].to_i;
		data[x][record["value"].to_i] == nil ? data[x][record["value"].to_i] = 1 : data[x][record["value"].to_i] += 1;
		n+=1;
	end
	data[x] = data[x].sort_by{|k| k[0]}
end

p "Data loaded"

p "vectors count: " + vectors.size.to_s
p "params count: " + vectors[0].size.to_s

min_functional = Float::INFINITY;
good_clusters = [];
n = 100;
i = 0;

n.times do 
	k = 10; # Random.rand(5) + 3;
	clusters = k_means(vectors, k);
	next if clusters == nil;
	est = quality(clusters);
	if(min_functional > est) then
		min_functional = est
		good_clusters = clusters
	end
	p i.to_s + " of " + n.to_s + " K = " + k.to_s;
	i+=1;
end

f = File.open("shogi_clusters_"+table+".txt", "w");
good_clusters.each do |cluster|
	center = midle(cluster)
	center.each do |param|
		f.write(param.to_i.to_s + "\t")
	end
	f.write("\n")
end
f.close
