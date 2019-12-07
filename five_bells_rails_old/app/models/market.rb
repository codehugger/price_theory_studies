class Market < Company
  has_many :products, as: :owner

  has_many :purchases, as: :buyer, class_name: "Sale"
  has_many :sales, as: :seller

  scope :product, ->(name) { where(product_name: name) }
  scope :buys, ->(name) { where(product_name: name) }
  scope :sells, ->(name) { where(product_name: name) }

  before_validation :set_name
  after_create :open_deposit_account

  def max_lot
    max_items = 0
    if products.count >= max_inventory
      adjust_price(-1)
      max_items = 0
    elsif max_inventory <= 0
      max_items = account.deposit / self.bid_price
    else
      max_items = max_inventory - products.count
    end
    [account.deposit / self.bid_price, max_items].min.floor
  end

  def adjust_price(amount)
    # reject if adjustment brings bid price below 0
    return false if self.bid_price + amount < 1

    # max inventory or at least 3
    max_items = [max_inventory - products.count, 3].max

    # determine available cash
    available_cash = account.deposit - (max_items * self.bid_price)

    # no point increasing our bid price if we have exceeded our cash buffer
    return false if available_cash < account.deposit / self.cash_buffer && amount >= 1

    # no worries ... adjust prices
    update(bid_price: self.bid_price + amount, sell_price: self.sell_price + amount)
  end

  def increase_spread(amount)
    spread = [spread+amount, max_spread].min
    update!(spread: spread, sell_price: self.bid_price * spread)
  end

  def decrease_spread(amount)
    spread = [self.spread + amount, self.min_spread].max
    update!(spread: spread, sell_price: self.bid_price * spread)
  end

  def buy_from(lot, asking_price, seller)
    # take the current market price if no asking price
    price = asking_price < 0 ? self.bid_price : asking_price

    # check the sale quantity
    if lot.count <= max_lot
      transfer = account.transfer_to(seller.account, price * lot.count, "Sale from #{seller.name} to #{name}")

      # transfer went through at the expected price
      if transfer.persisted? && transfer.amount == price * lot.count
        # register the successful sale
        purchase = purchases.create!(buyer: self, seller: seller, transfer: transfer, cycle: 0)

        # inventory increased lower prices
        adjust_price(-1)

        # transfer the inventory
        return lot.map do |product|
          purchase.sales_items.create(product: product, price: price)
          product.update(owner: self)
        end
      end
    end

    # no purchase
    []
  end

  def sell_to(buyer, quantity=1, asking_price=-1)
    # the inventory does not contain enough products, attempt to acquired extra inventory
    if products.count < quantity && attempt_to_buy
      provider = Factory.produces(product_name).first
      provider.sell_to(self, quantity - products.count, (asking_price * (1.0 - profit_margin)).ceil)
    end

    if products.count < quantity
      adjust_price(+1)
    end

    # we can only sell what we have
    lot_size = [quantity, products.count].min

    # set market price if no asking price
    price = asking_price < 0 ? sell_price : asking_price

    transfer = buyer.account.transfer_to(account, price * lot_size, "Sale from #{name} to #{buyer.name}")

    # transfer went through at the expected price
    if transfer.persisted? && transfer.amount == price * lot_size
      sale = sales.create!(buyer: buyer, seller: self, transfer: transfer, cycle: 0)
      adjust_price(+1)

      return products.take(lot_size).map { |product|
        sale.sales_items.create(product: product, price: price)
        product.update(owner: buyer)
      }
    end

    # no sale
    []
  end

  def evaluate(cycle)
    # start by hiring people even if it means we will end up firing them
    hire_employees

    # pay salaries before anything else
    pay_salaries

    # adjust spread according to sales
    account.netto_flow < 0 ? increase_spread(1) : decrease_spread(1)

    # pay any outstanding loans
    pay_debts

    track_time_series(cycle)
  end

  def pay_salaries
    salaries_paid = employees.shuffle.reduce(0) do |sum, employee|
      transfer = account.transfer_to(employee.account, employee.salary, "Salary from #{name}")
      employee.fire!() if transfer.nil?
      sum + employee.salary
    end
    update!(salaries_paid: salaries_paid)
  end

  def hire_employees
    return false if (employees.size < max_employees)
  end

  def pay_debts
    return 0
  end

  def as_json(options=nil)
    {
      name: name,
      account_no: account_no,
      absolute_account_no: absolute_account_no,
      product_name: product_name,
      cash_buffer: cash_buffer,
      max_inventory: max_inventory,
      max_employees: max_employees,
      min_spread: min_spread,
      max_spread: max_spread
    }
  end

  def from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    new(
      name: hash["name"],
      product_name: hash["product_name"],
      cash_buffer: hash["cash_buffer"],
      max_inventory: hash["max_inventory"],
      max_employees: hash["max_employees"],
      min_spread: hash["min_spread"],
      max_spread: hash["max_sprea"]
    )
  end

  protected

  def track_time_series(cycle)
    # TODO: record everything important
  end

  def set_name
    self.name ||= "#{region.name.gsub(/\s/, '')}-Market-#{product.name.gsub(/\s/, '')}-#{id}"
  end
end
