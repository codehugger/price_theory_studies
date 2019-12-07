class ProductRecipe < ApplicationRecord
  has_ancestry
  has_many :products

  alias_method :component_recipes, :children
  alias_method :product_recipes, :children
  alias_method :components, :children

  def as_json(options=nil)
    {
      product_name: product_name,
      component_recipes: component_recipes.map { |c| c.as_json }
    }
  end

  def self.from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    obj = new(product_name: hash["product_name"])
    hash["component_recipes"].each { |r| obj.children.new(ProductRecipe.from_json(r)) }
  end
end
