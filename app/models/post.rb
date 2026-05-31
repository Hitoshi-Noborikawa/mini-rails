class Post < MiniRecord::Base
  validates :title, presence: true
  validates :body, length: { maximum: 1000 }
end
