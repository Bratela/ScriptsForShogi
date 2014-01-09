def midle(cluster)
	#Центр "масс"
	res = [0]*cluster[0].size();
	cluster.each do |e|  
		i = 0;
		e.each do |x|
			res[i] += x;
			i+=1;
		end
	end
	res.map! {|x| x/cluster.size.to_f}
	return res;
end

def dist(x1,x2)
	if(x1.size != x2.size)
		raise "WrongSizeException";
	end
	mode = 1
	if mode ==1 then # евклидово расстояние без корня
		dist = 0;
		for i in 0..x1.size-1
			dist += (x1[i]-x2[i])**2
		end
		return dist;
	end
	if mode == 2 then # косинусная мера
		dist = 0;
		x1_s = 0;
		x2_s = 0;
		for i in 0..x1.size-1
			dist += x1[i]*x2[i]
			x1_s += x1[i]**2;
			x2_s += x2[i]**2;
		end
		dist =1 - dist / Math.sqrt(x1_s) / Math.sqrt(x2_s)
	end

end

def quality1 (clusters)
	# Среднее внутрикластерное расстояние (относительно центра, ибо квадратичная сложность - зло)
	sum = 0;

	clusters.each do |cluster|
		center = midle(cluster)
		local_sum = 0
		cluster.each do |vector|
			local_sum += dist(vector, center);
		end
		sum += local_sum / cluster.size.to_f;
	end
	return sum;
end

def quality2 (clusters)
	# среднее межклассовое расстояние
	centers = [];
	clusters.each do |cl|
		centers += [midle(cl)];
	end
	sum = 0
	centers.each do |c1|
		centers.each do |c2|
			sum += dist(c1,c2)	
		end
	end
	return sum;
end

def quality (clusters) 
	# сие надо минимизировать
	return quality1(clusters)/quality2(clusters);
end

def find_nearest(vectors, point)
	min = Float::INFINITY
	imin = 0
	i = 0
	vectors.each do |vector|
		d = dist(vector, point)
		if(d < min) then
			min = d;
			imin = i;
		end
		i += 1;
	end
	return imin
end

def k_means(vectors, k)

	len = vectors.size;
	clusters = [];
	centers_index = [];
	if len < k then
		raise "count of clusters more than objects";
	end
	
	while centers_index.size != k do # пока не нарандомим k уникальных индексов
		centers_index = (1..k).map { Random.rand(len)}; # выбираем k случайных центров
		centers_index.uniq!
	end
	
	centers = centers_index.map{ |e| vectors[e] }

	clusters_new = []
	
	begin
		# Распределение по кластерам на основе центов
		clusters = clusters_new;
		clusters_new = k.times.map {[]};
		vectors.each do |vector|
			clusters_new[find_nearest(centers, vector)] += [vector];
		end

		#вычислить новые центры кластеров
		centers = [];
		clusters_new.each do |cluster|
			return nil if cluster == nil; # вернуть ничего, если какой-либо класстер оказался пуст
			return nil if cluster.size == 0; 
			centers += [midle(cluster)]
		end

	end until clusters_new == clusters

	return clusters_new
end


