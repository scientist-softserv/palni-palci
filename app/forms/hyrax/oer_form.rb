# Generated via
#  `rails generate hyrax:work Oer`
module Hyrax
  # Generated form for Oer
  class OerForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Oer
    include HydraEditor::Form::Permissions

    self.terms += %i[resource_type rendering_ids alternative_title date table_of_contents
      additional_information rights_holder oer_size accessibility_feature accessibility_hazard
      accessibility_summary audience education_level learning_resource_type discipline
      newer_version_id previous_version_id alternate_version_id]
    self.terms -=%i[keyword based_near related_url source date_created previous_version_id newer_version_id alternate_version_id]
    self.required_fields += %i[resource_type date audience education_level learning_resource_type discipline]

    delegate :related_members_attributes=, :previous_version, :newer_version, :alternate_version, to: :model

    def secondary_terms
      super - [:rendering_ids]
    end

    def self.build_permitted_params
      super + [
        {
          related_members_attributes: [:id, :_destroy, :relationship]
        }
      ]
    end

    def previous_version_json
      previous_version.map do |child|
        {
          id: child.id,
          label: child.to_s,
          path: @controller.url_for(child),
          relationship: "previous-version"
        }
      end.to_json
    end

    def newer_version_json
      newer_version.map do |child|
        {
          id: child.id,
          label: child.to_s,
          path: @controller.url_for(child),
          relationship: "newer-version"
        }
      end.to_json
    end

    def alternate_version_json
      alternate_version.map do |child|
        {
          id: child.id,
          label: child.to_s,
          path: @controller.url_for(child),
          relationship: "alternate-version"
        }
      end.to_json
    end
  end
end
