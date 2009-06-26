# ++
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
# --

require "gourmet"
require "gourmet/utility/type_check"
require "gourmet/ingredient"
require "nokogiri"

module Gourmet
  class Recipe
    module MealMaster
      SEPARATOR = /\-\-\-\-\-|MMMMM/
      HEADER = /^#{SEPARATOR}[\S ]*Meal-Master[\S ]*$/
      TITLE = /^ *Title: ([\S ]*)$/
      CATEGORIES = /^ *Categories: ([\S ]*)$/
      SERVINGS = /^ *(Yield|Servings): ([\S ]*)$/
      SOURCE = /^ *Source: ([\S ]*)$/
      SECTION = /^#{SEPARATOR}([\S ]*)$/
      AMOUNT = /[\d\.\/ ]{7}/
      UNIT = /[a-zTCGL ]{2}/
      INGREDIENT_ONE = /^((#{AMOUNT}) (#{UNIT}) ([\S ]{1,30}))$/
      INGREDIENT_TWO = Regexp.new(
        "^((#{AMOUNT}) (#{UNIT}) ([\\S ]{28,30})) " +
        "((#{AMOUNT}) (#{UNIT}) ([\\S ]{1,30}))$"
      )
      FOOTER = /^#{SEPARATOR}$/
    end

    attr_accessor :title
    attr_accessor :tags
    attr_accessor :servings
    attr_accessor :source
    attr_accessor :ingredients
    attr_accessor :directions

    def self.parse(obj)
      return self.send("parse_#{Gourmet.parse_type(obj)}", obj)
    end

    def self.parse_meal_master(obj)
      obj = Utility.convert(obj, String)
      obj = obj.gsub(/\r+\n?/, "\n")
      if (obj =~ MealMaster::HEADER)
        raw_header = obj[MealMaster::HEADER, 0]
        # Discard anything before the header
        obj[0...(obj =~ MealMaster::HEADER)] = ""
      end
      if (obj =~ MealMaster::TITLE)
        obj[0..(obj =~ MealMaster::TITLE)] = ""
      end
      if (obj =~ MealMaster::FOOTER)
        # Discard anything after the footer
        obj[(obj =~ MealMaster::FOOTER)..-1] = ""
      elsif defined?(raw_header) && raw_header
        footer_regexp = Regexp.new(Regexp.escape("-" * raw_header.size))
        obj[(obj =~ footer_regexp)..-1] = "" if obj =~ footer_regexp
      end

      recipe = Gourmet::Recipe.new

      recipe.title = obj[MealMaster::TITLE, 1].to_s.strip
      raw_categories = obj[MealMaster::CATEGORIES, 1]
      recipe.tags = (!!(raw_categories =~ /,/) ?
        raw_categories.split(",") :
        raw_categories.split(" ")
      ).map do |c|
        c.to_s.strip.downcase
      end
      recipe.servings = obj[MealMaster::SERVINGS, 2].to_s.strip
      recipe.source = obj[MealMaster::SOURCE, 1].to_s.strip
      # Discard the metadata
      obj.gsub!(MealMaster::SOURCE, "")
      obj[0...(obj =~ MealMaster::SERVINGS)] = ""
      obj[0..(obj =~ /\n/)] = ""

      lines = obj.scan(/^.*$/)
      current_section = nil
      recipe.ingredients = []
      directions_body = ""
      while !lines.empty?
        line = lines.shift
        next if line == nil

        if line.strip =~ /^(Mr\.|Mrs\.)/ && line.size < 35 &&
            recipe.source.to_s == ""
          recipe.source = line.strip
        elsif line =~ MealMaster::SECTION
          raw_section = obj[MealMaster::SECTION, 1]
          puts "Section: " + raw_section.inspect
        elsif line =~ MealMaster::INGREDIENT_ONE
          _, amount, unit, ingredient =
            line.scan(MealMaster::INGREDIENT_ONE)[0]
          recipe.ingredients << Gourmet::Ingredient.parse([
            amount.strip, unit.strip, ingredient.strip
          ].join(" "))
        elsif line =~ MealMaster::INGREDIENT_TWO
          _, amount_one, unit_one, ingredient_one,
          _, amount_two, unit_two, ingredient_two =
            line.scan(MealMaster::INGREDIENT_TWO)[0]
          recipe.ingredients << Gourmet::Ingredient.parse([
            amount_one.strip, unit_one.strip, ingredient_one.strip
          ].join(" "))
          recipe.ingredients << Gourmet::Ingredient.parse([
            amount_two.strip, unit_two.strip, ingredient_two.strip
          ].join(" "))
        else
          directions_body << (line.strip + "\n")
        end
      end
      recipe.directions = directions_body.strip + "\n"
      recipe.normalize!
      return recipe
    end

    def normalize!
      self.tags ||= []
      self.tags.reject! do |tag|
        tag == "posted-mm" ||
        tag == "posted-mc"
      end
      self.source = nil if self.source == ""
      if self.source == nil
        self.source =
          self.directions[/^From the recipe file of (.*)$/i, 1]
      end
      if self.source == nil
        self.source = self.directions[/^Recipe By:(.*)$/i, 1]
      end
      self.source = self.source.strip if self.source != nil
      self.directions.gsub!(/^From the recipe file of .*$/i, "")
      self.directions.gsub!(/^Recipe By:.*$/i, "")

      # Remove excess cruft
      self.directions.gsub!(/^From:.*$/i, "")
      self.directions.gsub!(/^Date:.*$/i, "")
      self.directions.gsub!(/^MC-RECIPE@MASTERCOOK.COM$/i, "")
      self.directions.gsub!(/^MASTERCOOK RECIPES LIST SERVER$/i, "")
      self.directions.gsub!(/^MC-RECIPE DIGEST .*$/i, "")
      self.directions.gsub!(/^From the MasterCook recipe list\..*$/i, "")
      self.directions.gsub!(
        /^.*Downloaded from Glen's MM Recipe Archive.*$/i, "")
      self.directions.gsub!(
        /^.*http:\/\/www.erols.com\/hosey.*$/i, "")
      self.directions = self.directions.strip + "\n"
      return self
    end
  end
end
