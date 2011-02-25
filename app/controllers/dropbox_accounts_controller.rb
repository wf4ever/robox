class DropboxAccountsController < ApplicationController
  
  def authorise
    if params[:oauth_token] then
      dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
      dropbox_session.authorize(params)
      session[:dropbox_session] = dropbox_session.serialize # re-serialize the authenticated session
      
      if dropbox_session.authorized?
        account_info = dropbox_session.account
        ap account_info; puts
        
        if account_info
        
          # Check if account is already registered, if not create it
          
          account = DropboxAccount.find_by_dropbox_user_id(account_info.uid)
          
          if account.nil?
            access_token = dropbox_session.access_token
            account = DropboxAccount.new(:dropbox_user_id => account_info.uid,
                                         :access_token => access_token.token,
                                         :access_secret => access_token.secret)
            
            account.setup_user!(account_info)
            
            account.save!
            
            flash[:success] = "Successfully set up your account. Welcome #{account.user.name}"
          else
            flash[:success] = "Successfully logged in. Welcome back #{account.user.name}"
          end
          
          sign_in account.user
          redirect_to root_path
        else
          flash[:error] = "Unable to retrieve information about your account from Dropbox. Please try again later"
          redirect_to root_path
        end
      else
        flash[:error] = "Unable to authorise you with Dropbox. Please try again later"
        redirect_to root_path
      end
    else
      dropbox_session = Dropbox::Session.new(Settings.dropbox.consumer_key, Settings.dropbox.consumer_secret)
      session[:dropbox_session] = dropbox_session.serialize
      redirect_to dropbox_session.authorize_url(:oauth_callback => url_for(:action => 'authorise'))
    end
  end

end