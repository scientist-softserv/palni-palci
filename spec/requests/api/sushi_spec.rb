# frozen_string_literal: true

RSpec.describe 'api/sushi/r51', type: :request, singletenant: true do
  describe 'GET /api/sushi/r51/reports/ir' do
    it 'returns a 200 with correct response for item report' do
      get '/api/sushi/r51/reports/ir'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['item_report']).to eq 'hello all items report'
    end

    describe 'with an item_id parameter'  do
      it 'returns a 200 status report for the given item' do
        get '/api/sushi/r51/reports/ir', params: { item_id: 123 }
        expect(response).to have_http_status(200)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['item_report']).to eq 'hello single item report'
      end
    end
  end

  describe 'GET /api/sushi/r51/reports/pr (e.g. platform report)' do
    describe 'with required begin_date and end_date parameters' do
      it 'returns a 200 status' do
        get '/api/sushi/r51/reports/pr?begin_date=2023-04&end_date=2023-05'
        expect(response).to have_http_status(200)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.dig('Report_Header', 'Report_Name')).to eq('Platform Report')
      end
    end

    describe 'without required begin_date and end_date parameters' do
      it 'returns a 422 unprocessable entity' do
        get '/api/sushi/r51/reports/pr'
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'GET /api/sushi/r51/reports/pr_p1 (e.g. platform usage report)' do
    it 'returns a 200 status' do
      get '/api/sushi/r51/reports/pr_p1'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['platform_usage_report']).to eq 'message'
    end
  end

  describe 'GET /api/sushi/r51/status (e.g. platform status)' do
    it 'returns a 200 status' do
      get '/api/sushi/r51/status'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['status']).to eq 'ok'
    end
  end

  describe 'GET /api/sushi/r51/members (e.g. members report)' do
    it 'returns a 200 status' do
      get '/api/sushi/r51/members'
      expect(response).to have_http_status(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['members']).to eq 'message'
    end
  end

  describe 'GET /api/sushi/r51/reports (e.g. reports list)' do
    it 'returns a 200 status' do
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
