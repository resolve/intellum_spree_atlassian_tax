module Spree
  module Admin
    class AtlassianEntityUseCodesController < Spree::Admin::BaseController
      before_action :load_use_code, only: %i[edit update destroy]

      def index
        @use_codes = SpreeAtlassianTax::EntityUseCode.all.order(code: :asc)
        respond_with(@use_codes)
      end

      def new
        @use_code = SpreeAtlassianTax::EntityUseCode.new
      end

      def edit; end

      def update
        if @use_code.update(entity_use_codes_params)
          redirect_to admin_atlassian_entity_use_codes_path, success: Spree.t('spree_atlassian_tax.entity_use_code_updated')
        else
          redirect_to edit_admin_atlassian_entity_use_code_path(@use_code), error: @use_code.errors.full_messages.to_sentence
        end
      end

      def create
        @use_code = SpreeAtlassianTax::EntityUseCode.new(entity_use_codes_params)
        if @use_code.save
          redirect_to admin_atlassian_entity_use_codes_path, success: Spree.t('spree_atlassian_tax.entity_use_code_created')
        else
          redirect_to new_admin_atlassian_entity_use_code_path, error: @use_code.errors.full_messages.to_sentence
        end
      end

      def destroy
        if @use_code.destroy
          flash[:success] = Spree.t('spree_atlassian_tax.entity_use_code_removed')
        else
          flash[:error] = @use_code.errors.full_messages.to_sentence
        end

        respond_with(@use_code) do |format|
          format.html { redirect_to admin_atlassian_entity_use_codes_path }
          format.js   { render_js_for_destroy }
        end
      end

      private

      def load_use_code
        @use_code ||= SpreeAtlassianTax::EntityUseCode.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = e.message
        redirect_to admin_atlassian_entity_use_codes_path
      end

      def entity_use_codes_params
        params.require(:entity_use_code).permit(:code, :name, :description)
      end
    end
  end
end
