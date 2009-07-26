# -*- coding: UTF-8 -*-
# Encoding pramga is not available until Ruby 2.0.
#

require 'forwardable'
require 'iconv'

module Unicode

  # Common class.
  class Unicode
    protected
    def iconv(string)
      @iconv ||= Iconv.new(@encoding, 'UTF-8')
      @iconv.iconv(string)
    end
  end

  # Unicode character
  #
  class Character < Unicode

    extend Forwardable
    def_delegators :@codepoint, :succ, :==

    def initialize(codepoint, encoding=$KCODE)
      @codepoint = codepoint
      @encoding  = encoding
    end
    def to_a
      [to_i]
    end
    def to_i
      @codepoint
    end
    def to_s
      iconv([to_i].pack('U'))
    end
    def to_u
      String.new(to_s, @encoding)
    end
    def inspect
      '<U+%X>' % to_i
    end
  end

  module Enumerable
    def each
      raise "Block is not given!" unless block_given? 
      to_a.each { |c| yield Character.new(c, encoding) }
    end
    alias each_char each
  end

  # Unicode string class.
  #
  # TODO:
  # 1. Currently, all RegExp related methods (gsub, scan, match etc..)
  #    can't pass test.
  # 2. Should be compatible with oniguruma bundled with 1.9 CVS HEAD.
  #    (testing required.)
  #
  class String < Unicode

    include Enumerable

    extend Forwardable
    def_delegators :@ucsary, :empty?, :hash, :size, :length

    attr_reader :encoding

    def initialize(string=nil, encoding=$KCODE)
      self.encoding=(encoding)
      @ucsary = iconv(string).unpack('U*') rescue []
    end
    def encoding=(encoding)
      raise if encoding.nil? or encoding == 'NONE'
      @encoding = encoding
      @iconv = Iconv.new('UTF-8', @encoding)
    end

    def split(pattern=$;, limit=0)
      case pattern
      when String
        to_s.split(pattern.to_s, limit)
      when RegExp
        to_s.split(/#{pattern.to_s}/, limit)
      end.map { |e| e.to_u }
    end

    def index(needle, offset=0)
      case needle
      when (Character or Fixnum)
        to_a.index(needle.to_i, offset)
      when String
        to_a[offset..-1].each_with_index do |e, i|
          if e == needle.to_a.first
            return i if to_a[offset+i, needle.size] == needle.to_a
          end
        end
        nil
      when RegExp
      else
        raise ArgumentError
      end
    end
    def rindex(needle, offset=nil)
      raise NotImplementedError
    end
    def ljust(count, padstr)
      self.class.from_array((padstr.to_a * count) + to_a, encoding)
    end
    def rjust(count, padstr)
      self.class.from_array(to_a + (padstr.to_a * count), encoding)
    end
    def strip
      filter = to_a.reject { |e| [?\t, ?\s, ?\n, ?\r, ?\f, ?\v].include? e }
      self.class.from_array(filter, encoding)
    end
    def strip!
      to_a.reject! { |e| [?\t, ?\s, ?\n, ?\r, ?\f, ?\v].include? e }
      nil
    end
    def reverse
      self.class.from_array(to_a.reverse, encoding)
    end

    #--
    # Basic override methods:
    #
    def to_a
      @ucsary
    end
    def to_s(encoding=nil)
      self.encoding=(encoding) if encoding and encoding != 'NONE'
      iconv(to_a.pack('U*'))
    end
    def inspect
      to_a.map{ |e| Character.new(e, encoding).inspect }.join
    end
    def eql?(other)
      self.class == other.class and to_a == other.to_a
    end
    def ==(other)
      to_a == other.to_a
    end
    def [](slice)
      a = to_a[slice]
      a = [a] unless a.is_a? Array
      iconv(a.pack('U*'))
    end
    def []=(slice, other)
      quack_invalid! other
      case slice
      when Range then to_a[slice] = other.to_a
      when Fixnum
        to_a[slice..-1] = other.to_a + to_a[slice+1..-1]
      when RegExp
        raise NotImplementedError
      else # [a, b]
        raise NotImplementedError
      end
    end
    def <<(other)
      quack_invalid! other
      to_a[length..-1] = other.to_a
      self
    end
    def +(other)
      quack_invalid! other
      raise "Encoding mismatch!" if encoding != other.encoding
      self.class.from_array(to_a + other.to_a, encoding)
    end
    def *(multiplier)
      raise TypeError unless Fixnum === multiplier
      self.class.from_array(to_a * multiplier, encoding)
    end

    private

    # Quack loud to invalid type. :-)
    def quack_invalid!(obj)
      raise TypeError unless obj.class < Unicode
    end

    public

    #--
    # Class methods:
    #
    class << self
      # Build Unicode::String from UCS4 array.
      def from_array(ucsary, encoding=$KCODE)
        obj = new(nil, encoding)
        obj.instance_eval { @ucsary = ucsary }
        return obj
      end
    end
  end
end

class String
  # Convert string to Unicode::String object.
  def to_u(encoding=$KCODE)
    raise "Pass encoding explicitly or set $KCODE properly." if
      encoding.nil? or encoding == 'NONE'
    Unicode::String.new(self, encoding)
  end
end

# vim: set sts=2 sw=2 et fdm=syntax fdl=2:
