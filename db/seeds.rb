# frozen_string_literal: true

posts = [
  { title: 'Hello, mini-rails', body: 'これは最初の投稿です', created_at: '2026-08-01 10:00:00 +0900' },
  { title: 'Migration の仕組み', body: 'create_table と timestamps の話', created_at: '2026-08-05 10:00:00 +0900'},
  { title: 'Router から Controller へ', body: 'リクエストがどう流れるのかの話', created_at: '2026-08-10 10:00:00 +0900' }
]

posts.map{ Post.create!(_1) }
