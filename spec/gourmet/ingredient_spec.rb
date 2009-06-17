# coding:utf-8
#--
# Gourmet, Copyright (c) 2008-2009 Bob Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

spec_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$:.unshift(spec_dir)
$:.uniq!

require "spec_helper"
require "gourmet/ingredient"

def read_fixture(fixture_path)
  spec_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
  full_path = File.join(spec_dir, "recipes", fixture_path)
  return File.open(full_path, "r") { |file| file.read }
end

describe Gourmet::Ingredient, "fully described" do
  before do
    @ingredient = Gourmet::Ingredient.parse("1 1/2 c butter, melted")
  end

  it "should have the correct quantity" do
    @ingredient.quantity.should == 1.5
  end

  it "should have the preferred unit" do
    @ingredient.unit.should == "cups"
  end

  it "should have the correct name" do
    @ingredient.name.should == "butter"
  end

  it "should have the correct preparation" do
    @ingredient.preparation.should == "melted"
  end
end

describe Gourmet::Ingredient, "with unicode quantity" do
  before do
    @ingredient = Gourmet::Ingredient.parse("1½ tbsp butter")
  end

  it "should have the correct quantity" do
    @ingredient.quantity.should == 1.5
  end

  it "should have the preferred unit" do
    @ingredient.unit.should == "tbsp"
  end

  it "should have the correct name" do
    @ingredient.name.should == "butter"
  end

  it "should have no preparation" do
    @ingredient.preparation.should == nil
  end
end

describe Gourmet::Ingredient, "with padding" do
  before do
    @ingredient = Gourmet::Ingredient.parse("   1½  tbsp  butter,  melted   ")
  end

  it "should have the correct quantity" do
    @ingredient.quantity.should == 1.5
  end

  it "should have the preferred unit" do
    @ingredient.unit.should == "tbsp"
  end

  it "should have the correct name" do
    @ingredient.name.should == "butter"
  end

  it "should have the correct preparation" do
    @ingredient.preparation.should == "melted"
  end
end

describe Gourmet::Ingredient, "with no whole number in fraction" do
  before do
    @ingredient = Gourmet::Ingredient.parse("½ tsp salt")
  end

  it "should have the correct quantity" do
    @ingredient.quantity.should == 0.5
  end

  it "should have the preferred unit" do
    @ingredient.unit.should == "tsp"
  end

  it "should have the correct name" do
    @ingredient.name.should == "salt"
  end

  it "should have no preparation" do
    @ingredient.preparation.should == nil
  end
end

describe Gourmet::Ingredient, "with no whole number in fraction" do
  before do
    @ingredient = Gourmet::Ingredient.parse("1/2 tsp salt")
  end

  it "should have the correct quantity" do
    @ingredient.quantity.should == 0.5
  end

  it "should have the preferred unit" do
    @ingredient.unit.should == "tsp"
  end

  it "should have the correct name" do
    @ingredient.name.should == "salt"
  end

  it "should have no preparation" do
    @ingredient.preparation.should == nil
  end
end

describe Gourmet::Ingredient, "with no unit" do
  before do
    @ingredient = Gourmet::Ingredient.parse("3 eggs")
  end

  it "should have the correct quantity" do
    @ingredient.quantity.should == 3
  end

  it "should have no unit" do
    @ingredient.unit.should == nil
  end

  it "should have the correct name" do
    @ingredient.name.should == "eggs"
  end

  it "should have no preparation" do
    @ingredient.preparation.should == nil
  end
end
