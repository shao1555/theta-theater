get '/' do
  haml :index, locals: { urls: settings.urls }
end

get '/theater' do
  haml :theater
end

get '/urls.json' do
  [ 200, {'Content-Type' => 'application/json'}, settings.urls.to_json ]
end

get '/realtime' do
  request.websocket do |ws|
    ws.onopen do
      # 最新 1 件を送る
      settings.sockets << ws
      ws.send(settings.urls[0])
    end

    ws.onclose do
      settings.sockets.delete(ws)
    end
  end
end
