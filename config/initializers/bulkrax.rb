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
      'abstract' => { from: ['abstract'], split: /\s*[|]\s*/ },
      'access_right' => { from: ['access_rights'], split: /\s*[;|]\s*/ },
      'additional_rights_info' => { from: ['additional_rights_info'], split: /\s*[;|]\s*/ },
      'advisor' => { from: ['advisor'], split: /\s*[;|]\s*/ },
      'alternative_title' => { from: ['alternative_title'], split: /\s*[;|]\s*/ },
      'bibliographic_citation' => { from: ['bibliographic_citation'], split: /\s*[;|]\s*/ },
      'children' => { from: ['children'], related_children_field_mapping: true },
      'committee_member' => { from: ['committee_member'], split: /\s*[;|]\s*/ },
      'contributor_institutional_relationship' => { from: ['contributor_institutional_relationship'] },
      'contributor_orcid' => { from: ['contributor_orcid'] },
      'contributor_role' => { from: ['contributor_role'], split: /\s*[;|]\s*/ },
      'contributor' => { from: ['contributor'], split: ';' },
      'creator_institutional_relationship' => { from: ['creator_institutional_relationship'], split: /\s*[;|]\s*/ },
      'creator_orcid' => { from: ['creator_orcid'] },
      'creator' => { from: ['creator'], split: /\s*[;|]\s*/ },
      'date_created' => { from: ['date_created'] },
      'degree_granting_institution' => { from: ['degree_granting_institution'], split: /\s*[;|]\s*/ },
      'degree' => { from: ['degree'], split: /\s*[;|]\s*/ },
      'department' => { from: ['department'], split: /\s*[;|]\s*/ },
      'description' => { from: ['description'], split: /\s*[|]\s*/ },
      'discipline' => { from: ['discipline'], split: /\s*[;|]\s*/ },
      'event_date' => { from: ['event_date'], split: /\s*[;|]\s*/ },
      'event_location' => { from: ['event_location'], split: /\s*[;|]\s*/ },
      'event_title' => { from: ['event_title'], split: /\s*[;|]\s*/ },
      'extent' => { from: ['extent'] },
      'format' => { from: ['format'], split: /\s*[;|]\s*/ },
      'funder_awards' => { from: ['funder_awards'], split: /\s*[;|]\s*/ },
      'funder_name' => { from: ['funder_name'], split: /\s*[;|]\s*/ },
      'identifier' => { from: ['identifier'] },
      'institution' => { from: ['institution'] },
      'keyword' => { from: ['keyword'], split: /\s*[;|]\s*/ },
      'label' => { from: ['label'] },
      'language' => { from: ['language'], split: /\s*[;|]\s*/ },
      # 'level' => { from: ['level'] },
      'license' => { from: ['license'] },
      'location' => { from: ['location'], split: /\s*[;|]\s*/ },
      'official_link' => { from: ['official_link'], split: /\s*[;|]\s*/ },
      'parents' => { from: ['parents'], related_parents_field_mapping: true },
      'project_name' => { from: ['project_name'], split: /\s*[;|]\s*/ },
      'publisher' => { from: ['publisher'], split: /\s*[;|]\s*/ },
      'related_url' => { from: ['related_url'], split: /\s*[;|]\s*/ },
      'resource_type' => { from: ['resource_type'] },
      'rights_holder' => { from: ['rights_holder'], split: /\s*[;|]\s*/ },
      'rights_notes' => { from: ['rights_notes'], split: /\s*[;|]\s*/ },
      'rights_statement' => { from: ['rights_statement'] },
      'source_identifier' => { from: ['source_identifier'], source_identifier: true },
      'source' => { from: ['source'], split: /\s*[;|]\s*/ },
      'subject' => { from: ['subject'], split: /\s*[;|]\s*/ },
      'title' => { from: ['title'] },
      'types' => { from: ['types'], split: /\s*[;|]\s*/ },
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
