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


describe Gourmet::Recipe, "with fixture #2" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/2.txt"))
  end

  it "should have the correct title" do
    @recipe.title.should == "\"21\" Club Rice Pudding"
  end

  it "should have the correct tags" do
    @recipe.tags.should include("dessert")
  end

  it "should have the correct servings" do
    @recipe.servings.should == "10 Servings"
  end

  it "should have the correct source" do
    @recipe.source.should == "Aunt Salli's"
  end

  it "should have the correct ingredients" do
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "qt", "Milk")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "pt", "Heavy cream")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.5, "tsp", "Salt")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, nil, "Vanilla bean")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.75, "cup", "Long-grained rice")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "cup", "Granulated sugar")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, nil, "Egg yolk")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1.5, "cups", "Whipped cream")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "Raisins (optional)")
    )
  end

  it "should strip from headers" do
    @recipe.directions.should_not include(
      "From: Bobb1744@aol.com"
    )
  end

  it "should strip date headers" do
    @recipe.directions.should_not include(
      "Date: Tue, 23 Apr 1996 13:28:27 -0400"
    )
  end

  it "should strip mailing list information" do
    @recipe.directions.should_not include(
      "MC-RECIPE@MASTERCOOK.COM"
    )
  end

  it "should have the correct directions" do
    @recipe.directions.should == <<-RECIPE
In a heavy saucepan, combine the milk, cream, salt, vanilla bean and 3/4
cup of the sugar and bring to a boil. Stirring well, add the rice. Allow
the mixture to simmer gently, covered, for 1 3/4 hours over a very low
flame, until rice is soft. Remove from the heat and cool slightly. Remove
the vanilla bean. Blending well, stir in the remaining 1/4 cup of sugar and
the egg yolk. Allow to cool a bit more. Preheat the broiler. Stir in all
but 2 tablespoons of the whipped cream; pour the mixture into individual
crocks or a souffle dish. (Raisins my be placed in the bottom of the
dishes, if desired.) After spreading the remaining whipped cream in a thin
layer over the top, place the crocks or dish under the broiler until the
pudding is lightly browned. Chill before serving.
RECIPE
  end
end
