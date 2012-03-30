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

  def adyen_form_tag(&block)
    buffer << (erb :'_adyen_form.html', :layout => false, :locals => { :block => block })
  end

  def adyen_payment_fields(&block)
    if block_given?
      capture &block
    else
      erb :'_adyen_payment_fields.html', :layout => false
    end
  end
end

get '/sf/*' do |path|
  if (file = "skins/#{path}") && File.exists?(file)
    send_file(file)
  else
    ""
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

get '/:skin_code' do |skin_code|
  # load skin
  erb :'skin.html', :layout => :'../../views/layout.html', :views => "skins/#{skin_code}", :locals => { :skin_code => skin_code }
end

get '/' do
  # list all skins
  skins = Dir['skins/*'].map do |path|
    File.basename(path)
  end

  erb :'index.html', :locals => { :skins => skins, :skin_code => 'index' }
end
