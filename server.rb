require 'sinatra'
require "sinatra/reloader"

require 'open-uri'

helpers do
  def buffer
    @_out_buf || @_buf
  end

  def capture
    pos = buffer.size
    yield
    buffer.slice!(pos..buffer.size)
  end

  def load(file)
    file = "./skins/#{@skin_code}/inc/#{file}.txt"
    File.read(file) if File.exists?(file)
  end

  def render_partial(file, locals = {})
    erb "_#{file}.html".to_sym, :layout => false, :locals => locals
  end

  def adyen_form_tag(&block)
    buffer << render_partial(:adyen_form, :block => block)
  end

  def adyen_payment_fields(&block)
    if block_given?
      capture &block
    else
      render_partial :adyen_payment_fields
    end
  end
end

get '/sf/*' do |path|
  if (file = "skins/#{path}") && File.exists?(file)
    send_file(file)
  end
end

get '/hpp/*' do |path|
  puts file = "views/#{path}"
  unless File.exists?(file)
    `mkdir -p #{File.dirname(file)}`
    `wget https://test.adyen.com/hpp/#{path} -O #{file}`
  end
  send_file(file)
end

get '/favicon.ico' do
end

get '/:skin_code' do |skin_code|
  # load skin
  file = "/skins/#{skin_code}/skin.html"
  if !File.exists?(".#{file}.erb")
    file = "/views/skin.html"
  end
  @skin_code = skin_code
  erb "..#{file}".to_sym, :layout => "layout.html".to_sym
end

get '/' do
  # list all skins
  skins = Dir['skins/*'].map do |path|
    File.basename(path)
  end

  erb :'index.html', :locals => { :skins => skins, :skin_code => 'index' }
end
