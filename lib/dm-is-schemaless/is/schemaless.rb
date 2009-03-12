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
        end
      end

      module InstanceMethods

       private

      end
    end # List
  end # Is 
end # DataMapper
