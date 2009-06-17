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

module Gourmet
  module Utility
    def self.convert(obj, type)
      message = nil
      if type == String
        message = :to_str
      elsif type == Integer
        message = :to_int
      elsif type == Array
        message = :to_ary
      elsif type == Hash
        message = :to_hash
      end
      if message == nil
        raise ArgumentError, "Unconvertable type: #{type}."
      end
      if obj.respond_to?(message)
        return obj.send(message)
      else
        raise TypeError,
          "Could not convert #{obj.class} into #{type}."
      end
    end

    def self.respond_check(obj, *messages)
      for message in messages
        if !obj.respond_to?(message.to_sym)
          raise TypeError,
            "Expected #{obj.inspect} to respond to :#{message}."
        end
      end
      return true
    end

    def self.type_check(obj, *types)
      for type in types
        return true if obj.kind_of?(type)
      end
      if types.size == 1
        raise TypeError, "Expected #{types[0]}, got #{obj.class}."
      else
        raise TypeError,
          "Expected one of: #{types.join(",")}.  Got #{obj.class}."
      end
    end
  end
end
