class Sale < ApplicationRecord
  belongs_to :buyer, polymorphic: true
  belongs_to :seller, polymorphic: true
  belongs_to :transfer

  has_many :sales_items
end
