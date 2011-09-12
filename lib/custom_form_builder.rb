class CustomFormBuilder < ActionView::Helpers::FormBuilder
  # NOTE: maybe this is possible to be defined as method
  # which will bring more flexibility in the markup
  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    if html_tag =~ /type="hidden"/ || html_tag =~ /<label/
      html_tag
    else
      error_tag = '<p class="input-errors">' +
                    [instance.error_message].join(', ') +
                  '</p>'
                  "<div class='input-box'>#{html_tag}#{error_tag}</div>"
    end
  end

  %w[text_field select collection_select password_field text_area].each do |method_name|
    define_method(method_name) do |field_name, *args|
      if args.present? && args[0][:hint].present?
        hint = @template.content_tag(:p, args[0][:hint], :class => 'input-hints')
      else
        hint = ""
      end

      @template.content_tag(:li, field_label(field_name, *args) +
                            super + hint, args[0][:wrapper_html])
    end
  end

  def check_box(field_name, *args)
    @template.content_tag(:p, super + " " + field_error(field_name) +
                          field_label(field_name, *args))
  end

  def submit(*args)
    @template.content_tag(:li, super, :class => 'commit')
  end

  def error_messages(*args)
    @template.render_error_messages(object, *args)
  end

  private

  def field_error(field_name)
    if object.errors.invalid? field_name
      @template.content_tag(:span,
          [object.errors.on(field_name)].flatten.first.sub(/^\^/, ''),
          :class => 'error_message')
    else
      ''
    end
  end

  def field_label(field_name, *args)
    options = args.extract_options!
    label_options = options[:label_html] || {}
    abbr = label_options[:required] ? '<abbr title="required">*</abbr>' : ''
    label("#{field_name}#{abbr}", "#{options[:label]}#{abbr}", label_options)
  end

  def objectify_options(options)
    super.except(:label, :required, :hint, :label_html, :wrapper_html)
  end
end
