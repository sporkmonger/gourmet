# coding:utf-8
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

module Gourmet
  class Ingredient
    module Parsing
      UNIT_SORT = lambda do |a, b|
        if (b.size <=> a.size) != 0
          # Sort first by size
          b.size <=> a.size
        elsif a.downcase != a
          # Then by case
          -1
        elsif b.downcase != b
          1
        else
          # Then by letter
          a <=> b
        end
      end
      UNITS = {
        ["cup", "cups"] => [
          "cups", "cup", "C"
        ],
        ["tbsp", "tbsp"] => [
          "tablespoons", "tablespoon", "tbsps", "tbsp", "tbs", "tb", "T"
        ],
        ["tsp", "tsp"] => [
          "teaspoon", "teaspoons", "tspn", "tsps", "tsp", "ts", "t"
        ],
        ["lb", "lbs"] => [
          "pounds", "pounds", "lbs", "lb"
        ],
        ["qt", "qt"] => [
          "quarts", "quart", "qts", "qt", "q"
        ],
        ["pt", "pt"] => [
          "pints", "pint", "pts", "pt", "p"
        ],
        ["slice", "slices"] => [
          "slices", "slice", "slcs", "slc", "sl"
        ],
        ["small", "small"] => [
          "small", "sm"
        ],
        ["large", "large"] => [
          "large", "lg"
        ]
      }
      ALL_UNITS = UNITS.values.flatten.uniq.sort(&UNIT_SORT)
      VULGAR_CHARS = {
        "¼" => (1.0/4.0),
        "½" => (1.0/2.0),
        "¾" => (3.0/4.0),
        "⅓" => (1.0/3.0),
        "⅔" => (2.0/3.0),
        "⅕" => (1.0/5.0),
        "⅖" => (2.0/5.0),
        "⅗" => (3.0/5.0),
        "⅘" => (4.0/5.0),
        "⅙" => (1.0/6.0),
        "⅚" => (5.0/6.0),
        "⅛" => (1.0/8.0),
        "⅜" => (3.0/8.0),
        "⅝" => (5.0/8.0),
        "⅞" => (7.0/8.0)
      }
      QUANTITY = Regexp.new(
        "^(([0-9]+ *)?(#{VULGAR_CHARS.keys.join('|')})|" +
        "([0-9]+ +)?[0-9]+/[0-9]+|[0-9]+\\.[0-9]+|[0-9]+)\\b"
      )
      PREPARATION = /(,|;|--) *([^,;-]+)/

      def self.vulgar_to_float(vulgar)
        case vulgar
        when nil, ""
          return nil
        when /^\d+$/
          return vulgar.to_i
        when /^(\d+) (\d+)\/(\d+)$/
          whole, numerator, denominator =
            vulgar.scan(/^(\d+) (\d+)\/(\d+)$/)[0]
          return whole.to_f + (numerator.to_f / denominator.to_f)
        when Regexp.new("^(\\d+) ?(#{VULGAR_CHARS.keys.join('|')})$")
          whole, fraction = vulgar.scan(
            Regexp.new("^(\\d+) ?(#{VULGAR_CHARS.keys.join('|')})$"))[0]
          for key, value in VULGAR_CHARS
            return whole.to_f + value if fraction == key
          end
          raise ArgumentError, "Invalid quantity: #{vulgar.inspect}"
        when /^(\d+)\/(\d+)$/
          numerator, denominator =
            vulgar.scan(/^(\d+)\/(\d+)$/)[0]
          return (numerator.to_f / denominator.to_f)
        when Regexp.new("^(#{VULGAR_CHARS.keys.join('|')})$")
          fraction =
            vulgar[Regexp.new("^(#{VULGAR_CHARS.keys.join('|')})$"), 1]
          for key, value in VULGAR_CHARS
            return value if fraction == key
          end
          raise ArgumentError, "Invalid quantity: #{vulgar.inspect}"
        else
          raise ArgumentError, "Invalid quantity: #{vulgar.inspect}"
        end
      end
    end

    attr_accessor :quantity
    attr_accessor :unit
    attr_accessor :name
    attr_accessor :preparation
    attr_accessor :section

    def self.parse(obj)
      remainder = Utility.convert(obj, String).dup.strip

      # Strip weird characters
      remainder.gsub!(/-\303\277\303\277/, " ")

      ingredient = Ingredient.new
      ingredient.quantity = Parsing.vulgar_to_float(
        remainder[Parsing::QUANTITY, 0]
      )
      remainder.gsub!(Parsing::QUANTITY, "")
      ingredient.preparation = remainder[Parsing::PREPARATION, 2]
      ingredient.preparation.strip! if ingredient.preparation
      remainder.gsub!(Parsing::PREPARATION, "")
      remainder.strip!
      unit_search = lambda do |case_sensitive|
        for unit_names, unit_strings in Parsing::UNITS
          break if ingredient.unit != nil
          for unit in unit_strings
            unit_regexp = case_sensitive ?
              Regexp.new("^#{Regexp.escape(unit)}\\b") :
              Regexp.new("^#{Regexp.escape(unit.downcase)}\\b")
            index = case_sensitive ?
              remainder =~ unit_regexp : remainder.downcase =~ unit_regexp
            if index == 0
              if ingredient.quantity == nil || ingredient.quantity <= 1.0
                ingredient.unit = unit_names.first
              else
                ingredient.unit = unit_names.last
              end
              remainder[0...unit.size] = ""
              break
            end
          end
        end
      end
      unit_search.call(true)
      unit_search.call(false)
      ingredient.name = remainder.strip
      if ingredient.preparation && ingredient.preparation =~ /^or/i
        ingredient.name << (" " + ingredient.preparation)
        ingredient.preparation = nil
      end
      ingredient.normalize!
      return ingredient
    end

    def initialize(
        quantity=nil, unit=nil, name=nil, preparation=nil, section=nil)
      self.quantity = quantity
      self.unit = unit
      self.name = name
      self.preparation = preparation
      self.section = section
    end

    def ==(other)
      return false if !other.kind_of?(Gourmet::Ingredient)
      return (self.quantity == other.quantity &&
        self.unit == other.unit &&
        self.name == other.name &&
        self.preparation == other.preparation &&
        self.section == other.section)
    end

    def to_a
      return [
        self.quantity, self.unit, self.name, self.preparation, self.section
      ]
    end

    def to_str
      buffer = ""
      buffer << self.quantity.to_s if self.quantity
      if self.unit
        buffer << " " if !buffer.empty?
        buffer << self.unit
      end
      if self.name
        buffer << " " if !buffer.empty?
        buffer << self.name
      end
      if self.preparation
        buffer << ", " if !buffer.empty?
        buffer << self.preparation
      end
      buffer
    end
    alias_method :to_s, :to_str

    def inspect
      self.to_str.inspect
    end

    def singular?
      return self.quantity && self.quantity <= 1.0
    end

    def plural?
      return !singular?
    end

    def normalize!
      if self.name =~ /freshly ground black pepper/i &&
          self.preparation == nil
        self.name = "black pepper"
        self.preparation = "freshly ground"
      end
      downcased_ingredients = [
        /black pepper/i,
        /salt/i,
        /(red|yellow|green) peppers?/i,
        /parsley/i,
        /onion/i,
        /olive oil/i
      ]
      if self.name &&
          downcased_ingredients.any? { |regexp| self.name =~ regexp }
        self.name.downcase!
      end
      if self.plural? && self.name == "onion"
        self.name = "onions"
      end
      self
    end
  end
end
