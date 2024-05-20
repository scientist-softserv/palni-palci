# frozen_string_literal: true

module Wings
  # OVERRIDE Hyrax v3.6.0 to backport a bug fix from v5.0.1.
  # This override is no longer needed when Hyrax's version is >= v5.0.1
  #
  # Work forms were throwing 504 time out errors because large AdminSets
  # being queried by Hyrax#query_service were loading all of their members.
  #
  # @see https://github.com/samvera/hyrax/commit/75312ee
  module AttributeTransformerDecorator
    # OVERRIDE: Replace contents of this method with the version found in v5.0.1
    def run(obj)
      attrs = obj.reflections.each_with_object({}) do |(key, reflection), mem|
        case reflection
        when ActiveFedora::Reflection::HasManyReflection,
             ActiveFedora::Reflection::HasAndBelongsToManyReflection,
             ActiveFedora::Reflection::IndirectlyContainsReflection
          mem[:"#{key.to_s.singularize}_ids"] =
            obj.association(key).ids_reader
        when ActiveFedora::Reflection::DirectlyContainsReflection
          mem[:"#{key.to_s.singularize}_ids"] =
            Array(obj.public_send(reflection.name)).map(&:id)
        when ActiveFedora::Reflection::FilterReflection,
             ActiveFedora::Reflection::OrdersReflection,
             ActiveFedora::Reflection::HasSubresourceReflection,
             ActiveFedora::Reflection::BelongsToReflection,
             ActiveFedora::Reflection::BasicContainsReflection
          :noop
        when ActiveFedora::Reflection::DirectlyContainsOneReflection
          mem[:"#{key.to_s.singularize}_id"] =
            obj.public_send(reflection.name)&.id
        else
          mem[reflection.foreign_key.to_sym] =
            obj.public_send(reflection.foreign_key.to_sym)
        end
      end

      obj.class.delegated_attributes.keys.each_with_object(attrs) do |attr_name, mem|
        next unless obj.respond_to?(attr_name) && !mem.key?(attr_name.to_sym)
        mem[attr_name.to_sym] = TransformerValueMapper.for(obj.public_send(attr_name)).result
      end
    end
  end
end

Wings::AttributeTransformer.singleton_class.send(:prepend, Wings::AttributeTransformerDecorator)
