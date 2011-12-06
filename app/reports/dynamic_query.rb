require 'fastercsv'

class Reports::DynamicQuery
  include Reports::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  def initialize(request, amount_type)
    @deepest_nesting = Code.deepest_nesting
    @amount_type = amount_type
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => :data_response },
      :order => "implementer_splits.id ASC",
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [
        { :activity => [
            :targets,
            { "leaf_#{@amount_type}_purposes".to_sym => :code },
            { "leaf_#{@amount_type}_inputs".to_sym => :code },
            { "coding_#{@amount_type}_district".to_sym => :code },
            { :project => { :in_flows => :from } },
            { :data_response => :organization }
          ]},
        { :organization => :data_responses } ]


  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @implementer_splits.each do |implementer_split|
        amount = implementer_split.activity.send(@amount_type)
        build_rows(csv, implementer_split) if amount && amount > 0
      end
    end
  end

  private
    def build_header
      row = []

      row << "Financing Agent"
      row << 'Organization'
      row << 'Implementing Agent'
      row << 'Description of Activity'
      row << 'Targets'
      row << 'Cost Category Split Total %'
      row << 'Cost Category Split %'
      row << 'Cost Category'
      row << 'Purpose Split Total %'
      row << 'Purpose Split %'
      row << 'Purpose'
      @deepest_nesting.times { |index| row << "Purpose #{index + 1} (short display)" }
      @deepest_nesting.times { |index| row << "Purpose #{index + 1} (official name)" }
      row << 'HSSP2 Strategic Objectives (post JHSR)'
      row << 'HSSP2 Strategic Programs (post JHSR)'
      row << 'Associated MTEF Sub Program'
      row << 'NSP Outputs'
      row << 'Location Split Total %'
      row << 'Location Split %'
      row << 'Name of District'
      row << 'Total Amount ($)'
      row << 'Actual Double Count'
      row << 'Implementer Split ID'
      row
    end

    def build_rows(csv, implementer_split)
      activity = implementer_split.activity
      @currency = activity.project_id.nil? ? activity.organization.currency : activity.currency

      build_fake_classifications(activity)
      build_fake_project_and_in_flow(activity)

      in_flows_total = activity.project.in_flows.inject(0) { |sum, e| sum + (e.send(@amount_type) || 0) }

      in_flows = in_flows_total == 0 ? loop_act = [fake_inflow(@currency)] : activity.project.in_flows

      # activity.project.in_flows.each do |in_flow|
      in_flows.each do |in_flow|
        !in_flow.send(@amount_type).nil? && in_flow.send(@amount_type) > 0
      end.each do |in_flow|
        populate_row(csv, implementer_split, in_flow, in_flows_total)
      end
    end

    def populate_row(csv, implementer_split, in_flow, in_flows_total)
      activity      = implementer_split.activity
      in_flow_ratio = get_ratio(in_flow.send(@amount_type), in_flows_total)

      base_row = []
      base_row << in_flow.from.try(:name)
      base_row << activity.organization.name
      base_row << implementer_split.organization.name
      base_row << activity.description
      base_row << activity.targets.map(&:description).join(' | ')

      fake_input = is_fake?(activity.send("leaf_#{@amount_type}_inputs").first.code)
      build_incomplete_classificiation(activity, "leaf_#{@amount_type}_inputs")
      base_row << funder_ratio(activity.send("leaf_#{@amount_type}_inputs"), in_flow_ratio, fake_input)

      activity.send("leaf_#{@amount_type}_inputs").each do |input_classification|
        input_row = base_row.dup
        fake_purpose = is_fake?(activity.send("leaf_#{@amount_type}_purposes").first.code)

        input_row << ( fake_input ? 'N/A' : input_classification.percentage )
        input_row << input_classification.code.short_display
        build_incomplete_classificiation(activity, "leaf_#{@amount_type}_purposes")
        input_row << funder_ratio(activity.send("leaf_#{@amount_type}_purposes"), in_flow_ratio, fake_purpose)

        activity.send("leaf_#{@amount_type}_purposes").each do |purpose_classification|
          purpose_row = input_row.dup

          purpose_row << ( fake_purpose ? 'N/A' : purpose_classification.percentage.to_f.round_with_precision(2) )

          purpose_row << purpose_classification.code.short_display

          # purpose tree
          codes = self_and_ancestors(purpose_classification.code).reverse
          add_codes_to_row(purpose_row, codes, @deepest_nesting, :short_display)
          add_codes_to_row(purpose_row, codes, @deepest_nesting, :official_name)


          purpose_row << purpose_classification.code.hssp2_stratobj_val
          purpose_row << purpose_classification.code.hssp2_stratprog_val
          purpose_row << mtef_name(purpose_classification.code)
          purpose_row << nsp_name(purpose_classification.code)

          fake_district = is_fake?(activity.send("coding_#{@amount_type}_district").first.code)
          build_incomplete_classificiation(activity, "coding_#{@amount_type}_district")
          purpose_row << funder_ratio(activity.send("coding_#{@amount_type}_district"), in_flow_ratio, fake_district)

          activity.send("coding_#{@amount_type}_district").each do |district_classification|
            district_row = purpose_row.dup
            district_row << ( fake_district ? 'N/A' : district_classification.percentage.to_f.round_with_precision(2) )
            district_row << district_classification.code.short_display
            district_row << n2c(in_flow_ratio *
              ( universal_currency_converter(implementer_split.send(@amount_type),
                  @currency, 'USD') || 0 ) *
              ( (input_classification.percentage || 0) / 100 ) *
              ( (purpose_classification.percentage || 0) /100 ) *
              ( (district_classification.percentage || 0) / 100))
            district_row << implementer_split.double_count?
            district_row << implementer_split.id
            csv << district_row
          end
        end
      end
    end

    def self_and_ancestors(code)
      codes = [code]

      while code.parent_id.present?
        code = codes_cache[code.parent_id]
        codes << code
      end

      return codes
    end

    def mtef_name(code)
      codes = self_and_ancestors(code)

      mtef = codes.detect { |a| a.type == "Mtef" && !a.root? }
      mtef ? mtef.short_display : 'N/A'
    end

    def nsp_name(code)
      codes = self_and_ancestors(code)

      nsp = codes.detect { |a| a.type == "Nsp" }
      nsp ? nsp.short_display : 'N/A'
    end

    def build_fake_classifications(activity)
      ["coding_#{@amount_type}_district", "leaf_#{@amount_type}_purposes",
       "leaf_#{@amount_type}_inputs"].each do |method|
        if activity.send(method).length == 0
          activity.send(method).build(:percentage => 100, :code => fake_code)
        end
      end
    end

    def build_incomplete_classificiation(activity, method)
      classifications = activity.send(method)
      classifications.build(:percentage => incomplete_percentage(classifications),
        :code => fake_code("Not Classified")) unless fully_classified?(classifications)
    end

    def incomplete_percentage(classifications)
      100 - calculate_total_percent(classifications)
    end

    def build_fake_project_and_in_flow(activity)
      if activity.project.blank?
        activity.project = fake_project
      end

      if activity.project.in_flows.blank?
        activity.project.in_flows = [fake_inflow(activity.currency)]
      end
    end

    def fake_inflow(currency)
      @fake_inflow || FundingFlow.new(:from => fake_org(currency),
                                      :spend => 1, :budget => 1)
    end

    def fake_project
      @fake_project ||= Project.new(:name => 'N/A', :currency => "USD")
    end

    def fake_org(currency)
      @fake_org ||= Organization.new(:name => 'N/A', :currency => currency)
    end

    def fake_code(value = "N/A")
      @fake_code ||= Code.new(:short_display => value, :hssp2_stratprog_val => value,
                              :hssp2_stratobj_val => value)
    end

    def get_ratio(amount, total)
      return 0 if amount.nil?
      total && total > 0 ? amount / total : 1
    end

    def funder_ratio(classifications, in_flow_ratio, fake)
      return 'N/A' if fake
      (calculate_total_percent(classifications) * in_flow_ratio).
        to_f.round_with_precision(2)
    end

    def fully_classified?(classifications)
      return true if (calculate_total_percent(classifications) - 100).abs <= 0.5
    end

    def calculate_total_percent(classifications)
      classifications.inject(0) { |sum, p| sum + (p.percentage || 0) }
    end

    def is_fake?(in_flow)
      in_flow.id.blank?
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
