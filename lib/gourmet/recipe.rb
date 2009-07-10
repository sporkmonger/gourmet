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
      ALL_UNITS = Regexp.new(
        "(#{Gourmet::Ingredient::Parsing::ALL_UNITS.join("|")})"
      )
      SEPARATOR = /\-\-\-\-\-|MMMMM/
      HEADER = /^#{SEPARATOR}[\S ]*Meal-Master[\S ]*$/
      TITLE = /^ *Title: ([\S ]*)$/
      CATEGORIES = /^ *Categories: ([\S ]*)$/
      SERVINGS = /^ *(Yield|Servings): ([\S ]*)$/
      SOURCE = /^ *Source: ([\S ]*)$/
      SECTION = /^#{SEPARATOR}([\S ]*)$/
      AMOUNT = /[\d\.\/ ]{7,9}/
      UNIT = /[a-zTBCGL ]{2}/
      INGREDIENT_ONE = /^((#{AMOUNT}) (#{UNIT}) ([^\n]+))$/
      INGREDIENT_TWO = Regexp.new(
        "^((#{AMOUNT}) (#{UNIT}) ([\\S ]{28,30})) " +
        "((#{AMOUNT}) (#{UNIT}) ([\\S ]{1,30}))$"
      )
      DROPPED_INGREDIENT =
        /^([a-zA-z ]*((\d[\d\.\/ ]*) (#{ALL_UNITS}) ([\S ]{1,30})))$/
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
      index = lines.size
      while index > 0
        index -= 1
        line = lines[index]
        if line.strip =~ /^[:;]/
          previous_line = lines[index - 1]
          previous_line.chomp!(" ")
          previous_line << (" " + line.strip.gsub(/^[:;]/, "").strip)
          line.gsub!(/.*/, "")
        end
      end
      body_started = false
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
        elsif line =~ MealMaster::INGREDIENT_TWO
          _, amount_one, unit_one, ingredient_one,
          _, amount_two, unit_two, ingredient_two =
            line.scan(MealMaster::INGREDIENT_TWO)[0]
          if amount_one.strip == "" && unit_one.strip == "" &&
              ingredient_one =~ /^[-:;]+/
            recipe.ingredients[-2] = Gourmet::Ingredient.append(
              recipe.ingredients[-2], ingredient_one.gsub(/^[-:;]+/, " ")
            )
          else
            recipe.ingredients << Gourmet::Ingredient.parse([
              amount_one.strip, unit_one.strip, ingredient_one.strip
            ].join(" "))
          end
          if amount_two.strip == "" && unit_two.strip == "" &&
              ingredient_two =~ /^[-:;]+/
            recipe.ingredients[-1] = Gourmet::Ingredient.append(
              recipe.ingredients[-1], ingredient_two.gsub(/^[-:;]+/, " ")
            )
          else
            recipe.ingredients << Gourmet::Ingredient.parse([
              amount_two.strip, unit_two.strip, ingredient_two.strip
            ].join(" "))
          end
        elsif line =~ MealMaster::INGREDIENT_ONE
          _, amount, unit, ingredient =
            line.scan(MealMaster::INGREDIENT_ONE)[0]
          if amount.strip == "" && unit.strip == "" && ingredient =~ /^[-:;]+/
            recipe.ingredients[-1] = Gourmet::Ingredient.append(
              recipe.ingredients[-1], ingredient.gsub(/^[-:;]+/, " ")
            )
          else
            recipe.ingredients << Gourmet::Ingredient.parse([
              amount.strip, unit.strip, ingredient.strip
            ].join(" "))
          end
        elsif body_started == false && line =~ MealMaster::DROPPED_INGREDIENT
          recipe.ingredients << Gourmet::Ingredient.parse(
            line.scan(MealMaster::DROPPED_INGREDIENT).first.first
          )
        elsif line.strip.size > 0
          body_started = true
          directions_body << (line.strip + "\n")
        end
      end
      recipe.directions = directions_body.strip + "\n"
      recipe.normalize!
      # It's not a real recipe if there are no ingredients
      return nil if recipe.ingredients.empty?
      return recipe
    end

    def normalize!
      self.tags ||= []
      self.tags.reject! do |tag|
        tag == "posted-mm" ||
        tag == "posted-mc" ||
        tag == "publication"
      end
      self.source = nil if self.source == ""
      self.ingredients.each do |ingredient|
        ingredient.name.strip!
        ingredient.name.gsub!(/ +/, " ")
      end

      # Preprocess messed up directions
      self.directions.gsub!(/^(.+) Posted to(.*)$/i, "\\1\nPosted to\\2")

      # Normalize cooking temperatures
      self.directions.gsub!(/\b(\d+)\s*(F|C)\b/, "\\1°\\2")
      self.directions.gsub!(/\b(\d+)\s*ø\s*f\b/i, "\\1°F")
      self.directions.gsub!(/\b(\d+)\s*ø\s*c\b/i, "\\1°C")
      self.directions.gsub!(/\b(\d+)\s*o\s+(F|C)\b/, "\\1°\\2")
      self.directions.gsub!(/\b(\d+)\s*degrees\s+f\b/i, "\\1°F")
      self.directions.gsub!(/\b(\d+)\s*degrees\s+c\b/i, "\\1°C")
      self.directions.gsub!(/\b(\d+)\s*degrees\b/i, "\\1°F")

      # Normalize lists
      if self.directions.scan(/\b(\d+[\.\)\-])\b/).size > 2
        self.directions.gsub!(/[\n\s]+(\d+[\.\)\-])[ \t]+/, "\n\n")
        self.directions.gsub!(/^(\d+[\.\)\-])[ \t]+/, "\n\n")
      else
        self.directions.gsub!(/\.\s*\n\s*/, ".\n\n")
      end

      # Normalize source
      if self.source == nil
        self.source =
          self.directions[/^From the recipe file of (.*)$/i, 1]
      end
      if self.source == nil
        self.source = self.directions[/^Recipe By\s*:(.*)$/i, 1]
      end
      self.directions.gsub!(/^From the recipe file of .*$/i, "")
      self.directions.gsub!(/^Recipe By\s*:.*$/i, "")

      # Normalize yield
      if self.servings == nil || self.servings == "1 servings"
        if self.directions =~ /Yield\s*:[^\.]+\./
          self.servings = self.directions[/Yield\s*:([^\.]+)\./, 1].strip
        end
      end
      self.directions.gsub!(/Yield\s*:[^\.]+\./, "")

      # Remove excess cruft
      self.directions.gsub!(/^Posted to(.|\n)+/, "")
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
      if self.source == nil && self.directions =~ /Florence Taft Eaton/
        self.source = self.directions[/(Florence Taft Eaton.*)$/i, 1]
        self.directions.gsub!(/Florence Taft Eaton.*$/i, "")
      elsif self.source == nil &&
          self.directions =~ /^[a-zA-Z\. ]+,\s*[\'\"][\w ]+[\'\"]$/
        self.source =
          self.directions[/^([a-zA-Z\. ]+,\s*[\'\"][\w ]+[\'\"])$/, 1]
        self.directions.gsub!(/^[a-zA-Z\. ]+,\s*[\'\"][\w ]+[\'\"]$/, "")
      end
      self.source = self.source.strip if self.source != nil
      self.directions = self.directions.strip + "\n"
      return self
    end
  end
end
