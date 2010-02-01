class Article < ActiveRecord::Base

  set_primary_key 'article_id'

  has_many :comments, :dependent => :destroy
  
  belongs_to :magazine, :polymorphic => true

  before_save :set_body_html

  validates_presence_of :title,:body

  serialize :data

  def to_param
    "#{id}-#{title.gsub(' ', '_').camelize}"
  end

  private

  def set_body_html
    self.body_html = self.body
  end
  
end
