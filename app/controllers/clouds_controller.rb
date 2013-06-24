class CloudsController < ApplicationController

  def show

    @cloud = Cloud.agnostic_fetch(params[:id_or_short_name])

    authorize @cloud, :show?

    @page_title = @cloud.name
    @page_image = @cloud.dynamic_avatar_url
    @page_description = @cloud.description
    @page_type = "cloudsdale:cloud"
    @page_url = @cloud.short_name.present? ? cloud_url(@cloud.short_name) : cloud_url(@cloud.id)

    render status: 200

  end

end
