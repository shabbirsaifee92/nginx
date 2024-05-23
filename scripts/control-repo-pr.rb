#!/usr/bin/env ruby

require 'octokit'
require 'securerandom'
require 'fileutils'

# Read the Personal Access Token, repository, and branch name from the command line arguments
pat = ARGV[0]
branch_name = ARGV[1]
repo = 'shameson/argo-demo'

# Set up the Octokit client with the PAT
client = Octokit::Client.new(access_token: pat)

# Define the PR details
target_branch = 'main' # The branch you want to merge into
unique_id = SecureRandom.hex(8) # Generate a unique identifier
branch_name = "#{branch_name}-#{unique_id}" # Unique branch name
title = 'Deploy to prod'
body = 'This PR was created automatically by a Ruby script.'

begin
  # Clone the repository
  `git clone https://#{pat}@github.com/#{repo}.git`
  Dir.chdir(repo.split('/').last) do
    # Create the new branch
    `git checkout -b #{branch_name}`

    Dir.glob('argo-demo/helm/myapp/environments/production-*/*version.yaml').each do |file|

      yaml_data = YAML.load_file(file)
      # Modify the version field in the YAML file
      yaml_data["deployment"]["image"]['tag'] = "x.x.x" # Example: Update version to "1.0.0"

      # Write back the modified YAML data to the file
      File.open(file, 'w') { |f| f.write yaml_data.to_yaml }
      puts "Modified file: #{file}"
    end

    # Commit and push the changes to the new branch
    `git add .`
    `git commit -m "Update version.yaml files"`
    `git push origin #{branch_name}`

    # Create the pull request
    pr = client.create_pull_request(repo, target_branch, branch_name, title, body)
    puts "Pull request created successfully: #{pr.html_url}"
  end
rescue Octokit::UnprocessableEntity => e
  puts "Failed to create pull request: #{e.message}"
  puts e.errors # Print detailed error messages
rescue Octokit::Error => e
  puts "An error occurred: #{e.message}"
end
