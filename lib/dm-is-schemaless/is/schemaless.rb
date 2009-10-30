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
                
        property :added_id, DataMapper::Types::Serial, :key => false 
        property :id, DataMapper::Types::UUID,  :unique => true, 
                                                :nullable => false, 
                                                :index => true,
                                                :default => Proc.new{ Guid.new.to_s }
        property :updated, DataMapper::Types::EpochTime,  :key => true, 
                                                          :index => true, 
                                                          :default => Proc.new{ Time.now }
        property :body, DataMapper::Types::Json, :default => {}
        
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
          fields_to_rewrite = find_indexes(query)
          fields_to_rewrite.each do |(field, value)|
            name = field.respond_to?(:target) ? field.target : field
            rewritten_field = "#{indexes[name].assoc_name}.#{name}"
            rewritten_field << ".#{key.operator}" if field.respond_to?(:operator)
            query[rewritten_field] = value
            query.delete(key)
          end
        end
        
        def find_indexes(query)
          query.select do |key, value|
            indexes.has_key?(key.respond_to?(:target) ? key.target : key)
          end
        end
      end

      module InstanceMethods
        def initialize(args = {})
          super({})
          self.body = args
        end
        
        def method_missing(method_symbol, *args)
          method_name = method_symbol.to_s
          if %w(? =).include?(method_name[-1,1])
            method = method_name[0..-2]
            operator = method_name[-1,1]
            if operator == '='
              set_value(method, args.first)
            elsif operator == '?'
              !body[method].blank?
            end
          else 
            body[method_name]
          end
        end
        
        def set_value(method, val)
          if val.blank?
            body.delete(method)
          else
            body[method] = val
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
