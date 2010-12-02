class User < ActiveRecord::Base
  default_scope :order => 'id'

  serialize :data

  has_many :phone_numbers, :dependent => :destroy
  has_and_belongs_to_many :clubs
  has_one :website, :dependent => :destroy

  validates_presence_of :first_name, :age
  validates_numericality_of :age

  def to_param
    "#{self.id}-#{self.first_name}-#{self.last_name}".downcase.gsub(/\W/, ' ').strip.gsub(' ', '-').squeeze('-')
  end

end
