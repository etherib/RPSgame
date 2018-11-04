require 'sinatra'
require 'sqlite3'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/score.db")


class Score
	include DataMapper::Resource
	property :id, Serial
	property :wins, Integer, :required => true, :default => 0
	property :ties, Integer, :required => true, :default => 0
        property :losses, Integer, :required => true, :default => 0
end
DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

#set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"


result = nil


@s = Score.new
@s.wins = 0
@s.ties = 0
@s.losses=0
@s.save


before do
  @defeat = {rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '/' do
    erb :make_move
end

delete '/delete' do

  #sample code for using plain SQL
  
  #open connection to database
#  db = SQLite3::Database.open "test.db"
#  db.execute "delete from cars where id = 'id'"


  @scores = Score.get 1
  @scores.wins=0
  @scores.ties=0
  @scores.losses=0
  @scores.save
  
  @ties = 0
  @losses = 0
  @wins = 0


erb :index

end

post '/' do
  player_throw = params[:throw].downcase.to_sym


  
  unless @throws.include?(player_throw)
    halt 403, "You must throw one of: #{@throws}"
  end

  computer_throw = @throws.sample

  
  if player_throw == computer_throw
    @scores = Score.get 1
      
    @scores.ties = @scores.ties + 1
    @scores.save
    @result = "You tied with the computer. Try again!"
  elsif computer_throw == @defeat[player_throw]
   @scores = Score.get 1
   
   @scores.wins = @scores.wins + 1
   @scores.save
    @result = "Nicely done; #{player_throw} beats #{computer_throw}!"
  else
    @scores = Score.get 1

    @scores.losses = @scores.losses + 1
    @scores.save

    @result = "Ouch; #{computer_throw} beats #{player_throw}. Better luck next time!"
  end


  # get the total score counts
  @scores = Score.new
  @scores = Score.first

  # set an instance variable for the view
  # for some reason passing the @scores object doesn't work
  @wins = @scores.wins
  @ties = @scores.ties
  @losses = @scores.losses
  

  erb :index
    
end
