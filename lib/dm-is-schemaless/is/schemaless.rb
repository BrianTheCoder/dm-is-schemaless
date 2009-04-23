require 'dm-types'
require 'uuidtools'

module DataMapper
  module Is
    module Schemaless

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
        before :save, :update_indexes
      end

      module ClassMethods
        
        def index_on(field)
          indexes[field] = ::Schemaless::Index.new(self, field)
          
          instance_eval <<-RUBY, __FILE__, __LINE__
            def by_#{field}(val,opts = {})
              keys = indexes[:"#{field}"].resource.all(:"#{field}" => val).map{|i| i.message_id}
            end
          RUBY
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
        
        private
          def add_model_type
            unless body.has_key?('model_type')
              body['model_type'] = self.class.to_s
            end
          end
          
          def update_indexes
            self.class.indexes.each do |key, index_model|
              if body.has_key?(key.to_s)
                index = index_model.resource.new(key => body[key.to_s])
                self.send(:"#{index_model.assoc_name}=",index)
              end
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
