require 'will_paginate/array'

get '/' do
  if request.user_agent =~ /Android/
    mobile_device = true
    per_page = 3
  elsif request.user_agent =~ /iPhone OS/
    mobile_device = true
    per_page = 6
  else
    mobile_device = false
    per_page = 9
  end

  per_page = params[:per_page] || per_page
  theta_photos = settings.theta_photos.paginate(page: params[:page], per_page: per_page)
  haml :index, locals: { theta_photos: theta_photos, mobile_device: mobile_device }
end

get '/theater' do
  haml :theater
end

get '/urls.json' do
  response = settings.theta_photos.map(&:to_h)
  [ 200, {'Content-Type' => 'application/json'}, response.to_json ]
end

get '/realtime' do
  request.websocket do |ws|
    ws.onopen do
      # 最新 1 件を送る
      settings.sockets << ws
      if settings.theta_photos.count > 0
        ws.send(settings.theta_photos.last.to_h.to_json)
      else
        ws.send(
          {
            image_url: settings.placeholder,
            page_url: settings.placeholder,
            type: :placeholder
          }.to_json
        ) if settings.placeholder
      end
    end

    ws.onclose do
      settings.sockets.delete(ws)
    end
  end
end
