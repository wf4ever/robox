module ApplicationHelper
  
  def title(page_title, options={})
    content_for(:title, page_title.to_s)
    return content_tag(:h1, page_title, options)
  end
  
  def button(content_for_button, link, options={})
    options.reverse_merge!({ 
      :color => "regular",
      :size => "large" 
    })
    
    options[:class] = "awesome #{options[:color]} #{options[:size]} button"
    
    return link_to(content_for_button, link, options.delete_if{|o| [ :size, :color ].include? o})
  end
  
  def axialis_icon_path(name, options={})
    options.reverse_merge!({ 
      :color => :red,
      :size => "16x16" 
    })
    return "Axialis-Round-Web2-#{options[:color].to_s.capitalize}-Png/Png/#{options[:size]}/#{name}.png"
  end

  def value_or_none_text(value, none_text='none')
    value.blank? ?
        content_tag(:span, none_text, :class => 'none_text') :
        value.to_s
  end

  def toggle_collapsibles_link
    link_id = "toggle_collapsibles_#{rand(10000000)}"
    link_to_function("Expand/collapse all", nil, :id => link_id, :class => 'toggle_collapsibles') do |page|
      page << "$('.collapsibleContainerContent').slideToggle();"
    end
  end
  
end
