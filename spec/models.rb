require 'dm-sweatshop'
require 'faker'

class Message
  include DataMapper::Resource
  
  is :schemaless
  
  index_on :email
end

class Photo
  include DataMapper::Resource

  is :schemaless
end

Message.fixture{{
  :username => Faker::Internet.user_name,
  :email => Faker::Internet.free_email,
  :body => Faker::Lorem.paragraph(10),
  :city => Faker::Address.city,
  :us_state_abbr => Faker::Address.us_state_abbr,
  :post_code => Faker::Address.zip_code
}}