class Admin::CurrenciesController < ApplicationController
  
  def index
    if params[:query]
      @currencies = Currency.all(:conditions => ["UPPER(conversion) LIKE UPPER(:q)", {:q => "%#{params[:query]}%"}])
      @currencies = @currencies.paginate(:page => params[:page], :per_page => 100)
    else
      @currencies = Currency.all.paginate(:page => params[:page], :per_page => 100)
    end
  end

  def new 
    @currency = Currency.new
  end
  
  def create
    conversion = "#{params[:currency][:from].upcase}_TO_#{params[:currency][:to].upcase}"
    @currency = Currency.new(:conversion => conversion, :rate => params[:currency][:rate])
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
      format.html{ flash[:notice] = "Currency has been deleted"; redirect_to admin_currencies_path }
    end
  end
  
  private
    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "conversion"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
  
end
