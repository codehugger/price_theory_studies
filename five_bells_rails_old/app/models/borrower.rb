class Borrower < Person
  def debt() account.debts.first end

  def evaluate(cycle)
    # within cycle window and has now debt outstanding
    if cycle % borrower_window == 0 && account.debt_outstanding == 0
      if loan_amount > 0
        # check if there are other outstanding debts
        if account.debts.count == 0
          # request a loan
          account.bank.request_loan(account, loan_amount, loan_duration)
        end
      end
    # determine if a salary payment is needed to meet loan obligations.
    elsif debt.payment_due?
      next_payment = debt.next_payment

      if !next_payment.nil?
        if account.deposit <= next_payment.total
          # employ by the bank
          update!(employer: account.bank)

          if account.deposit > 0
            update!(salary: (debt.next_payment.total - account.deposit))
          elsif account.deposit == 0
            update!(salary: loan.next_payment.total)
          end

          account.bank.pay_salaries(cycle)
        end

        # pay the loan
        debt.make_payment()
      end
    end
  end
end
