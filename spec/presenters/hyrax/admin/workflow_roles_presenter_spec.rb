RSpec.describe Hyrax::Admin::WorkflowRolesPresenter do
  let(:presenter) { described_class.new }

  describe "#users" do
    subject { presenter.users }

    let!(:user) { create(:user) }

    before do
      create(:user, :guest)
    end
    it "doesn't include guests" do
      expect(subject).to eq [user]
    end
  end

  describe "#groups" do
    subject { presenter.groups }

    let!(:group) { create(:group) }

    it "includes all Hyrax::Groups" do
      expect(subject).to eq [group]
    end
  end
end
