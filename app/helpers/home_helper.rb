module HomeHelper
  
  def getting_started_status_icon(status)
    class_name = "status_icon"
    size = "24x24"
    image_name = status.to_s.capitalize
    alt_text = status.to_s.humanize.capitalize
    color = :green
    
    case status
    when :done
      image_name = "Ok"
    when :not_done
      image_name = "Cancel"
      color = :red
    end
    
    return image_tag axialis_icon_path(image_name, :color => color, :size => size), 
      :class => class_name, 
      :alt => alt_text
  end
  
end
