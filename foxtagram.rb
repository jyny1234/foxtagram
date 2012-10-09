# -*- encoding: utf-8 -*-

require "sinatra"
require "instagram"
require "slim"

enable :sessions


CALLBACK_URL = "http://localhost:4567/oauth/callback"

Instagram.configure do |config|
  config.client_id = "7cd0b495f4c24b0380d9d29f428cb572"
  config.client_secret = "07d5f71806034d3fb451538b05fe10bc"
end

before do
  @title = 'Инстаграм им. Фоксвеба'
  @year = Time.now.year
  @author = "foxweb"
end

get "/" do
  client = Instagram.client(access_token: session[:access_token])
  @media_popular = client.media_popular
  slim :index
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], redirect_uri: CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/feed"
end

get "/feed" do
  client = Instagram.client(access_token: session[:access_token])
  @username = client.user.username
  @user_recent_media = client.user_recent_media(count: 50)
  slim :feed
end

get "/popular" do
  client = Instagram.client(access_token: session[:access_token])
  @media_popular = client.media_popular
  slim :popular
end

get "/follows" do
  client = Instagram.client(access_token: session[:access_token])
  @username = client.user.username
  @user_follows = client.user_follows
  slim :follows
end

get "/media/:media_id" do
  client = Instagram.client(access_token: session[:access_token])
  @media_item = client.media_item(params[:media_id])
  t = Time.at(@media_item.created_time.to_i)
  @date = t.strftime("%d.%m.%Y %H:%M (%Z)")
  slim :media_item
end
