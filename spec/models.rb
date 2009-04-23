class Message
  include DataMapper::Resource
  
  is :schemaless
  
  index_on :iso_language_code
end

class Photo
  include DataMapper::Resource

  is :schemaless
end