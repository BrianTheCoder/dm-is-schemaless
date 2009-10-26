module DataMapper
  module Is
    module Schemaless
      class Index
        attr_accessor :storage_name, :parent_str
                          
        def initialize(resource,field, opts)
          name = "#{field.to_s.camel_case}Index"
          @storage_name = Extlib::Inflection.tableize(name)
          @parent = :"#{resource.to_s.snake_case}"
          update_field_callbacks(resource, field)
          build_resource(name, field, resource)
        end

        def update_field_callbacks(resource, field)
          p resource
          resource.class_eval <<-RUBY
            has n, :"#{storage_name}", :child_key => [ :"#{parent}_id" ], :parent_key => [ :id ]
            def update_#{field}_index
              old = #{resource}.first(:#{parent}_id => id)
              old.destroy unless old.nil?
              if body.has_key?("#{field}")
                #{resource}.create(:#{parent}_id => id, :#{field} => body["#{field}"])
              end
            end
          RUBY
          resource.before :save, :"update_#{field}_index"
        end
        
        def build_resource(name, field, parent)
          Object.class_eval <<-RUBY
            class #{name}
              include DataMapper::Resource
              property :"#{field}",          String, :key => true, :index => true
            end
          RUBY
          klass = Object.const_get(name)
          parent.key.each do |prop|
            klass.property :"#{@parent}_#{prop.name}", prop.type, :key => true, :index => true
          end
          klass.belongs_to @parent, :parent_key => parent.key.map(&:name)
        end
      end
    end
  end
end