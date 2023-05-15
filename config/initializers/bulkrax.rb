# frozen_string_literal: true

if ENV.fetch('HYKU_BULKRAX_ENABLED', 'true') == 'true'
  Bulkrax.setup do |config|
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
      'abstract' => { from: ['abstract'] },
      'access_right' => { from: ['access_rights'] },
      'additional_rights_info' => { from: ['additional_rights_info'] },
      'advisor' => { from: ['advisor'] },
      'alternative_title' => { from: ['alternative_title'] },
      'bibliographic_citation' => { from: ['bibliographic_citation'] },
      'children' => { from: ['children'], related_children_field_mapping: true },
      'committee_member' => { from: ['committee_member'] },
      'contributor_institutional_relationship' => { from: ['contributor_institutional_relationship'] },
      'contributor_orcid' => { from: ['contributor_orcid'] },
      'contributor_role' => { from: ['contributor_role'] },
      'contributor' => { from: ['contributor'] },
      'creator_institutional_relationship' => { from: ['creator_institutional_relationship'] },
      'creator_orcid' => { from: ['creator_orcid'] },
      'creator' => { from: ['creator'] },
      'date_created' => { from: ['date_created'] },
      'degree_granting_institution' => { from: ['degree_granting_institution'] },
      'degree' => { from: ['degree'] },
      'department' => { from: ['department'] },
      'description' => { from: ['description'] },
      'discipline' => { from: ['discipline'] },
      'event_date' => { from: ['event_date'] },
      'event_location' => { from: ['event_location'] },
      'event_title' => { from: ['event_title'] },
      'extent' => { from: ['extent'] },
      'format' => { from: ['format'] },
      'funder_awards' => { from: ['funder_awards'] },
      'funder_name' => { from: ['funder_name'] },
      'identifier' => { from: ['identifier'] },
      'institution' => { from: ['institution'] },
      'keyword' => { from: ['keyword'] },
      'label' => { from: ['label'] },
      'language' => { from: ['language'] },
      'level' => { from: ['level'] },
      'license' => { from: ['license'] },
      'official_link' => { from: ['official_link'] },
      'parents' => { from: ['parents'], related_parents_field_mapping: true },
      'project_name' => { from: ['project_name'] },
      'publisher' => { from: ['publisher'] },
      'related_url' => { from: ['related_url'] },
      'resource_type' => { from: ['resource_type'] },
      'rights_holder' => { from: ['rights_holder'] },
      'rights_notes' => { from: ['rights_notes'] },
      'rights_statement' => { from: ['rights_statement'] },
      'source_identifier' => { from: ['source_identifier'], source_identifier: true },
      'source' => { from: ['source'] },
      'subject' => { from: ['subject'] },
      'title' => { from: ['title'] },
      'types' => { from: ['types'] },
      'video_embed' => { from: ['video_embed'] },
      'year' => { from: ['year'] },
    }

    config.field_mappings["Bulkrax::BagitParser"] = default_field_mapping.merge({
      # add or remove custom mappings for this parser here
    })

    config.field_mappings["Bulkrax::CsvParser"] = default_field_mapping.merge({
      # add or remove custom mappings for this parser here
    })

    config.field_mappings["Bulkrax::OaiDcParser"] = default_field_mapping.merge({
      # add or remove custom mappings for this parser here
    })

    config.field_mappings["Bulkrax::OaiQualifiedDcParser"] = default_field_mapping.merge({
      # add or remove custom mappings for this parser here
    })

    config.field_mappings["Bulkrax::XmlParser"] = default_field_mapping.merge({
      # add or remove custom mappings for this parser here
    })

    config.default_work_type = 'GenericWork'

    # To duplicate a set of mappings from one parser to another
    #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
    #   config.field_mappings["Bulkrax::OaiDcParser"].each {|key,value| config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value }

    # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
    # config.reserved_properties += ['my_field']

    # List of Questioning Authority properties that are controlled via YAML files in
    # the config/authorities/ directory. For example, the :rights_statement property
    # is controlled by the active terms in config/authorities/rights_statements.yml
    # Default properties: 'rights_statement' and 'license'
    config.qa_controlled_properties += ['types', 'resource_type', 'format', 'institution']
  end

  Bulkrax::CreateRelationshipsJob.update_child_records_works_file_sets = true
end
