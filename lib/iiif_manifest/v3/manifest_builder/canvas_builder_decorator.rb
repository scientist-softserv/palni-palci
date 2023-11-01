# frozen_string_literal: true

# OVERRIDE IIIFManifest v1.3.1 to use the parent's title as the label instead of the filename

module IIIFManifest
  module V3
    module ManifestBuilderDecorator
      module CanvasBuilderDecorator
        def apply_record_properties
          super
          canvas.label = if record.to_s.present?
                           ManifestBuilder.language_map(record['parent_title_tesim']&.first || record.to_s)
                         end
        end
      end
    end
  end
end

IIIFManifest::V3::ManifestBuilder.prepend(IIIFManifest::V3::ManifestBuilderDecorator)
IIIFManifest::V3::ManifestBuilder::CanvasBuilder.prepend(IIIFManifest::V3::ManifestBuilder::CanvasBuilderDecorator)
