# frozen_string_literal: true

RSpec.describe 'api/sushi/r51', type: :request, singletenant: true do
  describe 'GET /api/sushi/r51/reports/ir' do
    it 'returns a 200 with correct response for item report' do
      get '/api/sushi/r51/reports/ir'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['item_report']).to eq 'hello all items report'
    end

    it 'returns a 200 with correct response for an specific work item report' do
      work = create(:work)
      get '/api/sushi/r51/reports/ir?item_id=' + work.id
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['item_report']).to eq 'hello single item report'
    end

    it 'returns a 200 with correct response for the platform report' do
      get '/api/sushi/r51/reports/pr'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['platform_report']).to eq 'hi'
    end

    it 'returns a 200 with correct response for the platform usage report' do
      get '/api/sushi/r51/reports/pr_p1'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['platform_usage_report']).to eq 'message'
    end

    it 'returns a 200 with correct response for the status' do
      get '/api/sushi/r51/status'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq 'ok'
    end

    it 'returns a 200 with correct response for the members' do
      get '/api/sushi/r51/members'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['members']).to eq 'message'
    end

    it 'returns a 200 with correct response for the reports list' do
      get '/api/sushi/r51/reports'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.first).to have_key('Report_Name')
      expect(parsed_body.first).to have_key('Report_ID')
      expect(parsed_body.first).to have_key('Release')
      expect(parsed_body.first).to have_key('Report_Description')
      expect(parsed_body.first).to have_key('Path')
    end
  end
end
