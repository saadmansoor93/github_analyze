# Github Analyze

Rails application to display pull requests for a Github repository

## Getting Started

In order to run this locally you must have Ruby 2.5.1 or greater installed on your machine

### Prerequisites

Here is a great guide on [getting started with rails](https://guides.rubyonrails.org/getting_started.html)

### Installing

Once you have rails installed:

cd into the repository and run the following:

```
rails s
```

then goto the following url to access the prs of a repository in the ramda org:

```
http://localhost:3000/pull_requests/ramda?u={Github_username}&p={Github_token}&repo={repository_in_ramda_org}
```

or if you want all prs of the org, go to the following:

```
http://localhost:3000/pull_requests/ramda?u={Github_username}&p={Github_token}
```

there is a pagination limit of 5 pages per repository set. This can be changed on line 32 on [pull_requests_helper.rb](https://github.com/saadmansoor93/github_analyze/blob/master/app/helpers/application_helper.rb) file

To generate a personal access token for github, follow [this link](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line). Make sure you have repo selected
