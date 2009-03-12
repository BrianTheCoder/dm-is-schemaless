require 'dm-types'

module DataMapper
  module Is
    module Schemaless

      def is_schemaless(options={})
        options = {  }.merge(options)
        extend  DataMapper::Is::Schemaless::ClassMethods
        include DataMapper::Is::Schemaless::InstanceMethods
        
        def self.storage_name
          "entities"
        end
        
        property :added_id, DataMapper::Types::Serial, :serial => true unless properties.detect{|p| p.name == :added_id && p.type == Serial}
        property :id, DataMapper::Types::UUID, :unique => true, :nullable => false unless properties.detect{|p| p.name == :id && p.type == Binary}
        property :updated, DateTime, :key => true unless properties.detect{|p| p.name == :updated && p.type == DateTime}
        property :body, DataMapper::Types::Json unless properties.detect{|p| p.name == :body && p.type == Text}
      end

      module ClassMethods
        def index_on(field)
          add_index field
          name = self.name + field.to_s.camel_case
          storage_name = Extlib::Inflection.tableize(name)
          model_name = Extlib::Inflection.classify(name)
          model = DataMapper::Model.new(storage_name)
          model.property field.to_sym, String
          model.belongs_to Extlib::Inflection.underscore(self.name).gsub('/', '_').to_sym, :parent_key => [ :id ]
          has n, Extlib::Inflection.underscore(model_name).gsub('/', '_').to_sym
          Object.const_set(model_name, model)
        end
        
        def indexes
          @indexes ||= []
        end
        
        def add_index(field)
          indexes << field
        end
      end

      module InstanceMethods
        def indexes
          self.class.indexes
        end
        
        private

      end
    end # List
  end # Is 
end # DataMapper
