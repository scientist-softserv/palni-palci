class NilSolrEndpoint
  def switch!
    ActiveFedora::SolrService.instance.conn = connection
    Blacklight.connection_config = connection_options
    Blacklight.default_index = nil
  end

  def ping
    false
  end

  private

    # Return an RSolr connection, that points at an invalid endpoint
    # Note: We could have returned a NilRSolrConnection here, but Blacklight
    # makes it's own RSolr connection, so we'd end up with an RSolr connection in
    # blacklight anyway.
    def connection
      RSolr.connect(connection_options)
    end

    # Return options that will never return a valid connection.
    def connection_options
      { url: 'http://127.0.0.1:99999/nil_solr_endpoint' }
    end
end
