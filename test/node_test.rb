require 'minitest_helper'

class NodeTest < Minitest::Test
  def setup
    @root_node = BoostInfo::Node.new(root: true)
    @node_a = BoostInfo::Node.new(key: :a, value: 1)
    @node_b = BoostInfo::Node.new(key: :b, value: 2)
    @node_c = BoostInfo::Node.new(key: :c, value: 3)
  end

  def test_inserting_nodes
    @root_node.insert_node(@node_a)

    assert_equal @node_a.parent, @root_node
    assert_includes @root_node.childrens, @node_a
  end

  def test_node_siblings
    @root_node.insert_node(@node_a)
    @root_node.insert_node(@node_b)
    @root_node.insert_node(@node_c)

    assert_equal @node_a.siblings, [@node_b, @node_c]
    assert_equal @node_b.siblings, [@node_a, @node_c]
    assert_equal @node_c.siblings, [@node_a, @node_b]
  end

  def test_deleting_not_existing_node
    assert_nil @root_node.delete(:a)
  end

  def test_deleting_existing_node
    @root_node.insert_node(@node_a)
    @root_node.insert_node(@node_b)
    @root_node.insert_node(@node_c)

    deleted_node = @root_node.delete(:b)

    assert_equal @node_b, deleted_node
    assert_equal @node_a.siblings, [@node_c]
    assert_equal @node_c.siblings, [@node_a]
    assert_empty deleted_node.siblings
  end

  def test_insert_node_before
    @root_node.insert_node(@node_a)
    @root_node.insert_node(@node_b)
    @root_node.insert_node(@node_c, before: :b)

    assert_equal @root_node.childrens, [@node_a, @node_c, @node_b]
  end

  def test_insert_node_after
    @root_node.insert_node(@node_a)
    @root_node.insert_node(@node_b)
    @root_node.insert_node(@node_c, after: :a)

    assert_equal @root_node.childrens, [@node_a, @node_c, @node_b]
  end

  def test_inserting_nodes_to_childrens
    @root_node.insert_node(@node_a)
    @node_a.insert_node(@node_b)
    @node_b.insert_node(@node_c)

    assert_equal @root_node.childrens, [@node_a]
    assert_equal @node_a.parent, @root_node
    assert_equal @node_a.childrens, [@node_b]
    assert_equal @node_b.parent, @node_a
    assert_equal @node_b.childrens, [@node_c]
    assert_equal @node_c.parent, @node_b
  end

  def test_parents
    @root_node.insert_node(@node_a)
    @node_a.insert_node(@node_b)
    @node_b.insert_node(@node_c)

    expected_parents = [@node_b, @node_a, @root_node]
    assert_equal expected_parents, @node_c.parents
  end

  def test_find_by_key
    @root_node.insert_node(@node_a)
    @node_a.insert_node(@node_b)
    @node_b.insert_node(@node_c)

    assert_equal @root_node.find_by_key(:c), [@node_c]
  end

  def test_find_by_regex
    @root_node.insert_node(@node_a)
    @node_a.insert_node(@node_b)
    @node_b.insert_node(@node_c)
    @node_a.key = 'c'
    @node_b.key = 'c1'
    @node_c.key = 'c2'

    assert_equal @root_node.find_by_key(/c\d/), [@node_b, @node_c]
  end

  def test_get_not_existing_children
    assert_equal @root_node.get(:test), []
  end

  def test_get_existing_node
    @root_node.insert_node(@node_a)
    @root_node.insert_node(@node_b)

    assert_equal @root_node.get(:b), [@node_b]
  end

  def test_find_by_not_existing_path
    assert_nil @root_node.find_by_path([:a, :b, :c])
  end

  def test_path_unchanged_after_find_by
    expected_path = [:a, :b, :c]
    actual_path = expected_path.dup
    @root_node.find_by_path(actual_path)

    assert_equal expected_path, actual_path
  end

  def test_find_by_existing_path
    @root_node.insert_node(@node_a)
    @node_a.insert_node(@node_b)
    @node_b.insert_node(@node_c)

    assert_equal @root_node.find_by_path([:a, :b, :c]), @node_c
  end

  def test_auto_insert
    node_c = @root_node.auto_insert([:a, :b, :c], 42)
    assert_equal node_c.parents.map(&:key), ['b', 'a', nil]
  end
end
