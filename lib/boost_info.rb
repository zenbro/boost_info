require 'boost_info/version'
require 'boost_info/node'
require 'boost_info/parser'
require 'boost_info/generator'

module BoostInfo
  def self.parse(source, opts={})
    BoostInfo::Parser.new(source, opts).parse.to_h
  end

  def self.generate(hash, opts={})
    BoostInfo::Generator.new(hash, opts).generate
  end
end

class Hash
  def to_info(opts={})
    BoostInfo.generate(self, opts)
  end
end
