require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe 'DataMapper::Is::Schemaless' do

  before :each do
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
      :updated => DateTime,
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
      Message.indexes.should include(:user_id)
      @message.indexes.should include(:user_id)
    end
    
    it 'should create a table named ModelProperty' do
      defined?(MessageUserId).should == "constant"
    end
    
    {
      :user_id => String,
      :message_id => String
    }.each do |k, v|
      it "has the property #{k}" do
        MessageUserId.properties[k].should_not be_nil
      end

      it "has the property #{k} of type #{v}" do
        MessageUserId.properties[k].type.should == v
      end
    end
    
    it 'should define a has n relationship on the model' do
      Message.relationships[:message_user_ids].should_not be_nil
    end
    
    it 'should define a belongs_to relationship on the index table' do
      MessageUserId.relationships[:message].should_not be_nil
    end
  end
  
end