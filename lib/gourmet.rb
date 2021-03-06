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

require "gourmet/version"

module Gourmet
  def self.parse_type(obj)
    begin
      case obj
      when /\-+.*Recipe (via|Extracted from) Meal-Master/
        return :meal_master
      when /\*?.*Exported from +MasterCook.*\*?/
        return :master_cook
      when Nokogiri::XML::Document
        return :xml
      when Nokogiri::HTML::Document
        return :html
      else
        return :text if obj.gsub(/\bC\b/, "cup").gsub(/\bT\b/, "tbsp").scan(
          /[\d\/ ]+ (cup|oz|lb|tsp|teaspoon|tbsp|tablespoon|gram)/i
        ).size >= 3
        return nil
      end
    rescue TypeError, ArgumentError
      return nil
    end
  end
end
