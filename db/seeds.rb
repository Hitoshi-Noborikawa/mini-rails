# frozen_string_literal: true

posts = [
  {
    title: 'Hello, mini-rails',
    body: "I made a blog. Not with Rails, though. I'm writing something that imitates Rails myself. For now it just returns one line. I'll write about why I started some other time.",
    created_at: '2026-08-01 10:00:00 +0900'
  },
  {
    title: 'Starting with Rack',
    body: 'The call(env) I wrote in config.ru got called, and text showed up in the browser. Apparently that alone counts as a web application. Going without a framework makes it clear what a framework actually gives you.',
    created_at: '2026-08-02 10:00:00 +0900'
  },
  {
    title: 'The router was just an array',
    body: 'I wondered what resources :posts does, so I wrote it myself. It just pushes seven routes into an array. I only learned the hard way that /posts/new has to come before /posts/:id, or new gets treated as an id.',
    created_at: '2026-08-04 10:00:00 +0900'
  },
  {
    title: "I didn't get yield in layouts",
    body: "For a while I couldn't tell where the yield in a template comes from. It clicked once I learned that the template is turned into a method and called with a block. I don't think I would have come up with that myself.",
    created_at: '2026-08-05 10:00:00 +0900'
  },
  {
    title: "I'm giving a talk on how Rails works by building a small one",
    body: "I'll be giving a talk about mini-rails. In 15 minutes, I'll follow a request from Rack through the router, controller and view and back, using the code I actually wrote.",
    created_at: '2026-08-06 10:00:00 +0900'
  }
].map { Post.create!(_1) }

comments = {
  posts[1] => [
    { body: 'I was surprised too when I learned that call(env) is all it takes.', created_at: '2026-08-03 09:00:00 +0900' }
  ],
  posts[3] => [
    { body: 'I got caught by this too. Obvious once someone points it out.', created_at: '2026-08-05 18:00:00 +0900' }
  ],
  posts[4] => [
    { body: "I'll be there!", created_at: '2026-08-07 09:00:00 +0900' },
    { body: 'Will the slides be published?', created_at: '2026-08-07 14:00:00 +0900' },
    { body: "That's a lot to cover in 15 minutes... Looking forward to it.", created_at: '2026-08-08 09:00:00 +0900' }
  ]
}

comments.each do |post, attributes_list|
  attributes_list.each { post.comments.build(_1).save! }
end
