class PullRequestsController < ApplicationController
  include PullRequestsHelper

  def ramda
    if params[:u].blank? || params[:p].blank?
      @response = 'Username or password was not provided'
      return @response
    end

    if params[:repo].nil?
      @response = ramda_prs(params[:u], params[:p])
      return @response
    end

    @response = ramda_repo_prs(params[:repo], params[:u], params[:p])
  end

  def week_o_week
    number_of_prs(params[:repo], params[:u], params[:p])
  end

  def average
    average_time(params[:repo], params[:u], params[:p])
  end
end
