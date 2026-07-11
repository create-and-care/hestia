class SearchesController < ApplicationController
  def show
    @query = params[:q].to_s.strip
    @results = GlobalSearch.call(query: @query, household: Current.household, user: Current.user)
  end
end
