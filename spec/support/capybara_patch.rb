# Retries the visit call to fix failures in CI. See below article for more info
# https://stackoverflow.com/questions/76209429/selenium-grid-with-chrome-113-against-macos-throws-exception-cannot-determine-l/76240293#76240293
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
