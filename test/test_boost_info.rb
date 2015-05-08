require 'minitest_helper'

class TestBoostInfo < Minitest::Test
  def setup
    @valid_info = <<-INFO
      key1 value1
      key2
      {
         key3
         {
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

    @info_hash = {
      'key1' => 'value1',
      'key2' => {
        'key3' => {
          'key4' => 'value4 with spaces'
        },
        'key5' => 'value5'
      }
    }
  end

  def test_parse_valid_info
    assert_equal @info_hash, BoostInfo.parse(@valid_info)
  end

  def test_parse_invalid_info
    assert_raises BoostInfo::ParseError do
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

  def test_generate_info_from_hash
    assert @valid_info, @info_hash.to_info(indent: 2)
  end

  def test_generate_info_from_hash_with_symbols
    assert 'x y', { x: :y }.to_info
  end
end
