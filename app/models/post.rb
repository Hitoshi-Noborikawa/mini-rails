class Post < ActiveRecord::Base
  validates :title, presence: true
  validates :body, length: { maximum: 1000 }
end
