# frozen_string_literal: true

RSpec.shared_examples "generic_work_form" do
  describe ".primary_terms" do
    it 'does not include the license field' do
      expect(form.primary_terms).not_to include(:license)
    end

    it 'does not include the secondary_terms field' do
      expect(form.primary_terms).not_to include(:keyword)
      expect(form.primary_terms).not_to include(:alternative_title)
      expect(form.primary_terms).not_to include(:contributor)
      expect(form.primary_terms).not_to include(:description)
      expect(form.primary_terms).not_to include(:abstract)
      expect(form.primary_terms).not_to include(:access_right)
      expect(form.primary_terms).not_to include(:rights_notes)
      expect(form.primary_terms).not_to include(:publisher)
      expect(form.primary_terms).not_to include(:subject)
      expect(form.primary_terms).not_to include(:language)
      expect(form.primary_terms).not_to include(:source)
      expect(form.primary_terms).not_to include(:bibliographic_citation)
      expect(form.primary_terms).not_to include(:format)
      expect(form.primary_terms).not_to include(:date_created)
      expect(form.primary_terms).not_to include(:identifier)
      expect(form.primary_terms).not_to include(:based_near)
      expect(form.primary_terms).not_to include(:related_url)
      expect(form.primary_terms).not_to include(:extent)
    end
  end

  describe ".primary_terms" do
    it 'includes the primary_terms aka the required fields' do
      expect(form.primary_terms).to include(:title)
      expect(form.primary_terms).to include(:creator)
      expect(form.primary_terms).to include(:rights_statement)
      expect(form.primary_terms).to include(:date_created)
      expect(form.primary_terms).to include(:resource_type)
      expect(form.primary_terms).to include(:institution)
      expect(form.primary_terms).to include(:types)
    end
  end

  describe ".secondary_terms" do
    it 'does not include the primary_terms aka the required fields' do
      expect(form.secondary_terms).not_to include(:title)
      expect(form.secondary_terms).not_to include(:creator)
      expect(form.secondary_terms).not_to include(:rights_statement)
      expect(form.secondary_terms).not_to include(:date_created)
      expect(form.secondary_terms).not_to include(:resource_type)
      expect(form.secondary_terms).not_to include(:institution)
      expect(form.secondary_terms).not_to include(:types)
    end
  end

  describe ".secondary_terms" do
    it 'includes the license field' do
      expect(form.secondary_terms).to include(:license)
    end
    it 'includes the secondary_terms' do
      expect(form.secondary_terms).to include(:license)
      expect(form.secondary_terms).to include(:keyword)
      expect(form.secondary_terms).to include(:alternative_title)
      expect(form.secondary_terms).to include(:contributor)
      expect(form.secondary_terms).to include(:description)
      expect(form.secondary_terms).to include(:abstract)
      expect(form.secondary_terms).to include(:access_right)
      expect(form.secondary_terms).to include(:rights_notes)
      expect(form.secondary_terms).to include(:publisher)
      expect(form.secondary_terms).to include(:subject)
      expect(form.secondary_terms).to include(:language)
      expect(form.secondary_terms).to include(:source)
      expect(form.secondary_terms).to include(:bibliographic_citation)
      expect(form.secondary_terms).to include(:format)
      expect(form.secondary_terms).to include(:date_created)
      expect(form.secondary_terms).to include(:identifier)
      expect(form.secondary_terms).to include(:based_near)
      expect(form.secondary_terms).to include(:related_url)
      expect(form.secondary_terms).to include(:extent)
    end
  end
end
