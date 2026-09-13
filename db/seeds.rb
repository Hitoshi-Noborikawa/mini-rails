# frozen_string_literal: true

posts = [
  {
    title: 'Hello, mini-rails',
    body: 'ブログを作った。といっても Rails ではなく、Rails を真似た何かを自分で書いている。まずは1行返すところまで。なぜ作りはじめたのかは、そのうち書こうと思う。',
    created_at: '2026-08-01 10:00:00 +0900'
  },
  {
    title: 'Rack から始めた',
    body: 'config.ru に書いた call(env) が呼ばれて、ブラウザに文字が出た。これだけで Web アプリケーションと呼んでいいらしい。フレームワークが無いと何が無いのか、逆によく分かる。',
    created_at: '2026-08-02 10:00:00 +0900'
  },
  {
    title: 'Router はただの配列だった',
    body: 'resources :posts の中身が気になって自分で書いてみたら、7本のルートを配列に詰めているだけだった。/posts/new を /posts/:id より先に入れないと new が id 扱いされる、というのは踏んでから気づいた。',
    created_at: '2026-08-04 10:00:00 +0900'
  },
  {
    title: 'Layout の yield が分からなかった',
    body: 'テンプレートの中の yield がどこから来るのか、しばらく分からなかった。テンプレートをメソッドにしてからブロック付きで呼ぶ、と知って腑に落ちた。この発想は自分では思いつかなかったと思う。',
    created_at: '2026-08-05 10:00:00 +0900'
  },
  {
    title: '「小さく作ってわかるRailsの仕組み」という話をします',
    body: 'mini-rails の話をすることになりました。タイトルは「小さく作ってわかるRailsの仕組み」です。15分で、リクエストが Rack から Router、Controller、View を通って返るまでを、実際に書いたコードで追いかけます。',
    created_at: '2026-08-06 10:00:00 +0900'
  }
].map { Post.create!(_1) }

comments = {
  posts[1] => [
    { body: 'call(env) だけで動くの、知ったときは驚きました。', created_at: '2026-08-03 09:00:00 +0900' }
  ],
  posts[3] => [
    { body: 'これ自分も引っかかりました。言われてみればという感じですね。', created_at: '2026-08-05 18:00:00 +0900' }
  ],
  posts[4] => [
    { body: '聞きに行きます！', created_at: '2026-08-07 09:00:00 +0900' },
    { body: '資料は公開されますか？', created_at: '2026-08-07 14:00:00 +0900' },
    { body: '15分でその範囲は攻めてますね…。楽しみにしています。', created_at: '2026-08-08 09:00:00 +0900' }
  ]
}

comments.each do |post, attributes_list|
  attributes_list.each { post.comments.build(_1).save! }
end
