# frozen_string_literal: true

posts = [
  { title: 'Hello, mini-rails', body: 'これは最初の投稿です' },
  { title: 'Migration の仕組み', body: 'create_table と timestamps の話'},
  { title: 'Router から Controller へ', body: 'リクエストがどう流れるのかの話' }
]

posts.map{ Post.create!(_1) }
