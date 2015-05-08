# encoding: utf-8

module BoostInfo
  class Node
    attr_accessor :level, :name, :value, :parent, :children

    def initialize(level, name, value=nil)
      # Instance initializer
      @level = level
      @name = name
      @value = value
      @parent = nil
      @children = []
    end

    def to_s
      # String representation for node
      if @value
        "#{'| '*@level}#{@level} #{@name} = #{@value}"
      else
        "#{'| '*@level}#{@level} #{@name}"
      end
    end

    def to_h(symbolize=false)
      key = symbolize ? @name.to_sym : @name
      if has_children?
        result = {}
        @children.each { |c| result.merge!(c.to_h(symbolize)) }
        { key => result }
      else
        { key => @value }
      end
    end

    def add_child(child)
      # Add child node and assign parent to child node
      child.parent = self
      @children << child
    end

    def has_children?
      # Check children existence
      @children.size > 0
    end

    def has_parent?
      # Check parent existence
      @parent != nil
    end

    def find(name)
      # Recursive node search by name
      return self if @name == name
      result_node = nil
      @children.each do |node|
        if node.name==name then result_node = node; break end
        if node.has_children?
          found_node = node.find(name)
          if found_node
            if found_node.name==name then result_node = found_node; break end
          end
        end
      end
      result_node
    end
  end
end
