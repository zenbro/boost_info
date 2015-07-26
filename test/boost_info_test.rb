require 'minitest_helper'

class BoostInfoTest < Minitest::Test
  def setup
    @valid_info = <<INFO
key1 value1
key2 {
  key3 {
    key4 "value4 with spaces"
  }
  key5 value5
}
INFO

    @invalid_info = <<-INFO
      key1 value1
      key2
      {
    INFO

    @nested_info = <<INFO
key1 value1
key2 {
  key3 {
    key4 {
      key5 {
        key6 value2
      }
    }
  }
}
INFO

    @info_with_empty_section = <<INFO
key1 {
}
INFO

    @info_with_dup = <<INFO
key1 value1
key2 {
  key3 a
  key3 b
}
INFO

    @nested_hash = {
      key1: 'value1',
      key2: {
        key3: {
          key4: {
            key5: {
              key6: 'value2'
            }
          }
        }
      }
    }
    @info_hash = {
      'key1' => 'value1',
      'key2' => {
        'key3' => {
          'key4' => 'value4 with spaces'
        },
        'key5' => 'value5'
      }
    }

    @info_hash_without_dup = {
      'key1' => 'value1',
      'key2' => {
        'key3' => 'b'
      }
    }
  end

  def test_parse_valid_info
    assert_equal @info_hash, BoostInfo.parse(@valid_info)
  end

  def test_parse_invalid_info
    assert_raises BoostInfo::Parser::ParseError do
      BoostInfo.parse(@invalid_info)
    end
  end

  def test_parse_nil
    assert_raises TypeError do
      BoostInfo.parse(nil)
    end
  end

  def test_parse_with_symbolized_keys
    assert_equal({ x: 'y' }, BoostInfo.parse('x y', symbolize_keys: true))
  end

  def test_parse_nested_info
    assert_equal @nested_hash, BoostInfo.parse(@nested_info, symbolize_keys: true)
  end

  def test_parse_info_with_empty_section
    h = { key1: {} }
    assert_equal h,  BoostInfo.parse(@info_with_empty_section, symbolize_keys: true)
  end

  def test_parse_info_with_duplications
    assert_equal @info_hash_without_dup,  BoostInfo.parse(@info_with_dup)
  end

  def test_generate_info_from_hash
    assert_equal @valid_info, @info_hash.to_info(indent: 2)
  end

  def test_generate_info_from_nested_hash
    assert_equal @nested_info, @nested_hash.to_info(indent: 2)
  end

  def test_generate_info_from_hash_with_symbols
    assert_equal "x y\n", { x: :y }.to_info
  end

  def test_generate_info_with_empty_section
    assert_equal "x { }\n", { x: {} }.to_info
  end
end
