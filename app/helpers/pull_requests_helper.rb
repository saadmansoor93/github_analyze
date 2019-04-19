require 'nitlink'
require 'net/http'

module PullRequestsHelper
  def ramda_prs(username, auth_token)
    auth = {:username => username, :password => auth_token}
    ramda_repos = HTTParty.get('https://api.github.com/users/ramda/repos', :basic_auth => auth)
    ramda_repos = ramda_repos.parsed_response
    ramda_repos_names = ramda_repos.pluck('name')

    all_pull_requests = []

    ramda_repos_names.each do |repo_name|
      all_pull_requests += ramda_repo_prs(repo_name, username, auth_token)
    end

    all_pull_requests
  end

  def ramda_repo_prs(repo_name, username, auth_token)
    return if repo_name.nil?
    link_parser = Nitlink::Parser.new

    auth = {:username => username, :password => auth_token}
    first_page = HTTParty.get("https://api.github.com/repos/ramda/#{repo_name}/pulls?state=all", :basic_auth => auth)

    results = first_page.parsed_response
    links = link_parser.parse(first_page)

    # We set a hard page limit to avoid it from taking forever
    page_number = 1
    page_limit = 5

    while links.by_rel('next') && page_number != page_limit
      response = HTTParty.get(links.by_rel('next').target, :basic_auth => auth)
      results += response.parsed_response
      links = link_parser.parse(response)

      page_number += 1
    end

    results.pluck('html_url')
  end
end
