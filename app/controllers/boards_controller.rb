class BoardsController < ApplicationController
  ## privateに追加したprepare_meta_tagsをboardコントローラー以外にも使えるように設定
  helper_method :prepare_meta_tags

  def index
    @boards = Board.includes(:user).order(created_at: :desc)
  end

  def new
    @board = Board.new
  end

  def create
    @board = current_user.boards.build(board_params)
    if @board.save
      redirect_to boards_path, success: t("defaults.flash_message.created", item: Board.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_created", item: Board.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @board = Board.find(params[:id])
    ## メタタグを設定
    prepare_meta_tags(@board)
  end

  def edit
    @board = current_user.boards.find(params[:id])
  end

  def update
    @board = current_user.boards.find(params[:id])
    if @board.update(board_params)
      redirect_to board_path(@board), success: t("defaults.flash_message.updated", item: Board.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_updated", item: Board.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    board = current_user.boards.find(params[:id])
    board.destroy!
    redirect_to boards_path, success: t("defaults.flash_message.deleted", item: Board.model_name.human), status: :see_other
  end

  private

  def board_params
    params.require(:board).permit(:title, :body, :board_image, :board_image_cache)
  end

  def prepare_meta_tags(post)
    ## image_urlにMiniMagickで設定したOGPの生成した合成画像を代入する
    image_url = "#{request.base_url}/images/ogp.png?text=#{CGI.escape(@board.title)}"
    set_meta_tags og: {
                    site_name: "CHOCOLATE DUCK",
                    title: @board.title,
                    description: "ちゃいろときいろ ずかん",
                    type: "website",
                    url: request.original_url,
                    image: image_url,
                    locale: "ja-JP"
                  },
                  twitter: {
                    card: "summary_large_image",
                    site: "@https://x.com/kumateq",
                    image: image_url
                  }
  end
end
