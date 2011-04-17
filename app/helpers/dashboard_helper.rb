module DashboardHelper

  def class_name_for_sync_status(status)
    case status
      when :pending
        'notice'
      when :running
        'notice'
      when :failed
        'error'
      when :success
        'success'
      else
        ''
    end
  end

  # TODO: right now this just uses the cached info
  # on the ResearchObject and DropboxEntries, but for future
  # need to include info from the manifest too, like
  # the link in dLibra, annotations, etc.
  def build_tree_for_ro_contents(ro)
    content_tag(:ul, :class => 'ro_contents filetree') do
      content = ''
      ro.children.each do |entry|
        content = content + build_inner_content_for_entry(entry)
      end
      content.html_safe
    end
  end

  protected

  def build_inner_content_for_entry(entry)
    case entry.entry_type
      when :file
        content_tag(:li) do
          content_tag(:span, entry.name, :class => 'file')
        end

      when :directory
        content_tag(:li) do
          content = ''
          content = content + content_tag(:span, entry.name, :class => 'folder')
          content = content + content_tag(:ul) do
            content2 = ''
            entry.children do |inner_entry|
              content2 = content2 + build_inner_content_for_entry(inner_entry)
            end
            content2.html_safe
          end
          content.html_safe
        end

      when :manifest
        content_tag(:li) do
          content_tag(:span, entry.name, :class => 'file manifest')
        end
    end
  end

end