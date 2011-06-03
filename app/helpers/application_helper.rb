# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include NumberHelper # gives n2c method available
  include CurrencyHelper

  # include these again so that each module using this module doesnt need to
  include ERB::Util
  include ActionView::Helpers::TextHelper

  # Adds title on page
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Adds javascripts to head
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  # Adds stylesheets to head
  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

  # Adds keywords to page
  def keywords(page_keywords)
    content_for(:keywords) { page_keywords }
  end

  # Adds description to page
  def description(page_description)
    content_for(:description) { page_description }
  end

  # Creates unique id for HTML document body used for unobtrusive javascript selectors
  def get_controller_id(controller)
    parts = controller.controller_path.split('/')
    parts << controller.action_name
    parts.join('_')
  end

  # Generates proper dashboard url link depending on the type of user
  def user_dashboard_path(current_user)
    if current_user
      if current_user.admin?
        admin_dashboard_path
      elsif current_user.reporter?
        reporter_dashboard_path
      elsif current_user.activity_manager?
        reporter_dashboard_path
      else
        raise 'user role not found'
      end
    end
  end

  # Generates proper dashboard url link depending on the type of user
  def user_report_dashboard_path(current_user)
    if current_user
      if current_user.admin?
        admin_reports_path
      elsif current_user.reporter?
        reporter_reports_path
      else
        reporter_reports_path
      end
    end
  end

  # need to ensure we dont activate a different 'root' tab when we are on a
  # nested controller of the same name
  # Eg. Dashboard | Activities | Districts
  # where Districts has a nested-controller also called 'Activities'
  def build_admin_nav_tab(tab)
    parent = 'admin'
    active =  current_controller_with_nesting?(parent, tab)
    unless active
      if tab == 'reports'
        active = current_controller_with_nesting?('reports', 'districts') ||
                 current_controller_with_nesting?('districts', 'activities') ||
                 current_controller_with_nesting?('districts', 'organizations') ||
                 current_controller_with_nesting?('reports', 'countries') ||
                 current_controller_with_nesting?('countries', 'activities') ||
                 current_controller_with_nesting?('countries', 'organizations') ||
                 current_controller_with_nesting?('admin', 'responses')
      end
    end
    return link_to tab.humanize, { :controller => "/#{parent}/#{tab}" }, :class => ('active' if active)
  end

  # alternative to rails' current_page?() method
  # which doesnt allow you to have extra params in the URI after the
  # controller name.
  def current_controller?(controller_name)
    current = request.path_parameters[:controller].split('/').last
    controller_name == current
  end

  # check the request matches the form 'parent/controller'
  def current_controller_with_nesting?(parent_name, controller_name)
    path = request.path_parameters[:controller].split('/')
    controller_name == path[1] && parent_name == path[0]
  end

  def friendly_name(object, truncate_length = 45)
    return "n/a" unless object
    name = object.name.blank? ? object.description : object.name
    return "n/a" if name.blank?
    return truncate(name.titleize, :length => truncate_length)
  end

  # appends a .active class
  def active_if(action_name)
    active = false
    current = controller.action_name.to_sym
    if action_name.is_a?(Array)
      active = true if action_name.include?(current)
    elsif (action_name.class == TrueClass || action_name.class == FalseClass)
      active = action_name
    else
      active = true if action_name == current
    end
    { :class => ('active' if active) }
  end

  # Gifted from will_paginate
  def short_page_entries_info(collection, options = {})
    entry_name = options[:entry_name] ||
      (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))

    if collection.total_pages < 2
      case collection.size
      when 0; "0"
      when 1; "<b>1</b> #{entry_name}"
      else;   "<b>all #{collection.size}</b> #{entry_name.pluralize}"
      end
    else
      %{<b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b>} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
  end

  # returns a javascript friendly definition of a ruby variable, even if the var is nil
  def js_safe(var)
    var.nil? ? "undefined" : var
  end

  def usd_to_local_currency
    Money.default_bank.get_rate(:USD, Money.default_currency)
  end

  # sortable columns
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction, :query => params[:query]}, {:class => css_class}
  end


  # Helper for adding remove link to nested form models
  def link_to_remove_fields(name, f, options = {})
    class_name = options[:class] || 'remove_nested'
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class => class_name)
  end

  # Helper for adding new nested form models
  def link_to_add_fields(name, f, association, subfolder, options = {})
    class_name = options[:class] || 'add_nested'
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(subfolder + association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"), :class => class_name)
  end

  def b(bool)
    bool ? 'yes' : 'no'
  end

  def c(amount, currency)
    if amount.present?
      "#{amount} <span class='currency'>#{currency}</span>"
    else
      "0.00 <span class='currency'>#{currency}</span>"
    end
  end

  def help_link(query = nil)
    link = "kb" #default to hte knowledge base
    link = "search?t=f&q=#{query}" if query
    return "http://hrtapp.tenderapp.com/#{link}"
  end

  def contact_link
    "http://hrtapp.tenderapp.com/discussions"
  end

  # given a project or activity, render a nice name from either
  # the name() or description()
  def nice_name(object, length=16)
    descr = '(no name)'
    unless object.nil?
      descr = object.description unless object.description.blank?
      descr = object.name unless object.name.blank?
    end
    truncate(descr, :length => length)
  end

  def coding_progress_style(progress)
    style = ''
    style = "background: #ccff00" if progress < 90
    style = "background: #ffd800" if progress < 80
    style = "background: #ff9c00" if progress < 70
    style = "background: #ff6c00" if progress < 50
    style = "background: red" if progress < 30
    style = style + "; width: #{progress}%"
  end

  def form_namespace(object)
    "f#{object.object_id}"
  end

  def budget_fiscal_year_prev(data_response)
    if data_response.fiscal_year_start_date.present?
      year = data_response.fiscal_year_start_date.year
      year1 = year.pred.to_s.split('')[-2..-1].join
      year2 = year.to_s.split('')[-2..-1].join
    else
      year1 = 'xx'
      year2 = 'xx'
    end

    "#{year1}-#{year2}"
  end

  def budget_fiscal_year(data_response)
    if data_response.fiscal_year_start_date.present?
      year = data_response.fiscal_year_start_date.year
      year1 = year.to_s.split('')[-2..-1].join
      year2 = year.next.to_s.split('')[-2..-1].join
    else
      year1 = 'xx'
      year2 = 'xx'
    end

    "#{year1}-#{year2}"
  end

  def spend_fiscal_year_prev(data_response)
    if data_response.fiscal_year_start_date.present?
      year = data_response.fiscal_year_start_date.year
      year1 = year.pred.pred.to_s.split('')[-2..-1].join
      year2 = year.pred.to_s.split('')[-2..-1].join
    else
      year1 = 'xx'
      year2 = 'xx'
    end

    "#{year1}-#{year2}"
  end

  def spend_fiscal_year(data_response)
    budget_fiscal_year_prev(data_response)
  end

  def fiscal_year(data_response)
    if data_response.fiscal_year_end_date.present?
      year1 = data_response.fiscal_year_end_date.strftime('%y')
      year2 = (data_response.fiscal_year_end_date + 1.year).strftime('%y')
    else
      year1 = 'xx'
      year2 = 'xx'
    end

    "#{year1}-#{year2}"
  end

  def funding_organizations_select
    orgs = Organization.find(:all, :order => 'old_type, name')
    orgs.map{|o| [o.display_name(100), o.id]}
  end

  def is_number?(i)
    true if Float(i) rescue false
  end

end
