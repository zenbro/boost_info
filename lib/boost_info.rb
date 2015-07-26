require 'boost_info/version'
require 'boost_info/node'
require 'boost_info/parser'
require 'boost_info/generator'

module BoostInfo
  def self.parse(source, opts={})
    root_node = BoostInfo::Parser.from_info(source, opts)
    root_node.to_h(opts)
  end

  def self.from_hash(hash, opts={})
    BoostInfo::Parser.from_hash(hash, opts)
  end

  def self.from_info(source, opts={})
    BoostInfo::Parser.from_info(source, opts)
  end
end

class Hash
  def to_info(opts={})
    root_node = BoostInfo::Parser.from_hash(self, opts)
    root_node.to_info(opts)
  end
end
