get '/' do
  haml :index, locals: { theta_photos: settings.theta_photos }
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
