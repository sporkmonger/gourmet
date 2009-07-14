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

  it "should have the correct sections" do
    @recipe.sections.should == []
  end

  it "should convert to a hash correctly" do
    @recipe.to_h.should == {
      :title => "Ararat Home Kadayif",
      :tags => ["armenian", "dessert"],
      :servings => "24 servings",
      :source => "Reflections of an Armenian Kitchen",
      :ingredients => [
        {
          :quantity => 2,
          :unit => "lbs",
          :name => "Kadayif dough (Shredded Filo)"
        },
        {
          :quantity => 1.5,
          :unit => "cups",
          :name => "Butter",
          :preparation => "melted"
        },
        {
          :quantity => 1,
          :unit => "qt",
          :name => "Half and half cream"
        },
        {
          :quantity => 1,
          :unit => "qt",
          :name => "Heavy cream"
        },
        {
          :quantity => 0.75,
          :unit => "cup",
          :name => "Cornstarch"
        },
        {
          :quantity => 0.75,
          :unit => "cup",
          :name => "Milk"
        },
        {
          :quantity => 4,
          :unit => "cups",
          :name => "Sugar"
        },
        {
          :quantity => 3,
          :unit => "cups",
          :name => "Water"
        },
        {
          :name => "Few drop fresh Lemon Juice"
        }
      ],
      :steps => [
        "Cut and fluff 1 lb of Kadayif dough in bowl with hands.",
        "Add half melted butter and mix until strands are evenly coated.",
        "Spread evenly in lightly buttered 17x13-inch baking pan.",
        "Combine half and half and heavy cream in large saucepan. " +
        "Bring to slow boil over low heat.",
        "Combine cornstarch and milk, stirring until cornstarch is dissolved.",
        "Slowly add to cream mixture, stirring constantly, " +
        "until mixture returns to slow boil. Spread hot cream " +
        "filling over kadayif in pan.",
        "Cut and fluff remaining 1 lb. of kadayif in bowl. Add remaining " +
        "melted butter and mix with hands until strands are evenly coated. " +
        "Spread over top of cream layer, pressing down firmly to " +
        "form an even surface.",
        "Place on lowest oven rack and bake at 450°F. until golden brown, " +
        "about 20-25 minutes. If not golden, move pan to top rack and bake " +
        "5 to 10 minutes longer.",
        "Meanwhile, prepare syrup. Combine sugar and water in saucepan and " +
        "boil 5 to 10 minutes. Add lemon juice. Cool. Pour cold syrup " +
        "evenly over kadayif as soon as it is removed from the oven. " +
        "Cut into squares to serve."
      ]
    }
  end

  it "should strip email addresses if a source is set" do
    @recipe.directions.should_not include(
      "From the recipe file of suzy@gannett.infi.net"
    )
  end

  it "should have the correct steps" do
    @recipe.steps.should include(
      "Cut and fluff 1 lb of Kadayif dough in bowl with hands."
    )
    @recipe.steps.should include(
      "Add half melted butter and mix until strands are evenly coated."
    )
    @recipe.steps.should include(
      "Spread evenly in lightly buttered 17x13-inch baking pan."
    )
    @recipe.steps.should include(
      "Combine half and half and heavy cream in large saucepan. " +
      "Bring to slow boil over low heat."
    )
    @recipe.steps.should include(
      "Combine cornstarch and milk, stirring until cornstarch is dissolved."
    )
    @recipe.steps.should include(
      "Slowly add to cream mixture, stirring constantly, until mixture " +
      "returns to slow boil. Spread hot cream filling over kadayif in pan."
    )
    @recipe.steps.should include(
      "Cut and fluff remaining 1 lb. of kadayif in bowl. Add remaining " +
      "melted butter and mix with hands until strands are evenly coated. " +
      "Spread over top of cream layer, pressing down firmly to form an " +
      "even surface."
    )
    @recipe.steps.should include(
      "Place on lowest oven rack and bake at 450°F. until golden brown, " +
      "about 20-25 minutes. If not golden, move pan to top rack and bake " +
      "5 to 10 minutes longer."
    )
    @recipe.steps.should include(
      "Meanwhile, prepare syrup. Combine sugar and water in saucepan and " +
      "boil 5 to 10 minutes. Add lemon juice. Cool. Pour cold syrup evenly " +
      "over kadayif as soon as it is removed from the oven. Cut into " +
      "squares to serve."
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

Place on lowest oven rack and bake at 450°F. until golden brown,
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
      Gourmet::Ingredient.new(0.5, "tsp", "salt")
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

describe Gourmet::Recipe, "with fixture #3" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/3.txt"))
  end

  it "should not register as a recipe" do
    @recipe.should == nil
  end
end

describe Gourmet::Recipe, "with fixture #4" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/4.txt"))
  end

  it "should have the correct title" do
    @recipe.title.should == "\"Baloney\" Cheese Dogs"
  end

  it "should have the correct tags" do
    @recipe.tags.should include("cheese")
    @recipe.tags.should include("hot dogs")
  end

  it "should have the correct servings" do
    @recipe.servings.should == "2 Servings"
  end

  it "should have the correct source" do
    @recipe.source.should ==
      "BETTER HOMES AND GARDENS MAGAZINE -- SEPTEMBER 1996"
  end

  it "should have the correct ingredients" do
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, nil, "Hot dog buns")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "Mayonnaise or mustard")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, "slices", "Turkey bologna")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(
        2, nil, "Sticks cheddar cheese or string cheese sticks"
      )
    )
  end

  it "should have the correct directions" do
    @recipe.directions.should == <<-RECIPE
Spread inside of hot dog buns with mayonnaise or mustard. Roll 1 bologna
slice around each cheese stick. Place inside hot dog bun. Wrap each bun in
plastic wrap.
RECIPE
  end
end

describe Gourmet::Recipe, "with fixture #5" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/5.txt"))
  end

  it "should have the correct title" do
    @recipe.title.should == "Raised Donuts"
  end

  it "should have the correct tags" do
    @recipe.tags.should include("breads")
  end

  it "should have the correct servings" do
    @recipe.servings.should == "6 servings"
  end

  it "should have the correct source" do
    @recipe.source.should == "Florence Taft Eaton, Concord, MA."
  end

  it "should have the correct ingredients" do
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "cup", "Sugar")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "cup", "Milk", "scalded")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, "tbsp", "Melted butter or butter substitute")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.5, "tsp", "salt")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, nil, "Eggs", "well beaten")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, nil, "Eggs", "well beaten")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "Flour")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.5, nil, "Cake dry yeast")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "OR 1/2 cake compressed yeast")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.25, "cup", "Lukewarm water")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.25, "tsp", "Nutmeg")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "OR 1/4 tsp cinnamon")
    )
  end

  it "should have the correct directions" do
    @recipe.directions.should == <<-RECIPE
Scald milk, at night, and add butter and salt.  Cool until lukewarm. Add
yeast, softened in lukewarm water, and nutmeg or cinnamon. Cut in enough
flour to make of soft roll dough consistency. Cover and let rise overnight.

Next morning cut down, add sugar, eggs, and enough additional flour to form
a soft roll dough. Cover and let rise until double in bulk. Turn onto
lightly floured board, roll in sheet 1/3 inch thick, cut with lightly
floured cutter.  Cook in deep, hot fat (365°F).  Drain on crumpled,
absorbent paper.  The doughnuts should rise to the top and begin to brown
almost instantly.  48 doughnuts.
RECIPE
  end
end

describe Gourmet::Recipe, "with fixture #6" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/6.txt"))
  end

  it "should have the correct title" do
    @recipe.title.should == "Armenian Pumpkin Stew"
  end

  it "should have the correct tags" do
    @recipe.tags.should include("stews")
    @recipe.tags.should include("low fat")
  end

  it "should have the correct servings" do
    @recipe.servings.should == "4-6 servings"
  end

  it "should have the correct source" do
    @recipe.source.should == "NYTimes Magazine 11/15/92"
  end

  it "should have the correct ingredients" do
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.5, "tsp", "coriander seed")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.5, "tsp", "cardamom seed")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.5, "tsp", "ground cinnamon")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "tsp", "cumin seed")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, nil, "clove")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, "tbsp", "vegetable oil")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, "lbs", "lamb", "cubed")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "large", "onion", "peeled and minced")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(4, nil, "cloves garlic", "peeled and minced")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, nil, "carrots", "peeled and cut into")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, nil, "celery root", "peeled and cut into")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(
        4, "large", "red ripe tomatoes", "peeled cored and se"
      )
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, nil, "acorn squash", "peeled and cut into")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, nil, "acorn squash", "peeled and cut into")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, "qt", "chicken broth or beef broth")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "large", "pumpkin", "about 5 pounds")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "cup", "Basmati rice", "uncooked")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.5, "tsp", "salt")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "tsp", "black pepper", "freshly ground")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "tsp", "black pepper", "freshly ground")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.25, "cup", "coriander leaves", "minced")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(0.75, "cup", "parsley leaves", "minced")
    )
  end

  it "should have the correct directions" do
    @recipe.directions.should == <<-RECIPE
Combine coriander, cardamom, cinnamon, cumin and
clove in a spice mill or coffee grinder.  Grind until
smooth.  Set aside.  Head a tblsp of oil in large,
heavy-bottom saucepan.  Add the lamb in one layer.
Sprinkle with the spice mixture.  Seer over medium
heat until lightly browned, about 3-5 minutes.  Remove
the lamb from the pan and set aside.

Add the onion
and garlic to the pan.  Saute, stirring frequently,
until translucent, about 5 minutes.  Add the carrots,
celery root, tomatoes, and acorn squash. Add the
broth.  Return lamb to the pan. Partly cover and
gently simmer until the lamb is tender, about 1.5 to 2
hours.  Season with salt and pepper.

Meanwhile,
preheat the oven to 350°F.  Place the pumpkin on
a baking sheet.  Brush the outside with the remaining
oil. Bake until tender, about 45 to 60 minutes.  Cook
the rice according to package directions, set aside.

To assemble, place the pumpkin in a serving dish.
Fill with the lamb stew.  Divide the rice among 4
warmed bowls. Ladle the stew from the pumpkin over the
rice.  Garnish with coriander and parsley. Serve
immediately.
RECIPE
  end
end

describe Gourmet::Recipe, "with fixture #7" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/7.txt"))
  end

  it "should have the correct title" do
    @recipe.title.should == "ARNAVUT CIGERI (LAMB'S LIVER WITH RED PEPPERS"
  end

  it "should have the correct tags" do
    @recipe.tags.should include("middle east")
    @recipe.tags.should include("turkish")
    @recipe.tags.should include("side dish")
    @recipe.tags.should include("offal")
    @recipe.tags.should_not include("publication")
  end

  it "should have the correct servings" do
    @recipe.servings.should == "4 servings"
  end

  it "should have no source" do
    @recipe.source.should == nil
  end

  it "should have the correct ingredients" do
    @recipe.ingredients.should_not include(
      Gourmet::Ingredient.new(
        nil, nil, "sprinkle with 1 tablespoon of the salt, and turn them"
      )
    )
    @recipe.ingredients.should_not include(
      Gourmet::Ingredient.new(
        nil, nil, "sprinkle with 1 tablespoon of the salt", "and turn them"
      )
    )
  end

  it "should have the correct directions" do
    @recipe.directions.should == <<-RECIPE
Place the onion rings in a sieve or colander,
sprinkle with 1 tablespoon of the salt, and turn them
about with a spoon to coat them evenly. Let them rest
at room temperature for 30 minutes, then rinse under
warm running water and squeeze them gently but
completely dry. In a large bowl, toss the onions,
parsley and red pepper together until well mixed. Set
aside.

Drop the liver into a bowl, pour in the raki and
stir together for a few seconds.  Then pour off the
raki.  Toss the liver and flour together in another
bowl, place the liver in a sieve and shake through all
the excess flour.  In a heavy 10 to 12 inch skillet,
heat the oil over high heat until a light haze forms
above it.  Add the liver and stir it about in the hot
oil for 1 or 2 minutes, or until the cubes are lightly
browned. Stir in the remaining 1/4 teaspoon of salt
and a few grindings of pepper. With a slotted spoon,
transfer the liver to paper towels to drain.

Mound the liver in the center of a heated platter,
arrange the onion-ring mixture and red pepper strips
around it and serve at once.
RECIPE
  end
end

describe Gourmet::Recipe, "with fixture #8" do
  before do
    @recipe = Gourmet::Recipe.parse(read_fixture("mm/8.txt"))
  end

  it "should have the correct title" do
    @recipe.title.should == "TURKISH EGGPLANT SALAD"
  end

  it "should have the correct tags" do
    @recipe.tags.should include("salads")
    @recipe.tags.should include("appetizers")
    @recipe.tags.should include("vegetables")
  end

  it "should have the correct servings" do
    @recipe.servings.should == "4 servings"
  end

  it "should have the correct source" do
    @recipe.source.should ==
      "Ayla Esen Algar, \"The Complete Book of Turkish Cooking\""
  end

  it "should have the correct ingredients" do
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1, "large", "Eggplant")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "Juice of 1/2 lemon")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(nil, nil, "salt")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(1.0/3.0, "cup", "extra virgin olive oil")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2, "tsp", "Mashed garlic")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(2.5, "tbsp", "Vinegar")
    )
    @recipe.ingredients.should include(
      Gourmet::Ingredient.new(
        nil, nil, "Tomato slices, onion slices black Greek olives for garnish"
      )
    )
  end

  it "should have the correct directions" do
    @recipe.directions.should == <<-RECIPE
Cook unpeeled eggplant until it is charred on the
outside & the flesh is thoroughly soft.  Cool slightly
& then peel.  Wipe clean & squeeze out all the water.

Place eggplant in a bowl with the lemon juice & salt.

Mash well.  Add olive oil, garlic & vinegar, blend
thoroughly.  Serve on a plate garnished with tomato,
onion & olives.
RECIPE
  end
end
