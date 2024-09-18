class OauthsController < ApplicationController
  # CSRF保護を無効にする
  skip_before_action :verify_authenticity_token, only: [ :callback ]
  skip_before_action :require_login

  def oauth
    # 指定されたプロバイダの認証ページにユーザーをリダイレクトさせる
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]

    # 既存のユーザーをプロバイダ情報を元に検索し、存在すればログイン
    if (@user = login_from(provider))
      flash[:success] = "#{provider.titleize}アカウントでログインしました"
      redirect_to root_path
    else
      begin
        # ユーザーが存在しない場合はプロバイダ情報を元に新規ユーザーを作成し、ログイン
        signup_and_login(provider)
        flash[:success] = "#{provider.titleize}アカウントでログインしました"
        redirect_to root_path
      rescue StandardError
        flash[:danger] = "#{provider.titleize}アカウントでのログインに失敗しました"
        redirect_to login_path
      end
    end
  end

  private

  def auth_params
    params.permit(:code, :provider, :scope, :authuser, :prompt)
  end

  def signup_and_login(provider)
    @user = create_from(provider)
    reset_session
    auto_login(@user)
  end
end
