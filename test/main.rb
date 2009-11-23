require 'rubygems'
require 'sqlite3'
require 'active_record'
require File.dirname(__FILE__) + '/../lib/active_index'
require 'test/unit'
require 'shoulda'
require 'mocha'

MY_DB_NAME = 'test.db.sqlite3'
MY_DB = SQLite3::Database.new(MY_DB_NAME)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MY_DB_NAME)
ActiveRecord::Base.connection.execute 'DROP TABLE IF EXISTS `lamps`'
ActiveRecord::Base.connection.create_table :lamps do |t|
  t.integer :id
  t.string :name
end

class Lamp < ActiveRecord::Base
end

class ActiveIndexTest < Test::Unit::TestCase

  context "The Lamp class" do
    should "respond to find_with_index" do
      assert Lamp.respond_to?(:find_with_index)
      assert Lamp.respond_to?(:find_without_index)
    end
  end

  context 'With some records' do
    setup do
      Lamp.create!(:name => 'kanye')
      Lamp.create!(:name => 'ryan')
    end

    should "be alias method chained" do
      Lamp.expects(:find_without_index).once
      Lamp.expects(:find_with_index).never
      Lamp.find_by_name('33')
    end

    should "still work with find" do
      assert !Lamp.find_by_name('whoa')
    end

    should "find things" do
      assert Lamp.find_by_name('kanye')
    end
    
    should "use string when given" do
      str = 'index_on_names_idx'
      Lamp.expects(:find_without_index).with(:first, :from => "`lamps` USE INDEX `#{str}`", :conditions => {:name => 'dude'}).once
      Lamp.find(:first, :index => str, :conditions => {:name => 'dude'}) 
    end

    should_eventually "use symbol when given" do
      Lamp.expects(:find_without_index).with(:first, :from => "`lamps` USE INDEX `index_on_name`", :conditions => {:name => 'dude'}).once
      Lamp.find(:first, :index => :name, :conditions => {:name => 'dude'})
    end

    should_eventually "build out index when given array" do
      Lamp.expects(:find_without_index).with(:first, :from => "`lamps` USE INDEX `index_on_name_id`", :conditions => {:name => 'dude'}).once
      Lamp.find(:first, :index => [:name, :id], :conditions => {:name => 'dude'})  
    end
  end
end
