class Admin::CurrenciesController < ApplicationController
  
  def index
    @currencies = Currency.all.paginate(:page => params[:page], :per_page => 100)
  end

  def new 
    @currency = Currency.new
  end
  
  def create
    conversion = "#{params[:currency][:from]}_TO_#{params[:currency][:to]}"
    @currency = Currency.new(:conversion => conversion, :rate => params[:rate])
    if @currency.save
      respond_to do |format|
        format.html { flash[:notice] = "You have successfully added a currency"
                      redirect_to admin_currencies_path}
      end
    end
  end
  
  def update
    @currency = Currency.find(params[:id])
    if @currency.update_attributes(:rate => params[:rate])
      respond_to do |format|
        format.js{ render :json => { :status => 'success', :new_rate => params[:rate] } }
        format.json{ render }
      end
    end
  end 
  
  def destroy
    c = Currency.find(params[:id])
    c.delete
    respond_to do |format|
      format.html{ redirect_to admin_currencies_path }
    end
  end
  
end
