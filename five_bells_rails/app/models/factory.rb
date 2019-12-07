class Factory < Company
  has_many :products, as: :producer

  scope :produces, ->(name) { where(product_name: name) }
  scope :sells, ->(name) { where(product_name: name, allow_direct_purchase: true) }

  def produce(quantity=1)
    components_acquired = {}

    # see if the recipe actually exists
    recipe = ProductRecipe.find_by!(product_name: product_name)

    # check if we can actually afford the components
    required_deposit = 0
    recipe.components.each do |component|
      provider = Factory.sells(component.product_name).first
      provider ||= Market.sells(component.product_name).first

      required_deposit += provider.last_sold_price * quantity
    end

    if required_deposit > account.deposit
      raise 'Unable to afford to acquired the required components'
    end

    # first acquire all the required components (in bulk) to see if we can acquire them
    # even if we know we can afford them
    recipe.components.each do |component|
      # assume only one producer
      provider = Factory.sells(component.product_name).first
      provider ||= Market.sells(component.product_name).first

      # calculate price based on provider type
      price = provider.class == Factory ? (asking_price * (1.0 - component_margin)).ceil : -1

      # buy the required number of components
      components_provided = provider.sell_to(self, quantity, price)

      # see if we were able to acquire the necessary inventory
      if components_provided.empty?
        raise "Unable to acquire the necessary component #{component.product_name}"
      else
        components_acquired[component.product_name] = components_provided
      end
    end

    (1..quantity).map do |x|
      # delete one component (for each different component) from the inventory
      recipe.components.collect(&:product_name).each do |name| components_acquired[name].shift end

      # produce the end product
      products.create!(owner: self, producer: self, product_recipe: recipe)
    end
  end

  def bid_price() (asking_price * (1.0 - component_margin)).ceil end

  # Keiretsu style buying directly from factory at a fixed price
  def sell_to(buyer, quantity=1, asking_price=-1)
    # direct sales allowed or buyer is a market
    raise 'Direct factory purchases are not allowed' unless allow_direct_purchase || buyer.class == Market

    if output >= quantity
      produce(quantity)

      # make the transfer
      buyer.account.transfer_to(self.account, (asking_price - (1.0 - component_margin)).ceil*quantity, "#{buyer.name} buying #{product_name} quantity: #{quantity}")

      update!(asking_price: asking_price, last_sold_price: last_sold_price)

      # hand over the products once the sale has gone through
      products.take(quantity).map { |x| x.update!(owner: buyer) }
    else
      []
    end
  end

  # determine output of current work force
  def output
    employees.count * labour_output
  end

  def max_lot(bid_price)
    max_items = 0
    if products.count >= max_inventory
      adjust_price(-1)
      max_items = 0
    elsif max_inventory <= 0
      max_items = account.deposit / bid_price
    else
      max_items = max_inventory - products.count
    end
    [account.deposit / bid_price, max_items].min.floor
  end

  def evaluate
    # what is our recipe?
    recipe = ProductRecipe.find_by(product_name: product_name)

    # see if there is a buyer for our product
    buyer = world.markets.buys(product_name).shuffle.first
    buyer ||= world.factories.produces(recipe.parent.product_name).shuffle.first

    # we don't initiate anything unless we are selling to a market
    unless buyer.nil? && buyer.class.name == "Market"
      max_lot = buyer.max_lot(buyer.bid_price) if buyer.class == Factory
      max_lot ||= buyer.max_lot

      # we can produce and the market can buy
      if output != 0 && max_lot > 0
        products = produce(output)

        # market can't buy the lot produced
        price = buyer.buy_from(products.take(max_lot), -1, self)
      else
        price = 0
      end

      # pay salaries
      salaries_paid = pay_salaries()

      # calculate profites
      profit = price * max_lot

      # raise offered salary
      # TODO: use government min wage instead of 1
      offered_salary = [profit / 2, 1].max

      # get more employees
      if (employees.size == 0 || account.deposit > 3 * salaries_paid)
        world.labour_market.hire(offered_salary, self)
        offered_salary += 1
      end

      # pay debts
      pay_debts()

      update!(last_sold_price: price, offered_salary: offered_salary)
    end
  end

  def pay_salaries()
    employees.shuffle.reduce(0) do |sum, employee|
      transfer = account.transfer_to(employee.account, employee.salary, "Salary from #{name}")
      employee.fire!() if transfer.nil?
      sum + employee.salary
    end
  end

  def pay_debts()
    return 0
  end

  def as_json(options=nil)
    {
      name: name,
      account_no: account_no,
      absolute_account_no: absolute_account_no,
      initial_deposit: initial_deposit,
      product_name: product_name
    }
  end

  def self.from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    obj = new(name: hash["name"], product_name: hash["product_name"])
    obj
  end

  protected

  def set_name
    self.name ||= "#{world.name.gsub(/\s/, '')}-Factory-#{id}"
  end
end
