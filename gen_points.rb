require "./k_means.rb"

points = [];

center = [Random.rand(500), Random.rand(500)]
30.times { points += [[center[0] - 75 + Random.rand(150), center[1] - 75 + Random.rand(150)]] }

center = [Random.rand(500), Random.rand(500)]
30.times { points += [[center[0] - 75 + Random.rand(150), center[1] - 75 + Random.rand(150)]] }

center = [Random.rand(500), Random.rand(500)]
30.times { points += [[center[0] - 75 + Random.rand(150), center[1] - 75 + Random.rand(150)]] }

f = File.open("clusters.txt", "w");
points.each do |point|
	f.write(point[0].to_s + "\t" + point[1].to_s + "\n");
end
f.close();

system(" gnuplot plot_clusters -persist");

min_functional = Float::INFINITY;
good_clusters = [];

100.times do 
	clusters = k_means(points, Random.rand(5) + 2);
	est = quality(clusters);
	if(min_functional > est) then
		min_functional = est
		good_clusters = clusters
	end
end

i=1
good_clusters.each do |cluster|
	f = File.open("cluster"+ i.to_s + ".txt" , "w");
	cluster.each do |point|
		f.write(point[0].to_s + "\t" + point[1].to_s + "\n");
	end
	f.close();
	i+=1;
end


system(" gnuplot plot_clusters2 -persist");
