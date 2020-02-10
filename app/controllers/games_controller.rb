require 'open-uri'
require 'time'
require 'json'

class GamesController < ApplicationController
  def new
    session[:start] = Time.now
    letter_array = ('A'..'Z').to_a
    @letters = letter_array.sample(10)
  end

  def word_in_the_grid?(attempt, grid)
    attempt_hash = Hash.new(0)
    attempt.downcase.chars.each { |letter| attempt_hash[letter] += 1 }
    grid_hash = Hash.new(0)
    grid.downcase.chars.each { |letter| grid_hash[letter] += 1 }
    grid_hash
    attempt_hash.select { |letter, frequency| grid_hash[letter] < frequency }.empty?
  end

  def english_word?(attempt)
    url = 'https://wagon-dictionary.herokuapp.com/' + attempt
    attempt_serialized = open(url).read
    attempted_word_in_api = JSON.parse(attempt_serialized)
    attempted_word_in_api['found']
  end

  def message_selector(attempt, grid)
    return 'Well done!' if english_word?(attempt) && word_in_the_grid?(attempt, grid)
    return 'The word is not in the grid' unless word_in_the_grid?(attempt, grid)
    return 'This is not an english word' unless english_word?(attempt)
  end

  def score
    session[:end] = Time.now
    @word = params[:word]
    @grid = params[:grid]
    word_in_the_grid?(@word, @grid)
    # return true if the word is in the grid
    english_word?(@word) # return true if the word is english
    @message = message_selector(@word, @grid)
    p @message

    word_length = @word.length
    timer = (session[:end] - Time.parse(session[:start])).to_f

    @final_score = @message == 'Well done!' ? (1 / timer * word_length).round * 1000 : 0
  end
end
