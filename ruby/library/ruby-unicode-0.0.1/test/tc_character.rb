# -*- coding: utf-8 -*-
$KCODE = 'UTF-8'

require 'unicode'
require 'test/unit'

class TestUnicodeCharacter < Test::Unit::TestCase
  def setup
    @uchar = Unicode::Character.new(0xAC00)
  end
  def test_all
    assert_equal 0XAC00, @uchar.to_i
    assert_equal '가', @uchar.to_s
    assert_equal '<U+AC00>', @uchar.inspect
  end
end
