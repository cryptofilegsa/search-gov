class Sites::ImageAssetsController < Sites::SetupSiteController
  def edit
  end

  def update
    if @site.update_attributes(site_params)
      redirect_to edit_site_image_assets_path(@site),
                  flash: { success: 'You have updated your image assets.' }
    else
      render :edit
    end
  end

  def site_params
    @site_params = params.require(:site).permit(
        { css_property_hash: [:logo_alignment, :page_background_image_repeat] },
        :favicon_url,
        :header_image,
        :logo_alt_text,
        :mark_header_image_for_deletion,
        :mark_mobile_logo_for_deletion,
        :mark_page_background_image_for_deletion,
        :mobile_logo,
        :page_background_image)
    @site_params[:css_property_hash] = @site.css_property_hash.merge(@site_params[:css_property_hash]) if @site_params[:css_property_hash]
    @site_params
  end
end
