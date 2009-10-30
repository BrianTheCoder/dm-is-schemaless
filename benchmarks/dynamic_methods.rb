require 'rubygems'
require 'benchmark'
require 'extlib'
require 'randexp'
require 'dm-core'
require 'dm-types'

PROPS = 10.of{ /\w+/.gen }

class SimpleDataMapper
  include DataMapper::Resource
  
  property :id,   Serial
  property :body, DataMapper::Types::Json, :default => {}
end

class Missing < SimpleDataMapper
  def method_missing(method_symbol, *args)
    method_name = method_symbol.to_s
    case method_name[-1..-1]
    when "="
      val = args.first
      prop = method_name[0..-2]
      if val.blank? && body.has_key?(prop)
        body.delete(prop)
      else
        body[prop] = args.first
      end
    when "?"
      body[method_name[0..-2]] == true
    else
      # Returns nil on failure so forms will work
      body[method_name]
    end
  end
end

class DefineMethod < SimpleDataMapper
  private
  
  def method_missing(method_symbol, *args)
    method_name = method_symbol.to_s

    method = case method_name[-1, -1]
      when '?' then define_bool(method_symbol,   method_name[0..-2])
      when '=' then define_setter(method_symbol, method_name[0..-2])
      else          define_getter(method_symbol)
    end

    method.call(*args)
  end

  def define_bool(method_symbol, property_name)
    self.class.send(:define_method, method_symbol) do
      body[property_name].blank?
    end
  end

  def define_setter(method_symbol, property_name)
    self.class.send(:define_method, method_symbol) do |value|
      if value.blank?
        body.delete(property_name)
      else
        body[property_name] = value
      end
    end
  end

  def define_getter(property_name)
    self.class.send(:define_method, property_name) do
      body[property_name]
    end
  end
end

class InstanceEvalMethod < SimpleDataMapper
  private
  
  def method_missing(method_symbol, *args)
    method_name = method_symbol.to_s
    case method_name[-1..-1]
    when "="
      define_setter(method_name, method_name[0..-2], args.first)
    when "?"
      define_bool(method_name, method_name[0..-2])
    else
      define_getter(method_name)
    end
  end
    
  def define_getter(prop)
    instance_eval  <<-RUBY, __FILE__, __LINE__ + 1
      def #{prop}
        body["#{prop}"]
      end
    RUBY
    send(prop)
  end
  
  def define_setter(method, prop, value)
    instance_eval  <<-RUBY, __FILE__, __LINE__ + 1
      def #{method}(val)
        if val.blank? && body.has_key?("#{prop}")
          body.delete("#{prop}")
        else
          body["#{prop}"] = val
        end
      end
    RUBY
    send(method, value)
  end
  
  def define_bool(method, prop)
    method_body = lambda{ body[prop].blank? }
    instance_eval  <<-RUBY, __FILE__, __LINE__ + 1
      def #{method}
        body["#{prop}"].blank?
      end
    RUBY
    send(method)
  end
end

def bench(klass, n = 20000)
  extensions = ['','=','?']
  n.times do
    model = klass.new
    ext = extensions.pick
    method = "#{PROPS.pick}#{ext}"
    case ext
    when '='
      model.send(method, /\w+/.gen)
    else
      model.send(method)
    end
  end
end

Benchmark.bm(30) do |x|
  x.report('method missing'){ bench(Missing) }
  x.report('method missing w/define_method'){ bench(DefineMethod) }
  x.report('method missing w/instance_eval'){ bench(InstanceEvalMethod) }
end