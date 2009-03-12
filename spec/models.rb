class Message
  include DataMapper::Resource
  
  is :schemaless
  
  index_on :user_id
end

class Photo
  include DataMapper::Resource

  is :schemaless
end