# rubocop:disable Metrics/LineLength
module IiifPrint
  ##
  # This module encapsulates the logic for whether or not we'll use the IIIF Print services for the
  # current tenant/account.  The IIIF Print services does the following:
  #
  # - Skipping IIIF Print based derivative generation
  # - Skipping PDF Splitting
  # - Ignoring showing PDFs in the UV
  #
  # @note I am specifically isolating as much of this code into one module as possible, so that it
  #       it is hopefully easier to understand the configuration requirements and scope to this
  #       change.  At some point, this might make sense to bring into IIIF Print directly.
  #
  # @see https://github.com/scientist-softserv/palni-palci/issues/656 palni-palci#656
  # @see https://github.com/scientist-softserv/palni-palci/issues/657 palni-palci#657
  # @see https://github.com/scientist-softserv/palni-palci/issues/658 palni-palci#658
  # @see https://github.com/scientist-softserv/palni-palci/issues/659 palni-palci#659
  module TenantConfig
    ##
    # When we were not planning on calling the underlying IiifPrint service but did due to some kind
    # of faulty programming logic.
    #
    # @note This is raised as a guard to say "Hey, you thought you weren't using IIIF Print but your
    #       code's logic paths say otherwise."
    class LeakyAbstractionError < StandardError
      def initialize(klass:, method_name:)
        super("Called #{klass}##{method_name} when we had said that #{klass} was not valid because we weren't using IIIF Print")
      end
    end

    def self.use_iiif_print?
      ::Flipflop.use_iiif_print?
    end

    ##
    # This class implements the interface of the Hyrax::DerivativeService.  It is responsible for
    # negotiating whether or not the DerivativeService is "on" for the current tenant.
    #
    # @see https://github.com/samvera/hyrax/blob/08ef6c9a4fac489972eea9be53403e173f4ffb29/app/services/hyrax/derivative_service.rb Hyrax::DerivativeService
    class DerivativeService
      ##
      # This allows you to specify the IIIF derivative service to use when the tenant has chosen to
      # use IIIF Print for processing PDFs.
      #
      # If you are using the DerivativeRodeo, you'd specify something else.
      class_attribute :iiif_service_class, default: ::IiifPrint::PluggableDerivativeService

      def initialize(file_set)
        @file_set = file_set
      end

      delegate :use_iiif_print?, to: TenantConfig

      def valid?
        return false unless use_iiif_print?

        iiif_print_service_instance.valid?
      end

      %i[create_derivatives cleanup_derivatives].each do |method_name|
        define_method(method_name) do |*args|
          raise LeakyAbstractionError.new(klass: self.class, method_name: method_name) unless use_iiif_print?

          iiif_print_service_instance.public_send(method_name, *args)
        end
      end

      ##
      # @api private
      #
      # @note Public to ease testing.
      def iiif_print_service_instance
        @iiif_print_service_instance ||= iiif_service_class.new(@file_set)
      end
    end

    ##
    # This is the pdf_splitter_service that will be used.  If the tenant does not allow PDF splitting
    # we will return an empty array.
    #
    # @example
    #
    #  class MyWork
    #    include IiifPrint.model_configuration(
    #      pdf_split_child_model: Attachment,
    #      pdf_splitter_service: IiifPrint::TenantConfig::PdfSplitter,
    #      derivative_service_plugins: [ IiifPrint::TextExtractionDerivativeService ])
    #  end
    #
    # @see https://github.com/scientist-softserv/iiif_print/blob/9e7837ce4bd08bf8fff9126455d0e0e2602f6018/lib/iiif_print.rb#L86-L138 Documentation for configuring
    # @see https://github.com/scientist-softserv/adventist-dl/blob/d7676bdac2c672f09b28086d7145b68306978950/app/models/image.rb#L14-L20 Example implementation
    module PdfSplitter
      mattr_accessor :iiif_print_splitter
      self.iiif_print_splitter = ::IiifPrint::SplitPdfs::PagesToJpgsSplitter

      ##
      # @api public
      def self.call(*args)
        return [] unless TenantConfig.use_iiif_print?

        iiif_print_splitter.call(*args)
      end
    end

    ##
    # @see https://github.com/scientist-softserv/iiif_print/blob/9e7837ce4bd08bf8fff9126455d0e0e2602f6018/lib/iiif_print/split_pdfs/child_work_creation_from_pdf_service.rb#L10-L46 Interface of FileSetActor#service
    module SkipSplittingPdfService
      ##
      # @return [Symbol] Always :tenant_does_not_split_pdfs
      def self.conditionally_enqueue(*_args)
        :tenant_does_not_split_pdfs
      end
    end

    ##
    # This decorator should ensure that we don't call model configured :pdf_splitter_service as
    # documented in {TenantConfig::PdfSplitter} and the IIIF Print gem.  It avoids the potentially
    # expensive conditionally enqueue logic of the super class.
    #
    # Why not make an `app/actors/hyrax/actors/file_set_actor_decorator.rb`?  It would be lost in that
    # it is decorating the decoration of the IIIF Print gem.  Beside, in bringing this here, we have
    # a relatively singular place for all of the configurations.
    module FileSetActorDecorator
      ##
      # @see https://github.com/scientist-softserv/iiif_print/blob/9e7837ce4bd08bf8fff9126455d0e0e2602f6018/app/actors/iiif_print/actors/file_set_actor_decorator.rb#L33-L35 Method we're overriding
      def service
        return TenantConfig::SkipSplittingPdfService if TenantConfig.use_iiif_print?

        super
      end
    end
  end
end

# rubocop:enable Metrics/LineLength
