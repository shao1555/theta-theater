$ ->
  ws = new WebSocket("ws://#{location.host}/realtime")
  ws.onmessage = (event) ->
    data = JSON.parse(event.data)
    url = data['page_url']
    if data['type'] == 'placeholder'
      $('div#frame_container').empty()
      img = $ '<img>', src: "#{url}", class: 'theta-placeholder'
      $('div#frame_container').append img
    else
      $('div#frame_container').empty()
      iframe = $ '<iframe>', src: "#{url}?view=embed", class: 'theta-frame'
      $('div#frame_container').append iframe
