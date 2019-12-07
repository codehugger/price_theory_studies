class Product < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :producer, foreign_key: 'producer_id', class_name: 'Factory'
  belongs_to :product_recipe, optional: false
end
