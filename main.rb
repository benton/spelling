#!/usr/bin/env ruby
# Runs a GUI application for testing spelling words
require 'gosu'
require File.join(File.dirname(__FILE__), 'spelling_word')

# used to hold and model all game state, so it can be displayed in-window
class MainWindow < Gosu::Window

  RED, GREEN, WHITE = 0xff_ff0000, 0xff_00ff00, 0xff_ffffff

  def initialize
    @window_width, @window_height = 1024, 768
    @fonts = Hash.new
    super(@window_width, @window_height, true)
    self.caption  = 'Dixie Spelling Bee Trainer 2015'
    starting_word = SpellingWord.new(answer: self.caption)
    @words, @current_word, @word_hidden = Array.new, starting_word, false
    @current_guess = ''
    Thread.new {load_words} # spawns a thread
  end

  def button_down(id)
    super(id)
    if id == Gosu::Button::KbEscape
      `say "#{@current_word.answer}"`
    elsif id == Gosu::Button::KbTab
      Thread.new {`say "#{@current_word.usage}"`}
    elsif (id == Gosu::Button::KbEnter) || (id == Gosu::Button::KbSpace) ||
      (id == Gosu::Button::KbReturn)
      if @words_loaded
        if @word_hidden
          @word_hidden = false
          if @current_word.answer == @current_guess
            @status = "Correct!"
          else
            @status = "Incorrect. You guessed: #{@current_guess}"
            @words_loaded = false # disable next word for 5 seconds
            Thread.new {sleep 5 ; @words_loaded = true}
          end
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
    @current_word = @words[Random.rand(@words.size)]
    @status = "Press ESC to repeat the level #{@current_word.level} word."+
      " Press TAB to hear it used in a sentence."
    `say "Please spell?"`
    sleep(0.3)
    `say "#{@current_word.answer}"`
    sleep(0.3)
    Thread.new {`say "#{@current_word.definition}"`}
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
