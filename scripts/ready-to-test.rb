require 'yaml'
require 'net/http'
require 'json'
require 'uri'
require "base64"

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

def fetch_content(url)
  github_api_get(url)
end

# Filter the folder contents to get only YAML files
def filter_yaml_files(contents)
  contents.select { |item| item['type'] == 'file' && item['name'].match?(/testing/) }
end

def find(yaml_files)
  already_reserved_by_branch = yaml_files.find do |file|
    yaml_string = Base64.decode64(fetch_content("https://api.github.com/repos/shameson/argo-demo/contents/#{file['path']}")["content"])
    data = YAML.load yaml_string
    data.dig("metadata","annotations","reservedBy") && data.dig("metadata","annotations","reservedBy") == "myapp/mybranch"
  end

  return already_reserved_by_branch if already_reserved_by_branch

  available = yaml_files.find do |file|
    yaml_string = Base64.decode64(fetch_content("https://api.github.com/repos/shameson/argo-demo/contents/#{file['path']}")["content"])
    data = YAML.load yaml_string
    data.dig("metadata","annotations","reservedBy").nil? || data.dig("metadata","annotations","reservedBy").empty?
  end
end

def update_file_content(argo_file, new_content, url)
  sha = argo_file['sha']
  puts sha
  # update_data = {
  #   message: "Update #{FILE_PATH}",
  #   content: Base64.strict_encode64(new_content),
  #   sha: sha,
  #   branch: 'main'
  # }

  # url = "https://api.github.com/repos/#{GITHUB_OWNER}/#{GITHUB_REPO}/contents/#{FILE_PATH}"
  # github_api_put(url, update_data)
end

def commit_to_control(argo_file)
  yaml_string = Base64.decode64(fetch_content("https://api.github.com/repos/shameson/argo-demo/contents/#{argo_file['path']}")["content"])
  data = YAML.load yaml_string
  h = {"annotations" => {"reservedBy"=> "myapp/mybranch" } }
  data["metadata"].merge!(h)

  update_file_content(argo_file, data.to_yaml, "https://api.github.com/repos/shameson/argo-demo/contents/#{argo_file['path']}")
end

# Main script
begin
  contents = fetch_content("https://api.github.com/repos/shameson/argo-demo/contents/argo/myapp")
  yaml_files = filter_yaml_files(contents)

  # puts yaml_files.class
  cluster_file = find(yaml_files)
  commit_to_control(cluster_file)
  # if cluster file is nil, post a commit saying no env found
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
