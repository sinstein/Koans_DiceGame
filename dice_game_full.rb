require File.expand_path(File.dirname(__FILE__) + '/neo')

class DiceSet
  
  @values = []

  def initialize()
    @values = []
  end

  def roll(count)
    @values = []
    count.times do
      @values.push(1 + rand(6)) 
    end
    score(@values)
  end

  def score(dice)
    score = 0
    remaining = dice.length
    (1..6).each do |i|
      slice = dice.select {|d| d == i}
      if(slice.size >= 3)
        remaining -= 3
        if i == 1
          score += 1000
        else
          score += (i * 100)
        end
      end
      
      rest = slice.size % 3
      if i == 1
        score += rest * 100
        remaining -= rest
      elsif i == 5
        score += rest * 50
        remaining -= rest
      end
    end
    
    if (remaining == 0)
      remaining = 5
    end
      puts"\e[34mYou scored #{score} with #{remaining} unscored dice. Throw: #{dice}\e[0m"
      return [score, remaining]
  end
end


class Game 
  @number
  @score
  
  def init_game
    print "Enter number of players: "
    @number = gets.chomp.to_i
    @score = Array.new(@number)
    
    puts "You must score atleast 300 in one turn to accumulate score"
    @number.times do |x|
      @score[x] = 0
    end
    
    play_game
  end

  def display
    puts "\n"
    @number.times do |x|
      puts "\t\e[35mPlayer #{x} at #{@score[x]}\e[0m"
    end
  end

  def valid(x)
    puts "\n\e[33mTurn for player #{x}\e[0m"
    if(@score[x] < 300)
      rem = 0
      first_score = 0
      dc = DiceSet.new()
      first_score, rem = dc.roll(5)
      
        if(first_score >= 300)
          puts "You are now in the game!!"
          @score[x] = first_score
          return true
        else
          puts "\e[31mWait for next turn\e[0m"
          return false
        end
    else   
      return true
    end
  end

  def play_game
    dice = DiceSet.new
    winner = 0 
    x = 0
    while (@score[x] < 3000)
      display
      while(!valid(x))
        x = (x + 1) % @number
      end

      round_score = 0
      remaining = 5

      while remaining != 0 do
        roll_score, remaining = dice.roll(remaining)

        if (roll_score == 0)
          round_score = 0
          break
        elsif (remaining >= 1)
          round_score += roll_score
          print "Y to roll the #{remaining} dice. N to stop turn:  "
          choice = gets.chomp
          break if choice == "N"
        end
      end
      puts "\e[32mRound score for player #{x} is #{round_score}\e[0m "

      @score[x] += round_score

      break if (@score[x] >= 3000)
      x = (x + 1) % @number
    end

    display
    puts "\n\n*** Last Round of Game ***"
    
    (@number - 1).times do
      x = (x + 1) % @number
      
      round_score = 0
      remaining = 5
      while remaining != 0 do
        roll_score, remaining = dice.roll(remaining)
        puts "\e[34mYou scored #{roll_score} with #{remaining} unscored dice.\e[0m"

        if (roll_score == 0)
          round_score = 0
          break
        elsif (remaining > 0)
          round_score += roll_score  
          choice = gets.chomp
          print "Y to roll the #{remaining} dice. N to stop turn:  "
          choice = gets.chomp
          break if choice == "N"
        end
      end
      puts "\e[32m Round score for player #{x} is #{round_score}\e[0m"
      @score[x] += round_score
    end

    declareWinner 
  end

  def declareWinner
    winner = 0
    @number.times do |x|
      if (@score[x] > @score[winner])
        winner = x
      end
    end
    puts "\n\n******* The winner is player #{winner} with score: #{@score[winner]}! ******"
  end
end    

g1 = Game.new
g1.init_game


