#!/usr/bin/env ruby
# Runs a GUI application for testing spelling words
require 'fileutils'
require 'gosu'
require File.join(File.dirname(__FILE__), 'spelling_word')

# used to hold and model all game state, so it can be displayed in-window
class MainWindow < Gosu::Window

  # Each incorrect guess makes the word ERROR_WEIGHT times more likely
  ERROR_WEIGHT      = 8
  STATS_FILE        = "#{ENV['HOME']}/.spelling/incorect.yml"
  RED, GREEN, WHITE = 0xff_ff0000, 0xff_00ff00, 0xff_ffffff

  def initialize
    @window_width, @window_height = 1024, 768
    @fonts = Hash.new
    super(@window_width, @window_height, true)
    self.caption  = 'Dixie Spelling Bee Trainer 2015'
    starting_word = SpellingWord.new(answer: self.caption)
    @words, @current_word, @word_hidden = Array.new, starting_word, false
    @current_guess = ''
    # @mistakes is a Hash mapping words that were spellied incorrectly to
    # the number of times each was spelled incorrectly
    @mistakes = Hash.new
    Thread.new {load_words} # spawns a thread
  end

  def button_down(id)
    super(id)
    if id == Gosu::Button::KbEscape
      `say "#{@current_word.answer.downcase}"`
    elsif id == Gosu::Button::KbTab
      Thread.new {`say "#{@current_word.usage.downcase}"`}
    elsif (id == Gosu::Button::KbEnter) || (id == Gosu::Button::KbSpace) ||
      (id == Gosu::Button::KbReturn)
      if @words_loaded
        if @word_hidden
          @word_hidden = false
          if @current_word.answer == @current_guess
            @status = "Correct!"
            if (@mistakes[@current_word.answer] || 0) > 2
              @mistakes[@current_word.answer] -= 1
            else
              @mistakes.delete(@current_word.answer)
            end
          else
            @status = "Incorrect. You guessed: #{@current_guess}"
            @words_loaded = false # disable next word for 5 seconds
            Thread.new {sleep 5 ; @words_loaded = true}
            @mistakes[@current_word.answer] =
              (@mistakes[@current_word.answer] || 0) + 1
          end
          write_stats_file
        else
          Thread.new {next_word}
        end
      end
    elsif id == Gosu::Button::KbBackspace
      @current_guess = '' if @word_hidden
    elsif (id >= 4) && (id <= 29)
      if @word_hidden
        char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[id - 4]
        @current_guess += char
      end
    end
  end

  def next_word
    @word_hidden = true
    @current_guess = ''
    @current_word = get_next_word
    @status = "Press ESC to repeat the level #{@current_word.level} word."+
      " Press TAB to hear it used in a sentence."
    `say "Please spell?"`
    sleep(0.3)
    `say "#{@current_word.answer.downcase}"`
    sleep(0.3)
    Thread.new {`say "#{@current_word.definition.downcase}"`}
  end

  def draw
    # status
    center_text(@status, 20, 10)
    # guess
    center_text((@word_hidden ? @current_guess : ''), 
      60, @window_height * 0.25)
    # answer
    center_text((@word_hidden ? '' : @current_word.answer), 
      60, @window_height * 0.25, 
      (@current_word.answer == @current_guess ? GREEN : RED))
    # definition
    center_text((@word_hidden ? '' : @current_word.definition), 
      40, @window_height * 0.5)
    # usage
    center_text((@word_hidden ? '' : @current_word.usage), 
      40, @window_height * 0.75)
  end


  # spawns a thread that fills @words, then sets @words_loaded
  def load_words
    read_stats_file
    set_status("Loading words...")
    (1..2).each do |word_level|
      infile = File.join(File.dirname(__FILE__), 'data', "level#{word_level}.txt")
      set_status("Reading file #{infile}...")
      @words.concat(SpellingWord.load_words_from_file(infile, word_level))
    end
    @words_loaded = true
    @current_guess = @current_word.answer
    set_status("#{@words.size} words loaded. Press the space bar to start...")
  end

  # helper methods
  private

  # returns a word based on a random number, weighted by the incorrect guesses
  def get_next_word
    @weighted_words = Array.new
    @words.each do |this_word|
      answer, weight = this_word.answer, 1 # the default weight for words is 1
      weight = (@mistakes[answer] * ERROR_WEIGHT) if @mistakes[answer]
      weight.times {@weighted_words << this_word}
    end
    # now just return a random selection from the weighted Array
    @weighted_words[Random.rand(@weighted_words.size)]
  end

  def write_stats_file
    unless File.directory?(File.dirname(STATS_FILE))
      FileUtils.mkdir_p(File.dirname(STATS_FILE))
    end
    File.open(STATS_FILE, 'w') do |f|
      f.write "---\n" # YAML header
      @mistakes.keys.sort.each do |mistake|
        f.write "#{mistake}: #{@mistakes[mistake]}\n"
      end
    end
  end

  def read_stats_file
    if File.file?(STATS_FILE)
      File.open(STATS_FILE, 'r') do |f|
        f.each_line do |line|
          if matches = line.match(/\A(\S+)\s*:\s*(\d+)/)
            @mistakes[matches[1]] = Integer(matches[2])
          end
        end
      end
    end
  end

  # draws text centered on the screen with the top at y_origin
  def center_text(text, font_size, y_origin, color = WHITE)
    font = get_font(font_size)
    # if the width is larger than the window, remove words until it fits
    line_text, overflow_text = text, ''
    line_width = font.text_width(line_text)
    while line_width > @window_width
      words = line_text.split(/\s+/)
      break if words.size == 1  # render the remaining too-long word on 1 line
      line_text = words[0..(words.size-2)].join(' ')
      line_width = font.text_width(line_text)
      overflow_text = [words.last, overflow_text.split(/\s+/)].flatten.join(' ')
    end
    x_origin = (@window_width - line_width) / 2
    font.draw(line_text, x_origin, y_origin, 0, 1.0, 1.0, color)
    if overflow_text != ''
      next_y_origin = y_origin + font_size + (font_size * 0.3)
      center_text(overflow_text, font_size, next_y_origin, color)
    end
  end

  # returns a Gosu::Font of the desired size, created as needed
  def get_font(size)
    @fonts[size] ||= Gosu::Font.new(size)
  end

  def set_status(text)
    puts text
    @status = text
  end

end

window = MainWindow.new
window.show
