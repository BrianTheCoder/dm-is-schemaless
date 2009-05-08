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
      model.has 1, assoc_name, :child_key => [:"#{parent}_id"], :parent_key => [:id]
      Object.const_set(model_name, resource)
      update_field_callbacks(model)
    end
    
    def index_model(model)
      resource = DataMapper::Model.new(storage_name)
      resource.property field.to_sym, String, :key => true, :index => true
      resource.property :"#{parent}_id", String, :key => true, :index => true
      resource.class_eval <<-RUBY
        def #{parent}(opts = {})
          #{model}.first(opts.merge(:id => self.#{parent}_id))
        end
      RUBY
      resource
    end
    
    def update_field_callbacks(model)
      model.class_eval <<-RUBY
        def #{assoc_name}(opts = {})
          #{resource}.first(opts.merge(:#{parent}_id => id))
        end
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