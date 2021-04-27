# frozen_string_literal: true

class ErrorsController < ApplicationController
  def internal_server_error
    render status: 500
  end
end