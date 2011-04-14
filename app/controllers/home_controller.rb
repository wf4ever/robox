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
      :text => "2. Specify a location in your Dropbox to find/store ROs",
      :action_label => "GO",
    })

    # TODO: add another step here to tell the users to add ROs + content
    # and then maybe get the user to explicitly to allow sync to happen
    
    step_data_3 = Hashie::Mash.new({
      :text => "3. Wait for the app to sync",
      :action_label => "Status",
      :action_path => "TODO"
    })
    
    step_data_4 = Hashie::Mash.new({
      :text => "Ready! View your Research Objects",
      :action_label => "ROs Dashboard",
      :action_path => dashboard_ros_path
    })
    
    if user_signed_in? and current_user.has_a_dropbox_account?
      step_data_1.status = :done
      step_data_1.show_action = false
      
      if current_user.has_an_ro_container?
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
        step_data_2.action_path = new_dropbox_account_ro_container_path(current_user.main_dropbox_account)
      
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
