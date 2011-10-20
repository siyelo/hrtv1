require 'fastercsv'

class Reports::ClassificationSplit
  include Reports::Helpers
  include CurrencyHelper

  def initialize(request, amount_type, classification_type)
    @amount_type                = amount_type
    @classification_type        = classification_type
    @classification_association = classification_association(amount_type,
                                    classification_type)
    @code_deepest_nesting       = case classification_type
                                  when :purpose
                                    Code.deepest_nesting
                                  when :input
                                    CostCategory.deepest_nesting
                                  else
                                    1
                                  end

    @is_budget          = is_budget?(amount_type)
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => :data_response },
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :activity => [{ @classification_association => :code },
        { :project => { :in_flows => :from } },
        { :data_response => :organization }]},
        { :organization => :data_responses }]
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @implementer_splits.each do |implementer_split|
        build_rows(csv, implementer_split)
      end
    end
  end

  private
    def build_header
      row = []

      classification_name = @classification_type.to_s.capitalize
      amount_name         = @amount_type.to_s.capitalize

      row << 'Organization'
      row << 'Project'
      row << 'Funding Source'
      row << 'Data Response ID'
      row << 'Activity ID'
      row << 'Activity'
      row << "Total Activity #{amount_name} ($)"
      row << 'Implementer'
      row << "Total Implementer #{amount_name} ($)"
      row << "#{classification_name} Code"
      row << "#{classification_name} Code Split (%)"
      row << "Implementer #{amount_name} by #{classification_name}"
      row << 'Possible Duplicate?'
      row << 'Actual Duplicate?'
      @code_deepest_nesting.times{ row << "#{classification_name} Hierarchy" }

      row
    end

    def build_rows(csv, implementer_split)
      activity = implementer_split.activity
      base_row = []
      if @is_budget
        activity_amount = activity.budget          || 0
        split_amount    = implementer_split.budget || 0
      else
        activity_amount = activity.spend           || 0
        split_amount    = implementer_split.spend  || 0
      end

      activity_amount = universal_currency_converter(activity_amount.to_f,
        activity.currency, 'USD')
      split_amount = universal_currency_converter(split_amount.to_f,
        activity.currency, 'USD')

      # dont bother printing a row if theres nothing to report!
      if activity_amount > 0
        classifications = activity.send(@classification_association)

        base_row << activity.organization.name
        base_row << activity.project.try(:name) # other costs does not have a project
        base_row << project_in_flows(activity.project)
        base_row << activity.data_response.id
        base_row << activity.id
        base_row << activity.name
        base_row << activity_amount
        # TODO: remove try after implementer_splits without implementer are fixed
        base_row << implementer_split.organization.try(:name)
        base_row << split_amount

        # iterate here over classifications
        classifications.each do |classification|
          percentage = classification.percentage || 0
          row = base_row.dup

          row << classification.code.short_display
          row << percentage
          row << percentage * split_amount / 100
          row << implementer_split.possible_double_count?
          row << implementer_split.double_count?
          codes = classification.code ?
            cached_self_and_ancestors(classification.code) : []
          add_codes_to_row(row, codes.reverse, @code_deepest_nesting, :short_display)

          csv << row
        end
      end
    end

    def classification_association(amount_type, classification_type)
      if amount_type == :budget
        case classification_type
        when :purpose
          :leaf_budget_purposes
        when :input
          :leaf_budget_inputs
        when :location
          :budget_locations
        else
          raise "Invalid classification type #{classification_type}".to_yaml
        end
      elsif amount_type == :spend
        case classification_type
        when :purpose
          :leaf_spend_purposes
        when :input
          :leaf_spend_inputs
        when :location
          :spend_locations
        else
          raise "Invalid classification type #{classification_type}".to_yaml
        end
      else
        raise "Invalid amount type #{amount_type}".to_yaml
      end
    end

    def cached_self_and_ancestors(code)
      codes = []
      codes << code

      while code.parent_id.present?
        code = codes_cache[code.parent_id]
        codes << code
      end

      codes
    end

    def add_codes_to_row(row, codes, deepest_nesting, attr)
      deepest_nesting.times do |i|
        code = codes[i]
        if code
          row << codes_cache[code.id].try(attr)
        else
          row << nil
        end
      end
    end
end
