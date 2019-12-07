ActiveAdmin.register World do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :current_cycle
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :current_cycle]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  member_action :run_cycle, method: :post do
    begin
      resource.evaluate()
      redirect_to resource_path, notice: "Cycle Run Successful!"
    rescue Exception => e
      details = "#{e.record.class.name} #{e.record.id}" if e.respond_to?(:record)
      redirect_to resource_path, alert: "#{e}#{details}"
    end
  end

  action_item :view, only: :show do
    link_to 'Run Cycle', run_cycle_admin_world_path(resource), method: :post
  end
end
