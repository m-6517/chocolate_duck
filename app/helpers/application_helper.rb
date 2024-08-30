module ApplicationHelper
  def flash_background_color(type)
    case type.to_sym
    when :success then "bg-yellow-100 border text-yellow-700 rounded-box relative"
    when :danger then "bg-orange-100 border text-orange-700 rounded-box relative"
    end
  end
end
