class DashboardController < ApplicationController

  before_filter :authenticate_user!

  def show

  end

  def ros
    @research_objects = current_user.all_research_objects
  end

  def dropbox

  end

end