require 'sinatra'
require 'sequel'
require 'sinatra/respond_with'
require 'json'


DB = Sequel.connect( ENV['DATABASE_URL'] || 'postgres://localhost/munki')
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
  colors = (0..15).to_a.sample 2
#  troll = sprintf("\x03%i,%i",colors[0],colors[1]).force_encoding('ASCII-8BIT')
  troll = "\x03#{colors[0]},#{colors[1]}"
  phrases = []
  0.upto(num) do
    #troll << "#{adjectives.rand[:adjective]} #{animals.rand[:animal]} #{nouns.rand[:noun]}\x16"
    
    phrases.push("#{adjectives.rand[:adjective]} #{animals.rand[:animal]} #{nouns.rand[:noun]}" + (params[:space] == "true" ? " " : "") +"\x16")
  end
  troll += phrases.join(params[:space] == "true" ? " " : "")
  params[:downcase] == "true" ? troll.downcase : troll.upcase
end

post '/adjective' do
  adj = params[:adjective]
  begin 
    adjectives.insert(adjective: adj.to_s.downcase)
    "success"
  rescue Sequel::UniqueConstraintViolation => e
    "failure"
  end
end

post '/animal' do
  animal = params[:animal]
  begin
    animals.insert(animal: animal.to_s.downcase)
    "success"
  rescue Sequel::UniqueConstraintViolation => e
    "failure"
  end
end

post '/noun' do
  noun = params[:noun]
  begin
    nouns.insert(noun: noun.to_s.downcase)
    "success"
  rescue Sequel::UniqueConstraintViolation => e
    "failure"
    end
end

get '/dbdump' do
  @DB = DB
  erb :dbdump
end

get '/db.json' do
  content_type :json
  {adjectives: adjectives.map(:adjective), animals: animals.map(:animal), nouns: nouns.map(:noun)}.to_json
end

