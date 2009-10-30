require 'benchmark'
require 'rubygems'
require 'dm-core'

def respond_to_bench(n = 100000)
  fields = [ :test, :test.gt ]
  n.times do
    fields[rand(fields.size)].respond_to?(:target)
  end
end

def is_a_bench(n = 100000)
  fields = [ :test, :test.gt ]
  n.times do
    fields[rand(fields.size)].is_a?(DataMapper::Query::Operator)
  end
end

Benchmark.bm(10) do |x|
  x.report('respond_to?'){ respond_to_bench }
  x.report('is_a?'){ is_a_bench }
end