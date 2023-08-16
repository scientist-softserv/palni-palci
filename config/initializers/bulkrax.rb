# frozen_string_literal: true

if ENV.fetch('HYKU_BULKRAX_ENABLED', 'true') == 'true'
  Bulkrax.setup do |config| # rubocop:disable Metrics/BlockLength
    # Add local parsers
    # config.parsers += [
    #   { name: 'MODS - My Local MODS parser', class_name: 'Bulkrax::ModsXmlParser', partial: 'mods_fields' },
    # ]

    # WorkType to use as the default if none is specified in the import
    # Default is the first returned by Hyrax.config.curation_concerns
    # config.default_work_type = MyWork

    # Path to store pending imports
    # config.import_path = 'tmp/imports'

    # Path to store exports before download
    # config.export_path = 'tmp/exports'

    # Server name for oai request header
    # config.server_name = 'my_server@name.com'

    # Field_mapping for establishing a parent-child relationship (FROM parent TO child)
    # This can be a Collection to Work, or Work to Work relationship
    # This value IS NOT used for OAI, so setting the OAI Entries here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # Example:
    #   {
    #     'Bulkrax::RdfEntry'  => 'http://opaquenamespace.org/ns/contents',
    #     'Bulkrax::CsvEntry'  => 'children'
    #   }
    # By default no parent-child relationships are added
    # config.parent_child_field_mapping = { }

    # Field_mapping for establishing a collection relationship (FROM work TO collection)
    # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # The default value for CSV is collection
    # Add/replace parsers, for example:
    # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

    # Field mappings
    # Create a completely new set of mappings by replacing the whole set as follows
    #   config.field_mappings = {
    #     "Bulkrax::OaiDcParser" => { **individual field mappings go here*** }
    #   }

    # Add to, or change existing mappings as follows
    #   e.g. to exclude date
    #   config.field_mappings["Bulkrax::OaiDcParser"]["date"] = { from: ["date"], excluded: true  }

    default_field_mapping = {
      'abstract' => { from: ['abstract'], split: ';' },
      'access_right' => { from: ['access_rights'], split: ';' },
      'additional_rights_info' => { from: ['additional_rights_info'], split: ';' },
      'advisor' => { from: ['advisor'], split: ';' },
      'alternative_title' => { from: ['alternative_title'], split: ';' },
      'bibliographic_citation' => { from: ['bibliographic_citation'], split: ';' },
      'children' => { from: ['children'], related_children_field_mapping: true },
      'committee_member' => { from: ['committee_member'], split: ';' },
      'contributor_institutional_relationship' => { from: ['contributor_institutional_relationship'] },
      'contributor_orcid' => { from: ['contributor_orcid'] },
      'contributor_role' => { from: ['contributor_role'], split: ';' },
      'contributor' => { from: ['contributor'], split: ';' },
      'creator_institutional_relationship' => { from: ['creator_institutional_relationship'], split: ';' },
      'creator_orcid' => { from: ['creator_orcid'] },
      'creator' => { from: ['creator'], split: ';' },
      'date_created' => { from: ['date_created'] },
      'degree_granting_institution' => { from: ['degree_granting_institution'], split: ';' },
      'degree' => { from: ['degree'], split: ';' },
      'department' => { from: ['department'], split: ';' },
      'description' => { from: ['description'], split: ';' },
      'discipline' => { from: ['discipline'], split: ';' },
      'event_date' => { from: ['event_date'], split: ';' },
      'event_location' => { from: ['event_location'], split: ';' },
      'event_title' => { from: ['event_title'], split: ';' },
      'extent' => { from: ['extent'] },
      'format' => { from: ['format'], split: ';' },
      'funder_awards' => { from: ['funder_awards'], split: ';' },
      'funder_name' => { from: ['funder_name'], split: ';' },
      'identifier' => { from: ['identifier'] },
      'institution' => { from: ['institution'] },
      'keyword' => { from: ['keyword'], split: ';' },
      'label' => { from: ['label'] },
      'language' => { from: ['language'], split: ';' },
      # 'level' => { from: ['level'] },
      'license' => { from: ['license'] },
      'official_link' => { from: ['official_link'], split: ';' },
      'parents' => { from: ['parents'], related_parents_field_mapping: true },
      'project_name' => { from: ['project_name'], split: ';' },
      'publisher' => { from: ['publisher'], split: ';' },
      'related_url' => { from: ['related_url'], split: ';' },
      'resource_type' => { from: ['resource_type'] },
      'rights_holder' => { from: ['rights_holder'], split: ';' },
      'rights_notes' => { from: ['rights_notes'], split: ';' },
      'rights_statement' => { from: ['rights_statement'] },
      'source_identifier' => { from: ['source_identifier'], source_identifier: true },
      'source' => { from: ['source'], split: ';' },
      'subject' => { from: ['subject'], split: ';' },
      'title' => { from: ['title'] },
      'types' => { from: ['types'], split: ';' },
      'video_embed' => { from: ['video_embed'] },
      'work_url' => { from: ['work_url'] },
      'year' => { from: ['year'] }
    }

    # add or remove custom mappings for this parser here
    config.field_mappings["Bulkrax::BagitParser"] = default_field_mapping.merge({})
    config.field_mappings["Bulkrax::CsvParser"] = default_field_mapping.merge({})
    config.field_mappings["Bulkrax::OaiDcParser"] = default_field_mapping.merge({})
    config.field_mappings["Bulkrax::OaiQualifiedDcParser"] = default_field_mapping.merge({})
    config.field_mappings["Bulkrax::XmlParser"] = default_field_mapping.merge({})

    config.default_work_type = 'GenericWork'

    # Should Bulkrax make up source identifiers for you? This allow round tripping
    # and download errored entries to still work, but does mean if you upload the
    # same source record in two different files you WILL get duplicates.
    # It is given two aruguments, self at the time of call and the index of the reocrd
    #    config.fill_in_blank_source_identifiers = ->(parser, index) { "b-#{parser.importer.id}-#{index}"}
    # or use a uuid
    config.fill_in_blank_source_identifiers = ->(_parser, _index) { SecureRandom.uuid }

    # To duplicate a set of mappings from one parser to another
    #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
    #   config.field_mappings["Bulkrax::OaiDcParser"].each { |key,value|
    #     config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value
    #   }

    # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
    # config.reserved_properties += ['my_field']

    # List of Questioning Authority properties that are controlled via YAML files in
    # the config/authorities/ directory. For example, the :rights_statement property
    # is controlled by the active terms in config/authorities/rights_statements.yml
    # Default properties: 'rights_statement' and 'license'
    config.qa_controlled_properties += ['types', 'resource_type', 'institution']
  end

  Bulkrax::CreateRelationshipsJob.update_child_records_works_file_sets = true
end
