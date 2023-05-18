# frozen_string_literal: true

module ApplicationHelper
  include ::HyraxHelper
  include Hyrax::OverrideHelperBehavior
  include GroupNavigationHelper
  include SharedSearchHelper

  def label_for(term:, record_class: nil)
    locale_for(type: 'labels', term: term, record_class: record_class)
  end

  def hint_for(term:, record_class: nil)
    hint = locale_for(type: 'hints', term: term, record_class: record_class)

    return hint unless missing_translation(hint)
  end

  def locale_for(type:, term:, record_class:)
    @term              = term.to_s
    @record_class      = record_class.to_s.downcase
    work_or_collection = @record_class == 'collection' ? 'collection' : 'defaults'
    default_locale     = t("simple_form.#{type}.#{work_or_collection}.#{@term}").html_safe
    locale             = t("hyrax.#{@record_class}.#{type}.#{@term}").html_safe

    return default_locale if missing_translation(locale)

    locale
  end

  def missing_translation(value)
    value.include?('translation missing')
  end

  def markdown(text)
    options = %i[
      hard_wrap autolink no_intra_emphasis tables fenced_code_blocks
      disable_indented_code_blocks strikethrough lax_spacing space_after_headers
      quote footnotes highlight underline
    ]
    Markdown.new(text, *options).to_html.html_safe
  end
end
