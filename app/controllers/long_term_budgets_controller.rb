class LongTermBudgetsController < Reporter::BaseController
  before_filter :load_organization
  before_filter :load_long_term_budget
  before_filter :load_current_response

  def show
    @coding_tree  = CodingTree.new(Activity.new, CodingBudget)
    @codes        = @coding_tree.root_codes
    @purpose_row  = render_to_string(:partial => 'purpose_row.html.haml',
                       :locals => {:ca => nil, :activity => nil})
  end

  def update
    @long_term_budget.update_budgets(params[:classifications])
    redirect_to long_term_budget_url(@year)
  end

  private
    def load_organization
      @organization = current_user.organization
    end

    def load_long_term_budget
      @long_term_budget = LongTermBudget.find_or_create_by_organization_id_and_year(
                                          @organization.id, params[:id])
    end

    def load_current_response
      @response = current_user.current_response
    end
end
