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
require "gourmet/recipe"

def read_fixture(fixture_path)
  spec_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
  full_path = File.join(spec_dir, "recipes", fixture_path)
  return File.open(full_path, "r") { |file| file.read }
end

describe Gourmet::Recipe, "with fixture #1" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/1.txt"))
  end

  it "should have the correct title" do
    @recipe.title.should == "Ararat Home Kadayif"
  end

  it "should have the correct tags" do
    @recipe.tags.should include("armenian")
    @recipe.tags.should include("dessert")
    @recipe.tags.should_not include("posted-mm")
  end

  it "should have the correct servings" do
    @recipe.servings.should == "24 servings"
  end

  it "should have the correct source" do
    @recipe.source.should == "Reflections of an Armenian Kitchen"
  end

  it "should have the correct ingredients" do
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, "lbs", "Kadayif dough (Shredded Filo)")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1.5, "cups", "Butter", "melted")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "qt", "Half and half cream")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "qt", "Heavy cream")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.75, "cup", "Cornstarch")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.75, "cup", "Milk")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(4, "cups", "Sugar")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "Few drop fresh Lemon Juice")
    )
  end

  it "should strip email addresses if a source is set" do
    @recipe.directions.should_not include(
      "From the recipe file of suzy@gannett.infi.net"
    )
  end

  it "should have the correct directions" do
    @recipe.directions.should == <<-RECIPE
Cut and fluff 1 lb of Kadayif dough in bowl with hands.
Add half melted butter and mix until strands are evenly coated.
Spread evenly in lightly buttered 17x13-inch baking pan.

Combine half and half and heavy cream in large saucepan. Bring to slow
boil over low heat.

Combine cornstarch and milk, stirring until cornstarch is dissolved.
Slowly add to cream mixture, stirring constantly, until mixture returns
to slow boil. Spread hot cream filling over kadayif in pan.

Cut and fluff remaining 1 lb. of kadayif in bowl. Add remaining melted
butter and mix with hands until strands are evenly coated. Spread over
top of cream layer, pressing down firmly to form an even surface.
Place on lowest oven rack and bake at 450 degrees F. until golden brown,
about 20-25 minutes. If not golden, move pan to top rack and bake 5 to
10 minutes longer.

Meanwhile, prepare syrup. Combine sugar and water in saucepan and boil
5 to 10 minutes. Add lemon juice. Cool. Pour cold syrup evenly over
kadayif as soon as it is removed from the oven. Cut into squares to
serve.
RECIPE
  end
end
