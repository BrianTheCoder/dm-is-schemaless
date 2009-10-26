module DataMapper
  module Is
    module Schemaless
      class Index
        attr_accessor :storage_name, :parent
                          
        def initialize(resource,field, opts)
          name = "#{field.to_s.camel_case}Index"
          @storage_name = Extlib::Inflection.tableize(name)
          @parent = :"#{resource.to_s.snake_case}"
          index_model = build_resource(name, field, resource)
          update_field_callbacks(resource, field, index_model)
        end

        def update_field_callbacks(model, field, index_model)
          assoc_name = index_model.to_s.snake_case
          model.has 1, assoc_name.to_sym
          model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def update_#{field}_index
              if body.key?('#{field}')
                attributes = { :#{field} => body['#{field}'] }
                self.#{assoc_name} ||= #{index_model}.new(attributes)
                #{assoc_name}.update(attributes) unless #{assoc_name}.dirty?
              elsif #{assoc_name}
                #{assoc_name}.destroy
              end
            end
          RUBY
          model.before :save, :"update_#{field}_index"
        end
        
        def build_resource(name, field, parent_resource)
          Object.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            class #{name}
              include DataMapper::Resource
              property :"#{field}",          String, :key => true, :index => true
            end
          RUBY
          klass = Object.const_get(name)
          parent_resource.key.each do |prop|
            klass.property :"#{@parent}_#{prop.name}", prop.type, :key => true, :index => true
          end
          klass.belongs_to @parent, :parent_key => parent_resource.key.map(&:name)
          klass
        end
      end
    end
  end
end