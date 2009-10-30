module DataMapper
  module Is
    module Schemaless
      class Index
        attr_accessor :storage_name, :parent, :assoc_name
        
        class IndexingError < StandardError; end
                          
        def initialize(resource,field, opts)
          name = "#{field.to_s.camel_case}Index"
          @storage_name = Extlib::Inflection.tableize(name)
          @parent = :"#{resource.to_s.snake_case}"
          index_model = build_resource(name, field, resource)
          update_field_callbacks(resource, field, index_model)
        end

        def update_field_callbacks(model, field, index_model)
          self.assoc_name = index_model.to_s.snake_case
          model.has 1, assoc_name.to_sym
          model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def update_#{field}_index
              if body.key?('#{field}')
                self.#{assoc_name} ||= #{index_model}.new
                #{assoc_name}.#{field} = body['#{field}']
              elsif #{assoc_name} && #{assoc_name}.destroy
                self.#{assoc_name} = nil
              else
              end
            end
          RUBY
          model.before :save, :"update_#{field}_index"
        end
        
        def build_resource(name, field, parent_resource)
          klass = Object.const_set(name, Class.new)
          klass.send(:include, DataMapper::Resource)
          klass.property field.to_sym, String, :key => true
          parent_resource.key.each do |prop|
            klass.property :"#{@parent}_#{prop.name}", prop.type, :key => true
          end
          klass.belongs_to @parent, :parent_key => parent_resource.key.map{|k| k.name }
          klass
        end
      end
    end
  end
end