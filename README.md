# mini-rails

A small web framework built for learning how Rails works.

Its structure follows current Rails: not only the components, but most of the files and classes inside them use almost the same names as the ones in the Rails source.

It does not aim to cover what Rails can do. Only the parts you need in order to follow the mechanics are implemented, so most features are missing.

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

To run the tests (Minitest + Rack::Test, against an in-memory SQLite database):

```bash
bin/mini-test                                  # all tests
bin/mini-test test/mini_record/relation_test.rb # a single file
```

## License

[MIT License](LICENSE)
