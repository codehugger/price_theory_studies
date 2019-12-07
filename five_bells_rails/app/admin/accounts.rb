ActiveAdmin.register Account do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :ledger_id, :owner_type, :owner_id, :account_no, :deposit, :inflow, :outflow
  #
  # or
  #
  # permit_params do
  #   permitted = [:ledger_id, :owner_type, :owner_id, :account_no, :deposit, :inflow, :outflow]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end


  show do
    attributes_table do
      row :account_no
      row :ledger do |acc|
        link_to acc.ledger.name, admin_ledger_path(acc.ledger)
      end
    end
    panel "Transfers" do
      table_for account.transfers do |trans|
        column "Debit" do |trans|
          link_to trans.debit.account_no, admin_account_path(trans.debit)
        end
        column "Credit" do |trans|
          link_to trans.credit.account_no, admin_account_path(trans.credit)
        end
        column :amount
        column :description
      end
    end
    active_admin_comments
  end
end
