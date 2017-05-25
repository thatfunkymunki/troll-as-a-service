require 'sinatra'
require 'sequel'
DB = Sequel.connect( 'postgres://localhost/troll')
module RandomEntry
  def rand
    self.order(Sequel.lit('random()')).first
  end
end
Sequel::Dataset.class_eval{ include RandomEntry}
adjectives = DB[:adjectives]
animals = DB[:animals]
nouns = DB[:nouns]


get '/troll' do
  num = params[:num].to_i || 1
  colors = 2.times.map{Random.rand(15)}
#  troll = sprintf("\x03%i,%i",colors[0],colors[1]).force_encoding('ASCII-8BIT')
  troll = "\x03#{colors[0]},#{colors[1]}"
  0.upto(num) do
    troll << "#{adjectives.rand[:adjective]} #{animals.rand[:animal]} #{nouns.rand[:noun]}\x16".upcase
  end
  troll
end

post '/adjective' do
  adj = params[:adjective]
  adjectives.insert(adjective: adj)
  "success"
end

post '/animal' do
  animal = params[:animal]
  animals.insert(animal: animal)
  "success"
end

post '/noun' do
  noun = params[:noun]
  nouns.insert(noun: noun)
  "success"
end


