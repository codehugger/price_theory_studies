ActiveAdmin.register Statistic do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :world_id, :name
  #
  # or
  #
  # permit_params do
  #   permitted = [:world_id, :name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do
    column :name
    column :world
    column "Values" do |stat|
      stat.statistic_values.count
    end
    column "Trend" do |stat|
      bumpspark_tag stat.statistic_values.order(cycle: :asc).last(200).pluck(:value)
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :world do |stat|
        link_to stat.world.name, admin_world_path(stat.world)
      end
    end
    panel "Values" do
      line_chart statistic.statistic_values.pluck(:cycle, :value).map do |cycle, value|
        { cycle: cycle, value: value }
      end
    end

    active_admin_comments
  end
end
