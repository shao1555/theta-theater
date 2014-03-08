THETA Theater
=============

指定の Twitter アカウントに投稿された THETA 画像を監視し、最新の THETA 画像をフルスクリーンでプレゼンテーションするとともに、撮影された THETA 画像へのリンクページを提供します

@shao1555 の結婚式披露宴でテーブルラウンドを実況するために作りました。

getting start
-------------

    bundle install
    rackup

- rackup すると Twitter の各種トークン類の設定がはじまります。
  - あらかじめ、 Twitter に任意の名前でアプリケーションを登録しておいてください。
- 起動後
  - 指定した Twitter アカウントに投稿されている THETA 画像をすべて取得します。
  - http://localhost:9292/theater を開くと、直近で投稿された THETA 画像をフルスクリーンでプレゼンテーションします
  - http://localhost:9292/ で写真の一覧を表示します

customization
-------------
`~/.pit/default.yaml` で以下の設定が行えます

- placeholder : 何も画像が投稿されてないときに表示する画像への URL を指定します
- no_robot : ロボット避けのメタタグを出力します

license
-------

MIT License

todo list
---------

- [✓] Twitter Streaming API
- [✓] WebSocket Server
- [✓] ざっくりビューをつくる
- [✓] ビューのお化粧
- [_] SQLite とかに格納したい
