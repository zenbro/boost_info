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
  ;comment
  }
}
c { ; comment
  g { a b }
  d x
} ; commment
d 1
INFO
  end

  def test_generate_hash
    root_node = BoostInfo::Parser.from_info(@source)
    assert_equal @hash, root_node.to_h(symbolize_keys: true)
  end

end
