class BoardDecorator < Draper::Decorator
  delegate_all

  def color_percentage
    # board_imageが存在しない場合は、茶色と黄色の割合を0%にして返す
    return { brown: 0, yellow: 0 } unless object.board_image.present?

    begin
      # 画像のパスまたはURLを取得し、MiniMagickで画像を開く
      img_path = Rails.env.development? ? object.board_image.path : object.board_image.url
      img = MiniMagick::Image.open(img_path)
    rescue => e
      # エラーが発生した場合はログに記録し、茶色と黄色の割合を0%にして返す
      Rails.logger.error("Image processing failed: #{e.message}")
      return { brown: 0, yellow: 0 }
    end

    # 画像の全ピクセルデータを取得し、RGB値に変換して配列化
    pixels = img.get_pixels.flatten.each_slice(3).to_a

    # 茶色と黄色のピクセル数をカウントする変数を初期化
    brown_count = 0
    yellow_count = 0
    total_count = pixels.size

    # 各ピクセルのRGB値を使って色を判定
    pixels.each do |pixel|
      case color_classification(pixel)
      when :brown
        brown_count += 1
      when :yellow
        yellow_count += 1
      end
    end

    # 割合を強調するために200%に拡大
    brown_percentage = (brown_count.to_f / total_count * 200).round(1)
    yellow_percentage = (yellow_count.to_f / total_count * 200).round(1)

    # 2色の割合の合計が100%を超えないよう設定
    total_percentage = brown_percentage + yellow_percentage
    if total_percentage > 100
      scale = 100.0 / total_percentage
      brown_percentage = (brown_percentage * scale).round(1)
      yellow_percentage = (yellow_percentage * scale).round(1)
    end

    # 茶色と黄色の割合をハッシュとして返す
    {
      brown: brown_percentage,
      yellow: yellow_percentage
    }
  end

  protected

  # RGB値をHSV値に変換
  def rgb_to_hsv(r, g, b)
    # RGBの値を0〜1の範囲に正規化
    r = r / 255.0
    g = g / 255.0
    b = b / 255.0

    # RGBの最大値・最小値を取得し、差分を計算
    max = [ r, g, b ].max
    min = [ r, g, b ].min
    delta = max - min

    # 色相（Hue）の計算
    h = if delta == 0
      0
    elsif max == r
      60 * (((g - b) / delta) % 6)
    elsif max == g
      60 * (((b - r) / delta) + 2)
    else
      60 * (((r - g) / delta) + 4)
    end

    h += 360 if h < 0

    # 彩度（Saturation）の計算
    s = max == 0 ? 0 : delta / max

    # 明度（Value）の計算
    v = max
    # HSV値として返す
    [ h, s, v ]
  end

  # ピクセルのRGB値に基づいて色を分類する
  def color_classification(pixel)
    # ピクセルのRGB値を取得
    r, g, b = pixel
    # RGBをHSVに変換
    h, s, v = rgb_to_hsv(r, g, b)

    # 黄色の分類条件（色相が30〜50度、彩度と明度が高い）
    if h.between?(30, 50) && s > 0.5 && v > 0.5
      :yellow
    # 茶色の分類条件（色相が20〜30度、彩度が高く明度が低い）
    elsif h.between?(20, 30) && s > 0.4 && v < 0.6
      :brown
    else
      # その他の色は分類しない
      :none
    end
  end
end
