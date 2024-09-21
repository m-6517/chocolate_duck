class BoardDecorator < Draper::Decorator
  delegate_all

  def color_percentage
    return { brown: 0, yellow: 0 } unless object.board_image.present?

    begin
      img_path = Rails.env.development? ? object.board_image.path : object.board_image.url
      img = MiniMagick::Image.open(img_path)
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

    # 強調して出力するために倍数をかける
    brown_percentage = (brown_count.to_f / total_count * 200).round(1)
    yellow_percentage = (yellow_count.to_f / total_count * 200).round(1)

    # 合計が100を超えないようにスケーリング
    total_percentage = brown_percentage + yellow_percentage
    if total_percentage > 100
      scale = 100.0 / total_percentage
      brown_percentage = (brown_percentage * scale).round(1)
      yellow_percentage = (yellow_percentage * scale).round(1)
    end

    {
      brown: brown_percentage,
      yellow: yellow_percentage
    }
  end

  protected

  # RGB to HSV conversion
  def rgb_to_hsv(r, g, b)
    r = r / 255.0
    g = g / 255.0
    b = b / 255.0

    max = [ r, g, b ].max
    min = [ r, g, b ].min
    delta = max - min

    # Hue calculation
    h = if delta == 0
      0
    elsif max == r
      60 * (((g - b) / delta) % 6)
    elsif max == g
      60 * (((b - r) / delta) + 2)
    else
      60 * (((r - g) / delta) + 4)
    end

    h += 360 if h < 0 # Hue should be in the range [0, 360]

    # Saturation calculation
    s = max == 0 ? 0 : delta / max

    # Value calculation
    v = max

    [ h, s, v ]
  end

  # Color classification based on HSV values
  def color_classification(pixel)
    r, g, b = pixel
    h, s, v = rgb_to_hsv(r, g, b)

    # Yellow classification (Hue around 30-50, high saturation and value)
    if h.between?(30, 50) && s > 0.5 && v > 0.5
      :yellow
    # Brown classification (Hue around 20-30, moderate saturation and lower value)
    elsif h.between?(20, 30) && s > 0.4 && v < 0.6
      :brown
    else
      :none
    end
  end
end
