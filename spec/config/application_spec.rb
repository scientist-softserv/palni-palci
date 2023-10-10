# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hyku::Application do
  describe '.html_head_title' do
    it { is_expected.to be_a(String) }
  end
end
