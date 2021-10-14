# frozen_string_literal: true

namespace :tenants do
  # how much space, works, files, per each tenant?
  task calculate_usage: :environment do
    @results = []
    Account.find_each do |account|
      AccountElevator.switch!(account.cname)
      models = Hyrax.config.curation_concerns.map { |m| "\"#{m}\"" }
      works = ActiveFedora::SolrService.query("has_model_ssim:(#{models.join(' OR ')})", rows: 100_000)
      @tenant_file_sizes = []
      works.each do |work|
        document = SolrDocument.find(work.id)
        files = document._source["file_set_ids_ssim"]
        file_sizes = []
        files.each do |file|
          f = SolrDocument.find(file.to_s)
          file_sizes.push(f.to_h['file_size_lts'])
        end
        file_sizes_total_bytes = file_sizes.inject(0, :+)
        file_size_total = (file_sizes_total_bytes / 1.0.megabyte).round(2)
        @tenant_file_sizes.push(file_size_total)
      end
      tenant_file_sizes_total_megabytes = @tenant_file_sizes.inject(0, :+)
      @results.push("#{account.cname}: #{tenant_file_sizes_total_megabytes} Total MB / #{works.count} Works")
    end
    puts "=================================================================="
    @results.each do |result|
      puts result
    end
  end
end
