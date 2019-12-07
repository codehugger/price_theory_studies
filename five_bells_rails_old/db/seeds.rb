# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
world = World.create(name: 'World')
region = Region.create(name: 'Region1', world: world)
central_bank = CentralBank.create(region: region)
customer_bank = CustomerBank.create(name: 'Bank1', region: region)
labour_market = LabourMarket.create(name: 'LabourMarket', region: region, initial_bank: customer_bank)
government = Government.create(name: 'Government', region: region, bank: central_bank)

# People
people = (1..10).each { |x| Person.create(name: 'Person#{x}', region: region, desired_salary: 5, salary: 1, initial_bank: customer_bank, initial_deposit: 1000) }
borrower = Borrower.create(name: 'Borrower1', region: Region.first, loan_amount: 1000, loan_duration: 10, borrower_window: 1)

# Markets & Factories

# Product1 -> Component1
product_recipe = ProductRecipe.create(product_name: 'Product1')
component_recipe = ProductRecipe.create(product_name: 'Component1', parent: product_recipe)

# Product handlers
product_factory = Factory.create(name: 'Factory1', region: region, initial_bank: customer_bank, initial_deposit: 1000, product_name: product_recipe.product_name)
product_market = Market.create(name: 'Market1', region: region, product_name: product_recipe.product_name, initial_deposit: 1000, initial_bank: customer_bank, attempt_to_buy: false)

# Component handlers
component_factory_1 = Factory.create(name: 'ComponentFactory1', region: region, initial_bank: customer_bank, initial_deposit: 1000, product_name: component_recipe.product_name, allow_direct_purchase: false)
component_factory_2 = Factory.create(name: 'ComponentFactory2', region: region, initial_bank: customer_bank, initial_deposit: 1000, product_name: component_recipe.product_name, allow_direct_purchase: false)
component_market = Market.create(name: "ComponentMarket1", product_name: component_recipe.product_name, initial_bank: customer_bank, attempt_to_buy: false)

# Hire workers
Person.find(1).update!(employer: product_factory)
Person.find(2).update!(employer: component_factory_1)
Person.find(3).update!(employer: component_factory_2)
Person.find(4).update!(employer: product_market)
Person.find(5).update!(employer: component_market)
