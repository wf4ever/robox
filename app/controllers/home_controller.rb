class HomeController < ApplicationController
  
  before_filter :prepare_wizard_data, :only => [ :index ]
  
  def index
  end
  
  protected
  
  def prepare_wizard_data
    @wizard_data = Hashie::Mash.new({
      :steps => [ ]
    })
    
    # Step 1
    
    step_data_1 = Hashie::Mash.new({
      :text => "1. Sign in or connect with your Dropbox account",
      :action_label => "GO",
      :action_path => connect_path
    })
    
    step_data_2 = Hashie::Mash.new({
      :text => "2. Specify the ROs folder in your Dropbox",
      :action_label => "GO",
    })
    
    step_data_3 = Hashie::Mash.new({
      :text => "3. Wait for the app to sync",
      :action_label => "Status",
      :action_path => ""
    })
    
    step_data_4 = Hashie::Mash.new({
      :text => "Ready! See your Dashboard",
      :action_label => "Dashboard",
      :action_path => ""
    })
    
    if user_signed_in? and current_user.dropbox_account_connected?
      step_data_1.status = :done
      step_data_1.show_action = false
      
      if current_user.ros_folder_specified?
        step_data_2.status = :done
        step_data_2.show_action = false
        
        if current_user.initially_synced?
          step_data_3.status = :done
          step_data_3.show_action = false
          
          step_data_4.status = :done
          step_data_4.show_action = true
        else
          step_data_3.status = :pending
          step_data_3.show_action = true
          
          step_data_4.status = :not_available
          step_data_4.show_action = false
        end
      else
        step_data_2.status = :pending
        step_data_2.show_action = true
        step_data_2.action_path = specify_ro_folder_dropbox_account_path(current_user.main_dropbox_account)
      
        step_data_3.status = :not_available
        step_data_3.show_action = false
        
        step_data_4.status = :not_available
        step_data_4.show_action = false
      end
    else
      step_data_1.status = :pending
      step_data_1.show_action = true
      
      step_data_2.status = :not_available
      step_data_2.show_action = false
      
      step_data_3.status = :not_available
      step_data_3.show_action = false
      
      step_data_4.status = :not_available
      step_data_4.show_action = false
    end
    
    @wizard_data.steps << step_data_1
    @wizard_data.steps << step_data_2
    @wizard_data.steps << step_data_3
    @wizard_data.steps << step_data_4
    
    @wizard_data
  end

end
