module ApplicationHelper
  def page_title(title = "")
    base_title = "CHOCOLATE DUCK"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def flash_background_color(type)
    case type.to_sym
    when :success then "bg-yellow-100 border text-yellow-700 rounded-box relative"
    when :danger then "bg-orange-100 border text-orange-700 rounded-box relative"
    end
  end

  def default_meta_tags
    {
      site: "CHOCOLATE DUCK",
      title: "CHOCOLATE DUCK",
      reverse: true,
      charset: "utf-8",
      description: "CHOCOLATE DUCK",
      canonical: request.original_url,
      og: {
        site_name: "CHOCOLATE DUCK",
        title: "CHOCOLATE DUCK",
        description: "CHOCOLATE DUCK",
        type: "website",
        url: request.original_url,
        image: image_url("ogp.png"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@https://x.com/kumateq",
        image: image_url("ogp.png")
      }
    }
  end
end
