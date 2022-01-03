# frozen_string_literal: true

module SharedSearchHelper
  def generate_work_url(model, request)
    # needed because some attributes eg id is a symbol 7 others are string
    model = model.with_indifferent_access

    cname = model["account_cname_tesim"]
    account_cname = Array.wrap(cname).first

    has_model = model["has_model_ssim"].first.underscore.pluralize
    id = model["id"]

    request_params = %i[protocol host port].map { |method| ["request_#{method}".to_sym, request.send(method)] }.to_h
    get_url(id: id, request: request_params, account_cname: account_cname, has_model: has_model)
  end

  private

    def get_url(id:, request:, account_cname:, has_model:)
      new_url = "#{request[:request_protocol]}#{account_cname || request[:request_host]}"
      new_url += ":#{request[:request_port]}" if Rails.env.development? || Rails.env.test?
      new_url += "/concern/#{has_model}/#{id}"
      new_url
    end
end
