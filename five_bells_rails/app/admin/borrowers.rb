ActiveAdmin.register Borrower do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :world_id, :employer_type, :employer_id, :name, :age, :initial_bank_id, :initial_deposit, :salary, :desired_salary, :type, :loan_amount, :loan_type, :loan_duration, :borrower_window, :bank_employee, :bank_id, :loan_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:world_id, :employer_type, :employer_id, :name, :age, :initial_bank_id, :initial_deposit, :salary, :desired_salary, :type, :loan_amount, :loan_type, :loan_duration, :borrower_window, :bank_employee, :bank_id, :loan_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
