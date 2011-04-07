class DropboxResearchObjectContainerController < ApplicationController
  
  before_filter :authenticate_user!
  
  load_and_authorize_resource :dropbox_account
  load_resource :dropbox_research_object_container, :through => :dropbox_account
  
  def new
  end

  def create
    respond_to do |format|
      if @dropbox_research_object_container.save
        flash[:success] = "Successfully added an ROs container folder"
        format.html { redirect_to root_url }
      else
        format.html { render :action => "new" }
      end
    end

  end

end
