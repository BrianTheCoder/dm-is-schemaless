require 'dm-types'
require 'uuidtools'

module DataMapper
  module Is
    module Schemaless
      class NoIndex < StandardError; end

      def is_schemaless(options={})
        options = {  }.merge(options)
        extend  DataMapper::Is::Schemaless::ClassMethods
        include DataMapper::Is::Schemaless::InstanceMethods
        
        class_inheritable_accessor(:indexes)
        self.indexes ||= {}
        
        storage_names[repository_name] = 'entities'
        
        property :added_id, DataMapper::Types::Serial, :key => false unless properties.has_property?(:added_id) && properties[:added_id].type == DataMapper::Types::Serial
        property :id, String, :unique => true, :nullable => false unless properties.has_property?(:id) && properties[:id].type == String
        property :updated, DataMapper::Types::EpochTime, :key => true unless properties.has_property?(:updated) && properties[:updated].type == EpochTime
        property :body, DataMapper::Types::Json unless properties.has_property?(:body) && properties[:body].type == DataMapper::Types::Json
        
        before :save, :add_model_type
      end

      module ClassMethods
        
        
        def index_on(field)
          indexes[field] = ::Schemaless::Index.new(self, field)
        end
        
        def by_index(field,conds)
          raise(DataMapper::Is::Schemaless::NoIndex, "There is no index on #{field} add \"index_on :#{field}\" in your model to fix this") if indexes[field].nil?
          key = "#{indexes[field].assoc_name}.#{field}"
          if conds.is_a?(String) || conds.is_a?(Numeric)
            all(key => conds)
          elsif conds.is_a?(Hash)
            all("#{key}.#{conds.keys.first}" => conds.values.first) 
          end
        end
      end

      module InstanceMethods
        def initialize(args = {})
          super({})
          self.body = args
          self.id = Guid.new.to_s
          self.updated = Time.now.to_i
        end
        
        def indexes
          self.class.indexes
        end
        
        def body=(val)
          #convert keys to strings
          normalized = Hash.new
          val.each{|k,v| normalized[k.to_s] = v }
          attribute_set(:body, normalized)
        end
        
        def body
          Mash.new(attribute_get(:body))
        end
        
        private
          def add_model_type
            unless body.has_key?('model_type')
              body['model_type'] = self.class.to_s
            end
          end
          
          def new_model(key, value)
            model = value.last.new
            model.send(:"#{key}=", body[key])
            model.send(:"#{self.class.to_s.downcase}=",self)
            self.send(:"#{value.first}=",model)
          end
      end
    end # List
  end # Is 
end # DataMapper
