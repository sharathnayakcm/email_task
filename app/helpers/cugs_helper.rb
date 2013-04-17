module CugsHelper

  def searched_flags(flags)
    flags = Flag.where("id in (?)", flags).map{|f| f.name.downcase}
    html = ""
    flags.each do |f|
      html += "#{image_tag "flag_#{f}.png", :height=> 16, :width => 16, :class => 'buzz_flags'} "
    end
    html.html_safe
  end

  def searched_buzzed_by(users)
    User.where("id in (?)", users).map{|u| u.full_name}.join(", ")
  end

  def searched_insync_type(insync_types)
    if insync_types.include?('true') && insync_types.include?('false')
      "Insynced, Out of Insync"
    elsif insync_types.include?('true')
      "Insynced"
    elsif insync_types.include?('false')
      "Out of Insync"
    end
  end
  
end
