# frozen_string_literal: true

class DeleteJpgFilesJob < ApplicationJob
  def perform(files)
    files.each do |file|
      basename = file.file.file.basename
      directory = Rails.root.join("tmp", "jpgs", basename)
      FileUtils.rm_rf(directory)
    end
  end
end
