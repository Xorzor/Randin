#!/usr/bin/ruby

# frontend file

if __FILE__ == $0
  require 'optparse'
  require './lib/pw.rb'

  @this = {}

  optparse = OptionParser.new do |opts|
    opts.on('-s', '--size INTEGER', "Output size") do |a|
      @this[:size] = a.to_i
    end
    opts.on('-t', '--type STRING', "Character Set") do |a|
      if a == "alphanumeric" || a == "alpha"
        @this[:type] = "___"
      else 
        @this[:type] = "ascii"
      end
    end
    opts.on('-v', '--volume INTEGER', "Amount of independant loops") do |a|
      @loop = a.to_i
    end
    opts.on('--table', "Display working characters") do
      puts "Dirty deck :: #{PwDecks.ascii.size} :: #{PwDecks.ascii}"
      puts "Clean deck :: #{PwDecks.nonmeta.size} :: #{PwDecks.nonmeta}"
      exit
    end 
    opts.on('-h', '--help', "Your reading it") do
      puts opts
      exit
    end 
  end
  optparse.parse!
  
  # allow optionless size passed in
  if @this[:size].nil? && ARGV[0] =~ /^[0-9]+$/ #.kind_of?(Integer)
    @this[:size] = ARGV[0].to_i
  end

  @loop ||= 1
  @loop.times do 
    puts PwGenerator.generate @this
    #puts PwGenerator.generate @this.merge({:type => "other"})
  end
end
