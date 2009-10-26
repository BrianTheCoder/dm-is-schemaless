require 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  require 'pathname'
  require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

  describe 'DataMapper::Is::Schemaless' do

    before :each do
      DataMapper.auto_migrate!
      @message = Message.new
      @photo = Photo.new
    end

    describe 'common table' do
      it 'should set each models table to entities' do
        Message.storage_name.should == "entities"
        Photo.storage_name.should == "entities"
        Photo.storage_name.should == Message.storage_name
      end
    end

    describe 'structure' do
      {
        :added_id => DataMapper::Types::Serial,
        :id => DataMapper::Types::UUID,
        :updated => DataMapper::Types::EpochTime,
        :body => DataMapper::Types::Json
      }.each do |k, v|
        it "has the property #{k}" do
          Message.properties[k].should_not be_nil
        end

        it "has the property #{k} of type #{v}" do
          Message.properties[k].type.should == v
        end
      end
    end

    describe 'index tables' do
      it 'should have empty indexes if none are created' do
        @photo.indexes.should be_empty
      end

      it 'should add the index to the list' do
        Message.indexes.should have_key(:email)
        @message.indexes.should have_key(:email)
      end

      it 'should create a table named ModelProperty' do
        defined?(EmailIndex).should == "constant"
      end

      {
        :email => String,
        :message_updated => DataMapper::Types::EpochTime
      }.each do |k, v|
        it "has the property #{k}" do
          EmailIndex.properties[k].should_not be_nil
        end

        it "has the property #{k} of type #{v}" do
          EmailIndex.properties[k].type.should == v
        end
      end

      it 'should define a has n relationship on the model' do
        Message.relationships[:email_index].should_not be_nil
      end

      it 'should define a belongs_to relationship on the index table' do
        EmailIndex.relationships[:message].should_not be_nil
      end
    end

    describe 'model_type field' do
      it 'adds it to date on save' do
        @message.save
        @msg = Message.first
        @msg.body.should have_key("model_type")
        @msg.model_type.should == "Message"
      end
    end

    describe 'update the index' do
      it 'should create a new record on save' do
        @message.email = Faker::Internet.free_email
        @message.save
        @message.reload
        @message.email_index.should_not be_nil
      end
      
      it 'should destroy the index if the value becomes nil' do
        @message.email = Faker::Internet.free_email
        @message.save
        @message.email_index.should_not be_nil
        @message.email = nil
        @message.save
        @message.email_index.should be_nil        
      end
      
      it 'should update the index when the value is changed' do
        @message.email = Faker::Internet.free_email
        @message.save
        @message.reload
        @message.email_index.should_not be_nil
        email = Faker::Internet.free_email
        @message.email = email
        @message.save
        @message.email_index.email.should == email
      end
    end
    
    describe 'querying' do
      it 'should look in the index tables if the property is indexed' do
        email = Faker::Internet.free_email
        @message.email = email
        @message.save
        queried = Message.first(:email => email)
        queried.id.should == @message.id
      end
    end
  end
end
