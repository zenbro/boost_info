require 'minitest_helper'

class ParserTest < Minitest::Test
  def setup
    @simple_config = <<INFO
a 42

b string ; comment here
c string with space
c "string with; another value"
d
; comment
INFO

    @config_with_include = <<INFO
start 1
#include "#{File.join(File.dirname(__FILE__), 'include_test.conf')}"
end 2
INFO

    @config_with_invalid_include = <<INFO
start 1
#include "#{rand}"
end 2
INFO

    @nested_config = <<INFO
a 42
b {
  c x
  d {
    e y
    f
    g { }
    h 1
  ;comment
  }
}
c { ; comment
  g { a b }
  d x
} ; commment
d 1
INFO

    @hash = {
      a: 42,
      b: {
        c: 'x',
        d: {
          e: 'y',
          f: nil,
          g: {},
          h: 1
        }
      },
      c: {
        g: {
          a: 'b'
        },
        d: 'x'
      },
      d: 1
    }
  end


  def test_parse_without_nesting_nodes
    root_node = BoostInfo::Parser.from_info(@simple_config)
    assert_equal root_node.childrens.map(&:key), %w(a b c c d)
  end

  def test_include_inside_source
    root_node = BoostInfo::Parser.from_info(@config_with_include)

    node_b = root_node.find_children(:b)
    node_d = node_b.find_children(:d)

    assert_equal root_node.childrens.map(&:key), %w(start a b c d end)
    assert_equal node_b.childrens.map(&:key), %w(c d)
    assert_equal node_d.childrens.map(&:key), %w(e f g h)
  end

  def test_invalid_include_inside_source
    assert_raises Errno::ENOENT do
      BoostInfo::Parser.from_info(@config_with_invalid_include)
    end
  end

  def test_parse_with_nesting_nodes
    root_node = BoostInfo::Parser.from_info(@nested_config)
    node_b = root_node.find_children(:b)
    node_d = node_b.find_children(:d)

    assert_equal root_node.childrens.map(&:key), %w(a b c d)
    assert_equal node_b.childrens.map(&:key), %w(c d)
    assert_equal node_d.childrens.map(&:key), %w(e f g h)
  end

  def test_parser_hash
    root_node = BoostInfo::Parser.from_hash(@hash)
    node_b = root_node.find_children(:b)
    node_d = node_b.find_children(:d)

    assert_equal root_node.childrens.map(&:key), %w(a b c d)
    assert_equal node_b.childrens.map(&:key), %w(c d)
    assert_equal node_d.childrens.map(&:key), %w(e f g h)
  end
end
