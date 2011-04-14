class HomeController < ApplicationController
  
  before_filter :prepare_wizard_data, :only => [ :index ]
  
  def index
  end

  def ros_help
    
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

    step_data_3 = Hashie::Mash.new({
      :text => "3. Add some ROs (as folders) with content into this location",
      :action_label => "Help",
      :action_path => ros_help_path(:anchor => 'adding_ros')
    })

    step_data_4 = Hashie::Mash.new({
      :text => "4. Wait for the app to sync",
      :action_label => "Status",
      :action_path => dashboard_dropbox_path(:anchor => 'sync_status')
    })
    
    step_data_5 = Hashie::Mash.new({
      :text => "Ready! View your Research Objects",
      :action_label => "ROs",
      :action_path => dashboard_ros_path
    })
    
    if user_signed_in? and current_user.has_a_dropbox_account?
      step_data_1.status = :done
      step_data_1.show_action = false
      
      if current_user.has_an_ro_container?
        step_data_2.status = :done
        step_data_2.show_action = false
        
        if current_user.initial_ro_synced?
          step_data_3.status = :done
          step_data_3.show_action = false

          step_data_4.status = :done
          step_data_4.show_action = false
          
          step_data_5.status = :done
          step_data_5.show_action = true
        else
          step_data_3.status = :pending
          step_data_3.show_action = true

          step_data_4.status = :pending
          step_data_4.show_action = true
          
          step_data_5.status = :not_available
          step_data_5.show_action = false
        end
      else
        step_data_2.status = :pending
        step_data_2.show_action = true
        step_data_2.action_path = new_dropbox_account_ro_container_path(current_user.main_dropbox_account)

        step_data_3.status = :not_available
        step_data_3.show_action = false

        step_data_4.status = :not_available
        step_data_4.show_action = false
        
        step_data_5.status = :not_available
        step_data_5.show_action = false
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
      
      step_data_5.status = :not_available
      step_data_5.show_action = false
    end
    
    @wizard_data.steps << step_data_1
    @wizard_data.steps << step_data_2
    @wizard_data.steps << step_data_3
    @wizard_data.steps << step_data_4
    @wizard_data.steps << step_data_5
    
    @wizard_data
  end

end
