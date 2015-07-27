# encoding: utf-8

module BoostInfo
  class Node
    attr_accessor :root, :key, :value, :parent, :childrens

    def initialize(params={})
      @root = params[:root]
      @key = params[:key].to_s if params[:key] # normalize key
      @value = params[:value]
      @parent = params[:parent]

      @childrens = nil
    end

    def get(key_to_get, params={})
      return [] unless @childrens

      if key_to_get.is_a?(Regexp)
        @childrens.select { |c| c.key =~ key_to_get }
      else
        @childrens.select { |c| c.key == key_to_get.to_s }
      end
    end

    def find_by_path(path, params={})
      path_copy = path.dup
      traverse_path(path_copy, params)
    end

    def traverse_path(path, params={})
      if path.size > 1
        next_node_key = path.shift
        node = get(next_node_key).first
        node.find_by_path(path) if node
      elsif path.size == 1
        last_key = path.last
        get(last_key).first
      end
    end

    def find_by_key(key, params={})
      result = []
      childrens.each do |node|
        if key.is_a?(Regexp)
          result << node if node.key =~ key
        else
          result << node if node.key == key.to_s
        end

        if node.childrens
          result_from_children = node.find_by_key(key, params)
          result.concat(result_from_children)
        end
      end
      result
    end

    def parents
      result = []
      unless root
        result << parent
        result.concat(parent.parents)
      end
      result
    end

    def siblings
      parent_childrens = (parent && parent.childrens) || []
      parent_childrens.reject { |c| c == self }
    end

    def auto_insert(path, value, params={})
      params[:force] ||= true
      if params[:force]
        params[:delete_if] = ->(node) { node.childrens.nil? }
      end

      current_node = self
      path.each do |new_key|
        existing_node = current_node.get(new_key).first
        current_node = if existing_node && existing_node.childrens
                        existing_node
                      else
                        current_node.insert(new_key, value, params)
                      end
      end
      current_node
    end

    def insert(key, value, params={})
      node = Node.new(key: key, value: value)
      insert_node(node, params)
      node
    end

    def insert_node(node, params={})
      node.parent = self
      @childrens ||= []
      @childrens.delete_if(&params[:delete_if]) if params[:delete_if]

      if params[:after]
        insert_node_after(params[:after], node)
      elsif params[:before]
        insert_node_before(params[:before], node)
      elsif params[:prepend]
        @childrens.unshift(node)
      else
        @childrens << node
      end
      node
    end

    def insert_node_after(key, node)
      index = @childrens.index { |c| c.key == key.to_s }
      index += 1 if index
      index = @childrens.size if index > @childrens.size || index.nil?
      @childrens.insert(index, node)
      node
    end

    def insert_node_before(key, node)
      index = @childrens.index { |c| c.key == key.to_s }
      index ||= 0
      @childrens.insert(index, node)
      node
    end

    def delete(key)
      node = find_children(key.to_s)
      return unless node

      delete_children(node)
    end

    def find_children(key_to_find)
      return unless @childrens
      key_to_find = key_to_find.to_s
      @childrens.find { |children| children.key == key_to_find }
    end

    def delete_children(node)
      return unless @childrens

      node.parent = nil

      index = @childrens.index(node)
      @childrens.delete_at(index)
      @childrens = nil if @childrens.empty?

      node
    end

    def to_h(params={})
      BoostInfo::Generator.new(self, params).to_hash
    end

    def to_info(params={})
      BoostInfo::Generator.new(self, params).to_info
    end
  end
end
