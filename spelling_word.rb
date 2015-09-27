# just a sctruct, for now
class SpellingWord
    DEFAULT_ATTRIBUTES  = {
    answer:     '',
    definition: '',
    usage:      '',
    level:      0,
  }
  DEFAULT_ATTRIBUTES.each{|attrib,val| attr_accessor attrib}
  def initialize(options = {})
        DEFAULT_ATTRIBUTES.each do |option, val|
      instance_variable_set "@#{option}", options[option] || val
    end
  end

  # returns an Array of SpellingWords loaded from infile
  def self.load_words_from_file(infile, word_level)
    returned_words = Array.new
    File.open(infile, "r") do |f|
      # loop through lines, maintaining a latest_word as state
      latest_word = nil
      f.each_line do |line|
        # case 0 - the line is whitespace only - save the latest word
        if matches = line.match(/\A\s+\Z/)
          if latest_word != nil
            returned_words << latest_word
            latest_word = nil
          end
        # case 1 - this line is a single word
        elsif matches = line.match(/\A\s*(\S+)\s*\Z/)
          # if there's no latest_word, it's a new candidate -
          # otherwise, it's a definition
          if latest_word == nil
            latest_word = SpellingWord.new(
              answer: matches[1].upcase, level: word_level
            )
          else
            latest_word.definition = line.strip
          end
        # case 2 - the line begins with a quote character - this line is usage
        elsif matches = line.match(/\A["']/)
          latest_word.usage = line.strip
        else # case 3 - the line has several unquoted words - the definition
          latest_word.definition = line.strip
        end
      end
    end
    return returned_words
  end

end
