# Only use with updated Ruby, there was a range issue when tested on v1.8.7
# contact me @xorzor

# TODO: - output w/ capital and lowercase indicators after letters only; 
#           _ & ‾, respectively
#       - entropy score option on run
#       - option to alter ascii chart

module PwDecks
  def self.assign
    nonmeta = (("a".."z").to_a + ("A".."Z").to_a)
    # extra cycle of integers is unneeded but recursive generator is faster
    2.times {nonmeta += ("0".."9").to_a}
    nonmeta.shuffle!

    ascii = (" ".."~").to_a.shuffle.delete_if do |i|
      # discard possible sanitization or illegible characters
      i == "\\" || i == "`" || i == "'" || i == "\"" || i == "|" ||
      i == " "  || i == "_"
    end

    return Array.[](nonmeta, ascii)
  end

  def self.nonmeta
    a, _ = self.assign
    return a
  end

  def self.ascii
    _, a = self.assign
    return a
  end
end
    
class PwBase
  attr_accessor :options

  def initialize(args = {})
    if args[:from].kind_of? PwBase
      @options = args[:from].options
    end
    @options ||= {
      :default => true,
      :size => 10,
      :type => "ascii",
      :tests => false
    }
  end

  def self.generate(args = {})
    temp = PwBase.new
    args.each do |key, ele|
      temp.options[key] = ele
    end
    my = PwGenerator.new(:from => temp)
    my.valid_string
  end
end

class PwStrength < PwBase
  attr_accessor :word, :size, :count, :max

  def initialize(args = {})
    super(args) if defined?(super)
  end

  def setup(a) 
    @word = a.split("")
    @size = a.size.to_f
    
    @count = { :int => 0, :cha => 0, :met => 0, :lo => 0, :hi => 0 }
    @max   = { :int => (@size*0.4).ceil,  # integers
               :cha => (@size*0.6).ceil,  # alphabetical
               :met => (@size*0.5).ceil,  # metacharacters
               :lo  => (@size*0.3).ceil,  # lower case
               :hi  => (@size*0.3).ceil } # upper case
  end

  def self.strong?(a)
    my = PwStrength.new
    my.setup a
    my.cycle
    if my.count[:int] > my.max[:int] || my.count[:cha] > my.max[:cha] || 
       my.count[:met] > my.max[:met] || my.count[:lo]  > my.max[:lo]  ||
       my.count[:hi]  > my.max[:hi]  || my.count[:int] == 0           ||
       my.count[:lo]  == 0           || my.count[:hi]  == 0         then
      return false
    else
      return true
    end
  end

  def self.entropy(a)
    my = PwStrength.new
    my.setup a
    my.cycle
    return my.score
  end

  def self.formal_entropy(a)
    my    = PwStrength.new
    this  = my.entropy a
    years = ((2 ** this) / 31536000000.0) # 365d * 24h * 60m * 60s * 1000.0
    return "2^#{this} will be broken in #{years} years at 1000 guesses/sec."
  end

  def cycle
    if @count[:int] == 0 && @count[:cha] == 0 && @count[:met] == 0
      @word.map do |ele|
        if ele          =~ /^[0-9]$/
          @count[:int]  += 1
        elsif ele       =~ /^[a-zA-Z]$/
          @count[:cha]  += 1
          if ele        =~ /^[a-z]$/
            @count[:lo] += 1
          elsif ele     =~ /^[A-Z]$/
            @count[:hi] += 1
          end
        else
          @count[:met]  += 1
        end
      end
    end
  end

  def score
    if @count[:met] != 0
      return (@size * 7)
    else
      return (@size * 6)
    end
  end
end

class PwGenerator < PwBase
  attr_accessor :deck

  extend PwDecks

  def initialize(args = {})
    super(args) if defined?(super)
    
    if @options[:type] == "ascii"
      @deck = PwDecks.ascii
    else
      @deck = PwDecks.nonmeta
    end
  end

  def slice
    @deck[rand(@deck.size)]
  end

  def suspect_string
    new = ""
    options[:size].times { new += slice }
    new
  end

  def valid_string
    begin
      new = suspect_string
    end while not PwStrength.strong?(new)
    new
  end
end
