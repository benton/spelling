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
end
