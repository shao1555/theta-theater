get '/' do
  # すべての投稿画像を返す
  [ 200, {}, 'hello' ]
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