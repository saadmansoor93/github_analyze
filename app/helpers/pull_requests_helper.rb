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

  # of PRs merged
  def number_of_prs(repo_name, username, auth_token)
    prs = ramda_repo_prs(repo_name, username, auth_token)
    total_merged = prs.select{ |pr| pr['merged_at'].blank? == false}
    sorted_prs = total_merged.sort_by{ |prs| prs['merged_at'] }

    first_pr_merge_date = sorted_prs.first['merged_at'].in_time_zone
    last_pr_merge_date = sorted_prs.last['merged_at'].in_time_zone

    date = first_pr_merge_date

    week_hash = {}
    while date < last_pr_merge_date
      week_hash[date] = sorted_prs.select { |pr| (pr['merged_at'] > date) && (pr['merged_at'] < date + 1.week)  }.count
      date += 1.week
    end
    binding.pry
    week_hash
  end

  # Average and median time from PR creation to merge time
  def average_time(repo_name, username, auth_token)
    prs = ramda_repo_prs(repo_name, username, auth_token)
    total_merged = prs.select{ |pr| pr['merged_at'].blank? == false}
    sorted_prs = total_merged.sort_by{ |prs| prs['merged_at'] }

    first_pr_merge_date = sorted_prs.first['merged_at'].in_time_zone
    last_pr_merge_date = sorted_prs.last['merged_at'].in_time_zone

    first_pr_created_date = sorted_prs.first['created_at'].in_time_zone
    last_pr_created_date = sorted_prs.last['created_at'].in_time_zone

    date = first_pr_merge_date

    week_hash = {}
    while date < last_pr_merge_date
      prs_for_week = sorted_prs.select { |pr| (pr['merged_at'] > date) && (pr['merged_at'] < date + 1.week)  }
      total_prs_for_week = prs_for_week.count

      prs_for_week_time = prs_for_week.map { |pr| pr['merged_at'].in_time_zone - pr['created_at'].in_time_zone  }
      sum = prs_for_week_time.sum

      week_hash[date] = total_prs_for_week == 0 ? 0 : sum/total_prs_for_week
      date += 1.week
    end

    week_hash
  end

end
