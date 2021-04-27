RSpec.describe 'Error page', type: :request do
  context 'with singletenancy', singletenant: true do
    describe 'GET /500' do
      it 'renders the error page' do
          get "/500"
          expect(response).to have_http_status(:internal_server_error)
      end
    end

    describe "" do
      it "" do
      end
    end

  end
end