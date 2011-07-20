class Admin::CurrenciesController < ApplicationController
  
  inherit_resources
  
  def index
    @currencies = Currency.all.paginate(:page => params[:page], :per_page => 100)
  end
  
  def create
    conversion = "#{params[:currency][:from]}_to_#{params[:currency][:to]}"
    @currency = Currency.new(:conversion => conversion, :rate => params[:rate])
    create! do |success, failure|
      success.html { redirect_to admin_currencies_path }
    end 
  end
  
  def update
    @currency = Currency.find(params[:id])
    if @currency.update_attributes(:rate => params[:rate])
      respond_to do |format|
        format.js{ render :json => { :status => 'success', :new_rate => params[:rate] } }
      end
    end
  end  
end
