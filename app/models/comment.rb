class Comment < MiniRecord::Base
  belongs_to :post

  validates :body, presence: true
end
