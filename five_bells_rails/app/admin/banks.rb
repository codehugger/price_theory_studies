ActiveAdmin.register Bank do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :world_id, :name, :bank_no, :type, :share_price, :min_capital, :capital_pct, :capital_steps, :interest_reate_delta, :write_off_limit, :loss_provision_pct, :labour_output
  #
  # or
  #
  # permit_params do
  #   permitted = [:world_id, :name, :bank_no, :type, :share_price, :min_capital, :capital_pct, :capital_steps, :interest_reate_delta, :write_off_limit, :loss_provision_pct, :labour_output]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
