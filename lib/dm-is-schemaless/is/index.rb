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
          update_field_callbacks(resource, field)
        end

        def update_field_callbacks(resource, field, index_model)
          resource.class_eval <<-RUBY
            has 1, :"#{storage_name}"
            def update_#{field}_index
              if body.has_key?("#{field}")
                old = #{storage_name}.first
                if old.blank?
                  #{storage_name}.create(:#{field} => body["#{field}"])
                else
                  #{storage_name}.first.update(:#{field} => body["#{field}"])
                end
              else
                old = #{storage_name}.first
                old.destroy unless old.blank?
              end
            end
          RUBY
          resource.before :save, :"update_#{field}_index"
        end
        
        def build_resource(name, field, parent_resource)
          Object.class_eval <<-RUBY
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