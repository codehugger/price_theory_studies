class LabourMarket < Market
  before_validation :set_product_name

  def hire(asking_price, employer)
    employee = world.people.unemployed.max_salary(asking_price).shuffle.first
    unless employee.nil?
      employee.update!(salary: asking_price, employer: employer)
    end
    employee
  end

  def adjust_prices
    if products.count > 0
      bid_price = sell_price = employees.shuffle.desired_salary
    end
    bid_price = sell_price = [sell_price, government.min_wage].max
    update(bid_price: bid_price, sell_price: sell_price)
  end

  def as_json(options=nil)
    { name: name, account_no: account_no, absolute_account_no: absolute_account_no }
  end

  def from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    new(name: hash["name"])
  end

  protected

  def set_product_name
    self.product_name = "labour"
  end

  def set_name
    self.name ||= "LabourMarket-#{world.name.gsub(/\s/, '')}"
  end
end
