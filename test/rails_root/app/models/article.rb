class Article < ActiveRecord::Base

  has_many :comments, :dependent => :destroy

  before_save :set_body_html

  validates_presence_of :title,:body

  private

  def set_body_html
    self.body_html = self.body
  end

end
