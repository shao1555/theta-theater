$ ->
  ws = new WebSocket("ws://#{location.host}/realtime")
  ws.onmessage = (event) ->
    url = event.data
    console.log url
    $('div#frame_container').empty()
    iframe = $ '<iframe>', src: "#{url}?view=embed", class: 'theta-frame'
    $('div#frame_container').append iframe
