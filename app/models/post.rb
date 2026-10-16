class Post < MiniRecord::Base
  has_many :comments

  validates :title, presence: true
  validates :body, length: { maximum: 1000 }
  validate :validate_title_must_unique

  before_validation :strip_title

  def strip_title
    self.title = title&.strip
  end

  def validate_title_must_unique
    return if title.to_s.empty?
    return unless title_used_by_another_post?

    errors.add(:title, 'has already been taken')
  end

  def title_used_by_another_post?
    Post.where(title: title).any? { _1.id != id }
  end
end
