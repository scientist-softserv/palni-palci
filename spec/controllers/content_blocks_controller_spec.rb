# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ContentBlocksController, type: :controller do
  before do
    sign_in user
  end

  let(:valid_attributes) do
    {
      announcement_text: 'This is announcement text!',
      marketing_text: 'This is marketing text!',
      featured_researcher: 'This is featured researcher!',
      about_page: 'This page is about us!',
      help_page: 'This page will provide all the help you need.'
    }
  end

  context 'with an unprivileged user' do
    let(:user) { FactoryGirl.create(:user) }

    describe "GET #edit" do
      it "denies the request" do
        get :edit, params: { site: valid_attributes }
        expect(response).to have_http_status(401)
      end
    end

    describe "PUT #update" do
      it "denies the request" do
        put :update, params: { site: valid_attributes }
        expect(response).to have_http_status(401)
      end
    end
  end

  context 'with an administrator' do
    let(:user) { FactoryGirl.create(:admin) }

    describe "GET #edit" do
      it "assigns the requested site as @site" do
        get :edit
        expect(assigns(:site)).to eq(Site.instance)
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) do
          {
            announcement_text: 'This is new announcement text!',
            marketing_text: 'This is new marketing text!',
            featured_researcher: 'This is a new featured researcher!',
            about_page: 'This is a new page about us!',
            help_page: 'This page will provide more of the help you need.'
          }
        end

        before do
          FactoryGirl.create(:content_block, name: 'announcement_text')
          FactoryGirl.create(:content_block, name: 'marketing_text')
          FactoryGirl.create(:content_block, name: 'featured_researcher')
          FactoryGirl.create(:content_block, name: 'about_page')
          FactoryGirl.create(:content_block, name: 'help_page')
        end

        it "updates the requested site" do
          put :update, params: { site: new_attributes }
          Site.reload
          expect(Site.announcement_text.value).to eq "This is new announcement text!"
          expect(Site.marketing_text.value).to eq "This is new marketing text!"
          expect(Site.featured_researcher.value).to eq "This is a new featured researcher!"
          expect(Site.about_page.value).to eq "This is a new page about us!"
          expect(Site.help_page.value).to eq "This page will provide more of the help you need."
        end

        it "assigns the requested site as @site" do
          put :update, params: { site: valid_attributes }
          expect(assigns(:site)).to eq(Site.instance)
        end

        it "redirects to the site" do
          put :update, params: { site: valid_attributes }
          expect(response).to redirect_to(edit_site_content_blocks_path)
        end
      end
    end
  end
end
