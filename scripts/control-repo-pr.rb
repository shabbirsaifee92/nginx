#!/usr/bin/env ruby

require 'octokit'
require 'fileutils'

# Ensure the correct number of arguments are passed
if ARGV.length != 2
  puts "Usage: ruby ready-to-test.rb <PAT> <branch_name>"
  exit 1
end

# Read the Personal Access Token and branch name from the command line arguments
pat = ARGV[0]
branch_name = ARGV[1]

# Set up the Octokit client with the PAT
client = Octokit::Client.new(access_token: pat)

# Define the repository where the PR will be created
repo = 'shameson/argo-demo' # Replace 'shameson' with the owner of the repository and 'argo-demo' with the repository name

# Define the PR details
target_branch = 'main' # The branch you want to merge into
title = 'Automated PR from Ruby script'
body = 'This PR was created automatically by a Ruby script.'

begin
  # Get the latest commit SHA from the target branch
  target_branch_ref = client.ref(repo, "heads/#{target_branch}")
  latest_commit_sha = target_branch_ref.object.sha

  # Create the new branch from the latest commit
  new_branch_ref = "refs/heads/#{branch_name}"
  client.create_ref(repo, new_branch_ref, latest_commit_sha)
  puts "New branch '#{branch_name}' created from '#{target_branch}'."

  # Make changes in the new branch (for demonstration, we'll create a new file)
  FileUtils.mkdir_p('tmp')
  File.open('tmp/hello.txt', 'w') { |file| file.write("Hello, world!") }

  # Commit and push the changes to the new branch
  `git config --global user.email "shabbirsaifee91@gmail.com"`
  `git config --global user.name "Shabbir Saifee"`
  `git checkout -b #{branch_name}`
  `touch tmp/hello.txt`
  `git add tmp/hello.txt`
  `git commit -m "Add hello.txt"`
  `git push origin #{branch_name}`

  # Create the pull request
  pr = client.create_pull_request(repo, target_branch, branch_name, title, body)
  puts "Pull request created successfully: #{pr.html_url}"
rescue Octokit::NotFound
  puts "Branch not found: Ensure that both the source branch '#{branch_name}' and the target branch '#{target_branch}' exist."
rescue Octokit::UnprocessableEntity => e
  puts "Failed to create pull request: #{e.message}"
  puts e.errors # Print detailed error messages
rescue Octokit::Error => e
  puts "An error occurred: #{e.message}"
end
