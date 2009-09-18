module DataMapper
  module Is
    module Schemaless
      class Index
        attr_accessor :storage_name, 
                      :model_name, 
                      :resource, 
                      :field, 
                      :assoc_name,
                      :parent
                  
        def initialize(model,field)
          name = "#{field.to_s.camel_case}Index"
          @storage_name = Extlib::Inflection.tableize(name)
          @field = field
          @model_name = Extlib::Inflection.classify(name)
          @parent = :"#{model.to_s.snake_case}"
          @resource = index_model(model)
          @assoc_name = name.snake_case.to_sym
          Object.const_set(model_name, resource)
          update_field_callbacks(model)
        end
    
        def index_model(model)
          resource = DataMapper::Model.new
          resource.storage_names[repository_name] = storage_name
          resource.property :"#{field}",     String, :key => true, :index => true
          resource.property :"#{parent}_id", String, :key => true, :index => true
          resource.belongs_to :"#{parent}"
          resource
        end
    
        def update_field_callbacks(model)
          model.class_eval <<-RUBY
            has n, :"#{assoc_name}", :child_key => [ :"#{parent}_id" ], :parent_key => [ :id ]
            def update_#{field}_index
              old = #{resource}.first(:#{parent}_id => id)
              old.destroy unless old.nil?
              if body.has_key?("#{field}")
                #{resource}.create(:#{parent}_id => id, :#{field} => body["#{field}"])
              end
            end
          RUBY
          model.before :save, :"update_#{field}_index"
        end
      end
    end
  end
end