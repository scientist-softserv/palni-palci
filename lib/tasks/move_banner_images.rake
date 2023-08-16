# frozen_string_literal: true

# @see https://github.com/scientist-softserv/palni-palci/issues/674
namespace :hyku do
  desc 'Move all banner images to new expected location'
  task copy_banner_images: :environment do
    files_in_old_location = `find #{Rails.root}/public/uploads/*/site/banner_image/* -type f`.split("\n")
    new_location = Rails.root.join('public', 'system', 'banner_images', '1', 'original')

    FileUtils.mkdir_p(new_location)
    files_in_old_location.each do |file|
      puts "Copying #{file} to #{new_location}"
      FileUtils.cp(file, new_location)
    end
  end

  desc 'Delete all banner images in old location'
  task delete_old_banner_images: :environment do
    copy_first_msg = 'WARNING - before running this, run hyku:copy_banner_images and verify the ' \
                     'files get copied successfully. Continue? (y/n)'
    STDOUT.puts copy_first_msg
    conf1 = STDIN.gets.chomp
    unless %w[y yes].include?(conf1)
      puts 'Task canceled'
      exit 1
    end

    files_in_old_location = `find #{Rails.root}/public/uploads/*/site/banner_image/* -type f`.split("\n")
    files_in_new_location = `find #{Rails.root}/public/system/banner_images/*/original/* -type f`.split("\n")

    if files_in_old_location.length > files_in_new_location.length
      warning = "WARNING - more files exist in the old file location (#{files_in_old_location.length}) " \
                "than the new location (#{files_in_new_location.length}). Continue? (y/n)"
      STDOUT.puts warning
      conf2 = STDIN.gets.chomp
      unless %w[y yes].include?(conf2)
        puts 'Task canceled'
        exit 1
      end
    end

    files_in_old_location.each { |file| FileUtils.rm(file) }
  end
end
