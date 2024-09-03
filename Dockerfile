# ベースイメージとしてRubyを使用
FROM ruby:3.2.3

# 環境変数の設定
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# 必要なパッケージをインストール
RUN apt-get update -qq \
  && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# アプリケーションの作業ディレクトリを作成
RUN mkdir /myapp
WORKDIR /myapp

# Bundlerをインストール
RUN gem install bundler

# GemfileとGemfile.lockをアプリケーションディレクトリにコピー
COPY Gemfile Gemfile.lock ./

# BundlerでGemをインストール
RUN bundle install

# アプリケーションのコードをコピー
COPY . .

# デフォルトのポートを指定（Herokuではこのポートが使われます）
EXPOSE 3000

# デフォルトのコマンドを指定
CMD ["rails", "server", "-b", "0.0.0.0"]
