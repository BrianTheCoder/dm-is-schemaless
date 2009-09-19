module DataMapper
  module Is
    module Schemaless
      class Index
        attr_accessor :storage_name, 
                      :model_name, 
                      :field, 
                      :assoc_name,
                      :parent
                  
        def initialize(resource,field, opts)
          name = "#{field.to_s.camel_case}Index"
          @storage_name = Extlib::Inflection.tableize(name)
          @field = field
          @model_name = Extlib::Inflection.classify(name)
          @parent = :"#{resource.to_s.snake_case}"
          model = index_model
          @assoc_name = name.snake_case.to_sym
          Object.const_set(model_name, model)
          update_field_callbacks(resource)
        end
    
        def index_model
          model = DataMapper::Model.new
          model.storage_names[DataMapper.repository.name] = storage_name
          model.property :"#{field}",     String, :key => true, :index => true
          model.property :"#{parent}_id", String, :key => true, :index => true
          model.belongs_to :"#{parent}", :parent_key => [ :"#{parent}_id" ]
          model
        end
    
        def update_field_callbacks(resource)
          resource.class_eval <<-RUBY
            has n, :"#{assoc_name}", :child_key => [ :"#{parent}_id" ], :parent_key => [ :id ]
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
      end
    end
  end
end