class Post < MiniRecord::Base
  has_many :comments

  validates :title, presence: true
  validates :body, length: { maximum: 1000 }

  before_validation :strip_title
  validate :validate_title_must_start_with_uppercase
  before_create :set_created_at
  before_save :set_updated_at

  def strip_title
    self.title = title&.strip
  end

  def validate_title_must_start_with_uppercase
    return if title.to_s.empty? || title.to_s.start_with?(/[A-Z]/)

    errors.add(:title, 'must start with an uppercase letter')
  end

  def set_created_at
    self.created_at = Time.now.to_s
  end

  def set_updated_at
    self.updated_at = Time.now.to_s
  end
end
