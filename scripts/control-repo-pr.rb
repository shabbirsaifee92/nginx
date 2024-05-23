#!/usr/bin/env ruby

require 'octokit'

# Ensure the PAT (Personal Access Token) is passed as an argument
if ARGV.length != 2
  puts "Usage: ruby ready-to-test.rb <PAT>"
  exit 1
end

# Read the Personal Access Token from the command line argument
pat = ARGV[0]
source_branch = ARGV[1]

# Set up the Octokit client with the PAT
client = Octokit::Client.new(access_token: pat)

# Define the repository where the PR will be created
repo = 'shameson/argo-demo' # Replace 'username' with the owner of the repository and 'myrepo' with the repository name

# Define the PR details
target_branch = 'main' # The branch you want to merge into
title = 'Automated PR from Ruby script'
body = 'This PR was created automatically by a Ruby script.'

begin
  # Create the pull request
  pr = client.create_pull_request(repo, target_branch, source_branch, title, body)
  puts "Pull request created successfully: #{pr.html_url}"
rescue Octokit::Error => e
  puts "Failed to create pull request: #{e.message}"
end
