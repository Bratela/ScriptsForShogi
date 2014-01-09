require 'net/http'

uri = URI('http://www.playok.com/ru/game.phtml/1356173.txt?sg')
result = Net::HTTP.get(uri)
black = /Gote \"([^\"]+)\"/
white = /Sente \"([^\"]+)\"/
p result.scan(black)[0][0]
p "vs"
p result.scan(white)[0][0]
