class UsersController < ApplicationController
  authorize_resource

  @@shown_columns = [:username, :email,   :password, :password_confirmation, :roles]
  @@create_columns = [:username, :email,  :password, :password_confirmation] #TODO allow roles editing, assign to only 1

  def self.create_columns
    @@create_columns
  end

  active_scaffold :user do |config|
    config.columns =  @@shown_columns
    list.sorting = {:username => 'DESC'}
    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    list.sorting = { :username => 'DESC' }
  end

  record_select :per_page => 20, :search_on => 'username', :order_by => "username ASC"

  def to_label
    @s="User: "
    if username.nil? || username.empty?
      @s+"<No Name>"
    else
      @s+username
    end
  end
end

