# -*- coding: utf-8 -*-
$KCODE = 'UTF-8'

require 'unicode'
require 'test/unit'

class TestUnicodeString < Test::Unit::TestCase
  def setup
    @ustr = "가나다".to_u
  end
  def test_basic
    assert_equal @ustr, Unicode::String.from_array(@ustr.to_a)
    assert_equal 3, @ustr.length
    assert_equal "가나다", @ustr.to_s
    assert_equal "가나다".unpack('U*'), @ustr.to_a
    assert_equal "<U+AC00><U+B098><U+B2E4>", @ustr.inspect
    assert_equal 1, {"가나다".to_u => 1 }[@ustr]
  end
  def test_overrides
    assert_equal "가나가나가나".to_u, "가나".to_u * 3
  end
  def test_each
    uchars = @ustr.to_a.map { |c| Unicode::Character.new(c) }
    ueachs = []
    @ustr.each_char { |c| ueachs << c }
    assert_equal uchars, ueachs
  end
  def test_slices
    ustr = "가나다".to_u
    ustr[1] = "라".to_u
    assert_equal "가라다".to_u, ustr
    assert_raise(TypeError)  { ustr[1] = "타" }
    ustr[1..-1] = "나다".to_u
    assert_equal @ustr, ustr
    assert_equal "가나다라".to_u, "가나".to_u + "다라".to_u
  end
  def _test_gsub
    assert_equal "가라다".to_u, @ustr.gsub(/나/, "라")
    assert_equal "나다".to_u, @ustr.gsub(/가(나)/u, '\1')
    assert_equal "나다".to_u, @ustr.gsub(/(나)다/u) { $1 + $& }
  end
  def _test_scan
    s = "cruel world".to_u 
    assert_equal ["cruel", "world"], s.scan(/\w+/)
    assert_equal [["cr", "ue"], ["l ", "wo"]], s.scan(/(..)(..)/)
  end
  def test_split
    assert_equal ["가".to_u, "다".to_u], @ustr.split("나".to_u)
  end
  def test_index
    assert_equal 1, @ustr.index('나다'.to_u)
  end
  def test_other_string_methods
    assert_equal @ustr, " 가나다 ".to_u.strip
    assert_equal @ustr, "다나가".to_u.reverse
  end
  def test_justification
    assert_equal "   가나다".to_u, @ustr.ljust(3, ' '.to_u)
    assert_equal "XYZXYZ가나다".to_u, @ustr.ljust(2, 'XYZ'.to_u)
    assert_equal "가나다   ".to_u, @ustr.rjust(3, ' '.to_u)
    assert_equal "가나다XYZXYZ".to_u, @ustr.rjust(2, 'XYZ'.to_u)
  end
end

# vim: set sts=2 sw=2 et fdm=syntax fdl=1:
