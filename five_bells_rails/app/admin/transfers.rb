ActiveAdmin.register Transfer do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :debit_id, :credit_id, :amount, :description, :cycle
  #
  # or
  #
  # permit_params do
  #   permitted = [:debit_id, :credit_id, :amount, :description, :cycle]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do
    column :cycle
    column :bank
    column "Debit Account" do |trans|
      link_to trans.debit.account_no, admin_account_path(trans.debit)
    end
    column "Credit Account" do |trans|
      link_to trans.credit.account_no, admin_account_path(trans.credit)
    end
    column :amount
    actions
  end
end
