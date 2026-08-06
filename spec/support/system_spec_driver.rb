# frozen_string_literal: true

RSpec.configure do |config|
  config.before(type: :system) do
    selenium_remote_url = ENV.fetch("SELENIUM_REMOTE_URL", nil)

    selenium_options =
      if selenium_remote_url.present?
        { browser: :remote, url: selenium_remote_url }
      else
        {}
      end

    if selenium_remote_url.present?
      Capybara.server_host = ENV.fetch("CAPYBARA_SERVER_HOST", "0.0.0.0")
      Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT", "3001").to_i
      Capybara.app_host = ENV.fetch("CAPYBARA_APP_HOST", "http://web:3001")
    end

    driven_by(
      :selenium,
      using: :headless_chrome,
      screen_size: [ 1400, 1400 ],
      options: selenium_options
    )
  end
end
