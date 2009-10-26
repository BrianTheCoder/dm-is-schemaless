module DataMapper
  module Is
    module Schemaless
      ##
      # fired when your plugin gets included into Resource
      #
      def self.included(base)
      end
      ##
      # Methods that should be included in DataMapper::Model.
      # Normally this should just be your generator, so that the namespace
      # does not get cluttered. ClassMethods and InstanceMethods gets added
      # in the specific resources when you fire is :example
      ##

      def is_schemaless(options = {})
        options = {  }.merge(options)
        # Add class-methods
        extend  DataMapper::Is::Schemaless::ClassMethods
        # Add instance-methods
        include DataMapper::Is::Schemaless::InstanceMethods
        class_inheritable_accessor(:indexes)
        self.indexes ||= {}
        
        storage_names[DataMapper.repository.name] = 'entities'
        
        property :added_id, DataMapper::Types::Serial, :key => false 
        property :id, DataMapper::Types::UUID, :unique => true, :nullable => false, :index => true
        property :updated, DataMapper::Types::EpochTime, :key => true, :index => true
        property :body, DataMapper::Types::Json 
        
        before :save, :add_model_type
      end

      module ClassMethods
        def storage_name(repository_name = default_repository_name); 'entities' end

        def index_on(field, opts = {})
          indexes[field] = Index.new(self, field, opts)
        end
        
        def all(query = {})
          super transform_query(query)
        end
        
        def first(query = {})
          super transform_query(query)
        end
        
        def last(query = {})
          super transform_query(query)
        end
        
        private
        
        def transform_query(query)
          query.each do |k,v|
            name = k.is_a?(DataMapper::Query::Operator) ? k.target : k
            if indexes.has_key?(name)
              key = "#{indexes[name].assoc_name}.#{name}"
              key << ".#{k.operator}" if k.is_a?(DataMapper::Query::Operator)
              query[key] = v
              query.delete(k)
            end
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
        
        def body=(val)
          #convert keys to strings
          normalized = Hash.new
          val.each{|k,v| normalized[k.to_s] = v }
          attribute_set(:body, normalized)
        end
        
        def body
          Mash.new(attribute_get(:body))
        end
        
        def method_missing(method_symbol, *arguments)
          method_name = method_symbol.to_s
          case method_name[-1..-1]
          when "="
            body[method_name[0..-2]] = arguments.first
          when "?"
            body[method_name[0..-2]] == true
          else
            # Returns nil on failure so forms will work
            body.has_key?(method_name) ? body[method_name] : nil
          end
        end
        
        private
          def add_model_type
            unless body.has_key?('model_type')
              body['model_type'] = self.class.to_s
            end
          end
      end
    end # Schemaless
  end # Is
end # DataMapper
