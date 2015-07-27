require 'minitest_helper'

class GeneratorTest < Minitest::Test
  def setup
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

    @source = <<INFO
a 42
b {
  c x
  d {
    e y
    f
    g { }
    h 1
  }
}
c {
  g {
    a b
  }
  d x
}
d 1
INFO
  end

  def test_generate_same_hash
    root_node = BoostInfo::Parser.from_info(@source)
    assert_equal @hash, root_node.to_h(symbolize_keys: true)
  end

  def test_generate_same_string
    root_node = BoostInfo::Parser.from_info(@source)
    assert_equal @source, root_node.to_info(indent: 2)
  end

end
