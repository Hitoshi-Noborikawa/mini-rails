# mini-rails

A small web framework built for learning how Rails works. It is modeled mainly on Rails 1–3.

A mini blog is included as a sample app.

| mini-rails | Rails |
| --- | --- |
| MiniPack | ActionPack |
| MiniRecord | ActiveRecord |
| MiniView | ActionView |
| MiniModel | ActiveModel |
| MiniSupport | ActiveSupport |

Tested with Ruby 3.3.

```bash
bundle install
cp .env.example .env
```

Put the output of this command into `SESSION_SECRET` in `.env`.

```bash
ruby -rsecurerandom -e 'print SecureRandom.hex(32)'
```

Then set up the database and start the server. (You may need to give the scripts execute permission.)

```bash
bin/mini-migrate
bin/mini-seed
bin/dev
```

## License

[MIT License](LICENSE)
