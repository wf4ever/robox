class DropboxResearchObjectContainerController < ApplicationController
  
  before_filter :authenticate_user!, :except => [ :force_sync ]
  
  load_and_authorize_resource :dropbox_account, :except => [ :force_sync ]
  load_resource :dropbox_research_object_container, :through => :dropbox_account, :except => [ :force_sync ]
  
  def new
	@dropbox_research_object_container.path = "My ROs"
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

  def force_sync
    @dropbox_research_object_container = DropboxResearchObjectContainer.find(params[:ro_container_id])
    respond_to do |format|
      if params[:password] == @dropbox_research_object_container.workspace_password
        #@dropbox_research_object_container.submit_sync_job

        # Perform the sync immediately!
        # NOTE: this is subject to the request timeout so
        # will only be effective for small sets of ROs.
        sync_job = @dropbox_research_object_container.sync_jobs.create
        sync_job.run

        if sync_job.has_error?
          Util.say "Force sync FAILED for DropboxResearchObjectContainer with ID #{@dropbox_research_object_container.id}"
          format.html { render :text => "Sync failed:\n#{sync_job.error_message}", :status => 500 }
        else
          Util.say "Successfully forced sync for DropboxResearchObjectContainer with ID #{@dropbox_research_object_container.id}"
          format.html { head :ok }
        end
      else
        Util.say "Could not force sync for DropboxResearchObjectContainer with ID #{@dropbox_research_object_container.id} - forbidden! (probably bad password)"
        format.html { head :forbidden }
      end
    end
  end

end
