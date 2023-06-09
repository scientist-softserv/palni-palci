
module Capybara
  module DSL
    def visit(visit_uri)
      page.visit(visit_uri)
    rescue ::Selenium::WebDriver::Error::UnknownError => e
      puts e
      sleep 0.1
      page.visit(visit_uri)
    end
  end
end
