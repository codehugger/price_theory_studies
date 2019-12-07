class Person < LegalEntity
  belongs_to :employer, polymorphic: true, optional: true

  scope :unemployed, -> { where(employer: nil) }
  scope :max_salary, ->(salary) { where("salary <= ?", salary) }

  def fire!
    update!(employer: nil)
  end

  def evaluate(cycle)
    # make a random purchase
    if rand(100) < 50
      Market.find_by(product_name: ProductRecipe.roots.shuffle.first.product_name).sell_to(self)
    end
  end

  def as_json(options=nil)
    {
      name: name,
      age: age,
      desired_salary: desired_salary,
      bank_name: account.bank.name,
      account_no: account.account_no,
      absolute_account_no: account.absolute_account_no,
      initial_deposit: initial_deposit
    }
  end

  def from_json(json)
    hash = json.class == String ? JSON.parse(json) : json
    new(
      name: hash["name"],
      age: hash["age"],
      desired_salary: hash["desired_salary"],
      initial_bank_name: hash["initial_bank_name"],
      account_no: hash["account.account_no"],
      initial_deposit: hash["initial_deposit"]
    )
  end

  protected

  def set_name
    self.name = "Person #{generate_number_sequence(6)}"
  end
end
