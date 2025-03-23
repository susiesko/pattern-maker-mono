# frozen_string_literal: true

module JsonHelper
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end

RSpec.configure do |config|
  config.include JsonHelper, type: :request
end
