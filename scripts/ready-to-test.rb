require 'yaml'
require 'net/http'
require 'json'
require 'uri'

###
# when ready to test label is added do:
#   1. check for all testing argo yaml files,
#   2. find an env that does not have annotation "reservedBy" or has annotation "reservedBy: mybranch"(find or create)
#   3. push a commit to main, update the argo yaml with annotation and update the version.yaml in helm
###

def github_api_get(url)
  uri = URI(url)
  request = Net::HTTP::Get.new(uri)
  request['User-Agent'] = 'Ruby Script'

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  unless response.is_a?(Net::HTTPSuccess)
    raise "HTTP request failed: #{response.code} #{response.message}"
  end

  JSON.parse(response.body)
end

def fetch_folder_contents
  url = "https://api.github.com/repos/shameson/argo-demo/contents/argo/myapp"
  github_api_get(url)
end

# Filter the folder contents to get only YAML files
def filter_yaml_files(contents)
  contents.select { |item| item['type'] == 'file' && item['name'].match?(/testing/) }
end

# Main script
begin
  contents = fetch_folder_contents
  yaml_files = filter_yaml_files(contents)

  yaml_files.each do |file|
    puts "- #{file['name']}"
  end
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
