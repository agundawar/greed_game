class DiceSet
  attr_reader :total
  
  def initialize(total)
  	@total = total
  end
  	
  def roll
    @values = []
    @total.times do 
      @values.push(rand(1..6))
    end
    @values
  end
end


class Player
	attr_reader :name
	attr_reader :score

	def initialize(name)
		@name = name.capitalize
		@score = 0
	end

	def to_str
		@name
	end

	def update_score(score)
		@score += score
	end
end

class Game
	$FINAL_SCORE = 3000
	$MIN_TURN_SCORE = 300
	$DEFAULT_DICE_COUNT = 5

	@@players = []

	def start
		puts "Welcome to Greed Game! Enter no. of players(>2)?"
		num_players = gets.chomp
		while !(num_players.to_i.to_s == num_players && num_players.to_i >= 2)
			puts "Enter Number >= 2"
			num_players = gets.chomp
		end
		num_players.to_i.times do |n|
			puts "Enter Player. #{n+1} name:"
			@@players.push(Player.new(gets.chomp))
		end
		get_status
		play_game
	end

	def get_status
		puts "--------------------"
		puts "Current Scoreboard\n"
		@@players.each do |player|
			puts "#{player.name}: #{player.score}"
		end
		puts "--------------------"
	end

	def get_winner
		@@players.sort! {|p1, p2| p2.score <=> p1.score}
		return @@players[0].name
	end

	def play_turn
		dice_count = $DEFAULT_DICE_COUNT
		turn_score = 0
		while dice_count > 0 do
			dices = DiceSet.new(dice_count)
			roll_details = calculate_score(dices.roll)
			puts "Current Roll details. #{roll_details[:values]} \nCurrent Roll Score. #{roll_details[:score]}"
			turn_score += roll_details[:score]
			return 0 if roll_details[:score] == 0
			roll_details[:count] == 0 ? dice_count = $DEFAULT_DICE_COUNT : dice_count = roll_details[:count]
			puts "Roll again with #{dice_count} dices or Pass to next player?(Y for Turn, N for Pass)"
			return turn_score if gets.chomp == "N"
		end
		turn_score
	end

	def play_game
		final_round = false
		final_mode = false
		until (final_round && final_mode)
			puts "Final Round! Final turn for each player!" if final_mode
			final_round = true if final_mode
			@@players.each do |player|
				puts "Current Player. #{player.name}"
				turn_score = play_turn
				player.update_score(turn_score) if turn_score >= $MIN_TURN_SCORE
				puts "Points scored in current run #{turn_score}. Total score #{player.score}"
				final_mode = true if player.score >= $FINAL_SCORE
			end
			get_status
			if final_round
				puts "Game Over! Winner is #{get_winner}!" 
			end
		end
	end

	def calculate_score(roll_set)
	  score = 0
	  non_scoring_count = roll_set.length
	  points_map = Hash.new(0)
	  points_map[1] = 100
	  points_map[5] = 50

	  num_count = Hash.new(0)
	  roll_set.each {|dice| num_count[dice] += 1}
	  num_count.each do |num, count|
	  	if count >= 3
	  		if num == 1
	  			score += 1000
	  		else
	  			score += num * 100
	  		end
	  		count -= 3
	  		non_scoring_count -= 3
	  	end
	  	score += points_map[num] * count
	  	non_scoring_count -= count if points_map[num] > 0
	  end
	  {values: roll_set, score: score, count: non_scoring_count}
	end
end

greed_game = Game.new
greed_game.start