class BoardDecorator < Draper::Decorator
  delegate_all

  def color_percentage
    return { brown: 0, yellow: 0 } unless object.board_image.present?

    begin
      img = MiniMagick::Image.open(object.board_image.path)
    rescue => e
      Rails.logger.error("Image processing failed: #{e.message}")
      return { brown: 0, yellow: 0 }
    end

    pixels = img.get_pixels.flatten.each_slice(3).to_a

    brown_count = 0
    yellow_count = 0
    total_count = pixels.size

    pixels.each do |pixel|
      case color_classification(pixel)
      when :brown
        brown_count += 1
      when :yellow
        yellow_count += 1
      end
    end

    {
      brown: (brown_count.to_f / total_count * 100).round(1),
      yellow: (yellow_count.to_f / total_count * 100).round(1)
    }
  end

  private

  def color_classification(pixel)
    r, g, b = pixel
    if r > 90 && g < 80 && b < 80 || r > 150 && g > 120 && b < 80
      :brown
    elsif r > 200 && g > 200 && b < 100
      :yellow
    else
      :none
    end
  end
end
