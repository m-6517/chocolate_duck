class BoardsController < ApplicationController
  skip_before_action :require_login, only: [ :index, :show ]

  def index
    @boards = Board.includes(:user).order(created_at: :desc)
  end

  def new
    @board = Board.new
  end

  def create
    @board = current_user.boards.build(board_params)
    if @board.save
      color_percentages = @board.decorate.color_percentage
      redirect_to boards_path, success: t("defaults.flash_message.created", item: Board.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_created", item: Board.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @board = Board.find(params[:id])
    if @board.board_image_url != "path/to/default/image.png"
      @color_percentages = @board.decorate.color_percentage
    else
      @color_percentages = nil
    end
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
end
