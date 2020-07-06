# frozen_string_literal: true

require "utils/curl"

module Repology
  module_function

  MAX_PAGINATION = 15

  def query_api(last_package_in_response = "")
    last_package_in_response += "/" unless last_package_in_response.empty?

    url = "https://repology.org/api/v1/projects/#{last_package_in_response}?inrepo=homebrew&outdated=1"

    output, _errors, _status = curl_output(url.to_s)
    JSON.parse(output)
  end

  def parse_api_response
    ohai "Querying outdated packages from Repology"

    outdated_packages = query_api
    last_package_index = outdated_packages.size - 1
    response_size = outdated_packages.size
    page_no = 1

    while response_size > 1 && page_no <= MAX_PAGINATION
      ohai "Paginating Repology api page: #{page_no}" if Homebrew.args.debug?

      last_package_in_response = outdated_packages.keys[last_package_index]
      response = query_api(last_package_in_response)

      response_size = response.size
      outdated_packages.merge!(response)
      last_package_index = outdated_packages.size - 1
      page_no += 1
    end

    ohai "#{outdated_packages.size} outdated packages identified"

    outdated_packages
  end
end
