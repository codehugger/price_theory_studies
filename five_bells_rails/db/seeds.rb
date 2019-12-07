# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Product1 -> Component1

def init_market_world
  product_recipe = ProductRecipe.first
  component_recipe = ProductRecipe.second

  world = World.create(name: 'MarketWorld')
  central_bank = CentralBank.create(world: world)
  customer_bank = CustomerBank.create(name: 'Bank_1', world: world)
  labour_market = LabourMarket.create(name: 'LabourMarket_1', world: world, initial_bank: customer_bank)
  government = Government.create(name: 'Government_1', world: world, bank: central_bank)

  # People
  people = (1..10).map { |x| Person.create(name: 'Person#{x}_1', world: world, desired_salary: 5, salary: 1, initial_bank: customer_bank, initial_deposit: 1000) }

  # Markets & Factories

  # Product handlers
  product_factory = Factory.create(name: 'Factory_1', world: world, initial_bank: customer_bank, initial_deposit: 1000, product_name: product_recipe.product_name)
  product_market = Market.create(name: 'Market_1', world: world, product_name: product_recipe.product_name, initial_deposit: 1000, initial_bank: customer_bank, attempt_to_buy: false)

  # Component handlers
  component_factory_1 = Factory.create(name: 'ComponentFactory_1', world: world, initial_bank: customer_bank, initial_deposit: 1000, product_name: component_recipe.product_name, allow_direct_purchase: false)
  component_factory_2 = Factory.create(name: 'ComponentFactory_2', world: world, initial_bank: customer_bank, initial_deposit: 1000, product_name: component_recipe.product_name, allow_direct_purchase: false)
  component_market = Market.create(name: 'Market_2', world: world, product_name: component_recipe.product_name, initial_deposit: 1000, initial_bank: customer_bank, attempt_to_buy: true)

  # Hire workers
  people[0].update!(employer: product_factory)
  people[1].update!(employer: component_factory_1)
  people[2].update!(employer: component_factory_2)
  people[3].update!(employer: product_market)
  people[4].update!(employer: component_market)
end

def init_keiretsu_world
  # product_recipe = ProductRecipe.first
  # component_recipe = ProductRecipe.second

  # world = World.create(name: 'KeiretsuWorld')
  # central_bank = CentralBank.create(world: world)
  # customer_bank = CustomerBank.create(name: 'Bank_2', world: world)
  # labour_market = LabourMarket.create(name: 'LabourMarket_2', world: world, initial_bank: customer_bank)
  # government = Government.create(name: 'Government_2', world: world, bank: central_bank)

  # # People
  # people = (1..10).map { |x| Person.create(name: 'Person#{x}_2', world: world, desired_salary: 5, salary: 1, initial_bank: customer_bank, initial_deposit: 1000) }

  # # Markets & Factories

  # # Product handlers
  # product_factory = Factory.create(name: 'Factory_2', world: world, initial_bank: customer_bank, initial_deposit: 1000, product_name: product_recipe.product_name)
  # product_market = Market.create(name: 'Market_2', world: world, product_name: product_recipe.product_name, initial_deposit: 1000, initial_bank: customer_bank, attempt_to_buy: true)

  # # Component handlers
  # component_factory = Factory.create(name: 'ComponentFactory_3', world: world, initial_bank: customer_bank, initial_deposit: 1000, product_name: component_recipe.product_name, allow_direct_purchase: true)

  # # Hire workers
  # people[0].update!(employer: product_factory)
  # people[1].update!(employer: component_factory)
  # people[2].update!(employer: product_market)
end

borrower = Borrower.create(name: 'Borrower1', world: World.first, loan_amount: 1000, loan_duration: 10, borrower_window: 1)
product_recipe = ProductRecipe.create(product_name: 'Product')
component_recipe = ProductRecipe.create(product_name: 'Component', parent: product_recipe)

init_market_world
init_keiretsu_world
