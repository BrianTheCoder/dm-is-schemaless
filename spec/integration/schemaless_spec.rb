require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::Schemaless' do

    before :each do
      @message = Message.new
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
          @message.attributes.should have_key(k)
        end
        
        it "has the property #{k} of type #{v}" do
          Message.properties[k].type.should == v
        end
      end
    end
  end
end
