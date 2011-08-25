require './lib/pw'

describe PwDecks do

  describe "#nonmeta" do
    
    it "should return an alphanumeric character array" do
      dropbox = PwDecks.nonmeta
      dropbox.should include "0" && "5" && "9"
      dropbox.should include "a" && "m" && "z"
      dropbox.should include "A" && "M" && "Z"
    end

    it "should not return meta characters" do
      PwDecks.nonmeta.should_not include "#" && "&" && ")"
    end
  end

  describe "#ascii" do

    it "should return a mixed with metacharacter array" do
      dropbox = PwDecks.ascii
      dropbox.should include "0" && "5" && "9"
      dropbox.should include "a" && "m" && "z"
      dropbox.should include "A" && "M" && "Z"
      dropbox.should include "#" && "&" && ")"
    end

    it "should not return ineligable or escape characters" do
      PwDecks.ascii.should_not include "\\" && " " && "\""
    end
  end

  describe "#assign" do
    it "should return a 2 part array" do
      PwDecks.assign.size.should == 2
    end
  end
end

describe PwStrength do

  it "should validate good passwords" do
    PwStrength.strong?("aA1bB2cC3").should be_true
    PwStrength.strong?("aA1!bB2@cC3#dD4$eE5%fF6^").should be_true
  end

  it "should reject bad passwords" do
    PwStrength.strong?("").should be_false
    PwStrength.strong?("abcdef123").should be_false
  end

  describe "#entropy" do
    it "should correctly score entry" do
      PwStrength.entropy("aA1bB2cC3").should == 54
      PwStrength.entropy("aA1!bB2@cC3#dD4$eE5%fF6^").should == 168
    end
  end
end

describe PwBase do
  
  describe "#generate" do
    it "should naturally generate 10 character semi-random strings" do
      #output = PwGenerator.generate(:type => "other")
      # jess'
      output = PwGenerator.generate()
      output.size.should == 10
      PwStrength.strong?(output).should be_true
    end
  end
end

describe PwGenerator do
  before(:all) do
    #temp = PwBase.new
    #temp.options[:type] = "monkeys"
    #@mew = PwGenerator.new(:from => temp)
    @mew = PwGenerator.new()
  end

  it "should properly intergrate with PwDecks" do
    @mew.deck.sort.should == PwDecks.ascii.sort
    #@mew.deck.sort.should == PwDecks.nonmeta.sort
  end

  describe "#slice" do
    it "should generate a random character" do
      a = []
      5.times do |i|
        a[i] = @mew.slice
      end
      
      PwDecks.ascii.should include a[0] && a[1] && a[2] && a[3] && a[4]
      #PwDecks.nonmeta.should include a[0] && a[1] && a[2] && a[3] && a[4]      

      a.uniq.size.should >= 2
    end
  end

  describe "#suspect_string" do
    it "should generate an untested string" do
      a = @mew.suspect_string
      a.should be_kind_of String
      a.size.should == 10
    end
  end

  describe "#valid_string" do
    it "should produce a string that is also valid" do
      PwStrength.strong?(@mew.valid_string).should be_true 
    end
  end
end
