class Admin::CurrenciesController < ApplicationController

  def index
    @currencies = Currency.all.paginate(:page => params[:page], :per_page => 100)
  end
  
  def update
    debugger
  end
  
end
