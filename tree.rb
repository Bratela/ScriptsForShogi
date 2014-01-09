# encoding: utf-8
require "tree"
require 'pg'



# SELECT * FROM matches INNER JOIN moves ON matches.numer = moves.match_id WHERE moves.move_no <= 5 LIMIT 100
# SELECT match_id, cnt FROM (SELECT match_id, COUNT(match_id) AS cnt FROM moves GROUP BY match_id ) AS FOO WHERE cnt < 20 LIMIT 100

conn = PGconn.connect("192.168.1.200", "5432", "", "", "shogi", "generall", "123456")



class ShogiNode
	attr_accessor :rate, :from, :to  
	def initialize()
		@rate = 0 ;
		@from = [];
		@to = [];
	end
end



class Stat
	attr_accessor :root;
	def initialize(conn)
		@offset = 0;
		@conn = conn 
		@root = Tree::TreeNode.new("root", ShogiNode.new)
	end
	def add_match()

		query = "SELECT numer, sente_rate, gote_rate, result  FROM matches LIMIT 100 OFFSET "+ @offset.to_s;
		#execute hereAn encoding is a set of rules that assign numeric values to each text character

		res = @conn.exec(query);
		res.each do |record|

			q2 = "SELECT * FROM moves WHERE move_no <= 10 AND match_id = " + record["numer"].to_s + " ORDER BY move_no";
			res2 =  @conn.exec(q2);
			current = @root;
			sres = 0;
			gres = 0;
			if record["result"] == "s" then
				sres = 2;
				gres = -0.5;
			end
			if record["result"] == "g"
				sres = -0.5;
				gres = 2;
			end


			res2.each do |move|
				move_str = move["peace"];
				if move["droped"] == "t" then
					move_str +="*";
				else
					move_str += move["from_x"].to_s + (move["from_y"].to_i + "a".ord - 1).chr
				end
				move_str += move["to_x"].to_s + (move["to_y"].to_i+"a".ord - 1).chr
				if move["promote"] == "t" then
					move_str += "+"
				end

				#search for move in tree
				found = false
				current.children do |child|
					if child.name == move_str then
						found = true;
					end			
				end

				rate = if move["move_no"]%2 == 0 then record["sente_rate"].to_i*sres else record["gote_rate"].to_i*gres end

				#if exists, add rate
				if found then	
					current = current[move_str];
					current.content.rate += rate.to_i / 1250.0;
				else #else, create new Node
					s = ShogiNode.new;
					s.rate = rate.to_i / 1250.0;
					current.add( Tree::TreeNode.new(move_str, s) )
					current = current[move_str];
				end
			end
		end
		@offset += 100;
	end

	def output()
		@root.each do |node|
			print " "*node.node_depth
			print node.node_depth.to_s + "| "
			print node.name
			print " :: "
			print node.content.rate.to_s
			print "\n"
		end
	end

	def thinOut(node)
		first = [];
		node.children do |child|
			first +=[[child.name, child.content.rate]];
		end
		first.sort! {|x,y| y[1] <=> x[1] }
		n=0;
		first.each do |a|
			n += 1;
			next if n <= 4;
			node.remove!(node[a[0]]);
		end
	end
	def maxChild(node)
		max_rate = 0;
		max_node = "";
		node.children do |child|
			if child.content.rate > max_rate then
				max_rate = child.content.rate
				max_node = child
			end
		end
		return max_node;
	end
end

stat = Stat.new(conn);
c = 500;
n = 0;
c.times do 
	stat.add_match();
	puts n.to_s + " of " + c.to_s
	n += 1;
#	stat.add_match();
end
#stat.thinOut(stat.root)
#stat.root.each do |child|
#	stat.thinOut(child);
#end

print "Statistics loaded!\n"

while 1
	current = stat.root

	move = gets.strip!

	while current[move] != nil && move != "" && current[move] != "" 
		current = current[move]
		best =stat.maxChild(current);
		if best == "" then
			current = stat.root
			move = gets.strip!
			next
		end
		print "best responce: " + best.name + " rate: "+ best.content.rate.to_s + "\n"
		move = gets.strip! 
		if move == "cancel" then
			current = stat.root
			move = gets.strip! 
		end
	end
	print "no such move in tree!\n"

end
#stat.root.print_tree();
#stat.output();