module PrependFileBasedAuthority

  # override all method to retrieve alt labels
  def all
    terms.map do |res|
      { id: res[:id], label: res[:term], active: res.fetch(:active, true), alt_labels: res.fetch(:alts, []) }.with_indifferent_access
    end
  end
end
