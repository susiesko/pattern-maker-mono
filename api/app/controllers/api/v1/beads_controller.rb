module Api
  module V1
    class BeadsController < BaseController
      def index
        @pagy, @beads = Catalog::FetchBeadsService.new(filter_params, self).call

        render json: {
          beads: ActiveModelSerializers::SerializableResource.new(@beads, each_serializer: BeadSerializer),
          meta: pagy_metadata(@pagy)
        }
      end

      def show
        @bead = Catalog::FetchBeadService.new(params[:id]).call
        render json: @bead, serializer: BeadSerializer
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Bead not found" }, status: :not_found
      end

      private

      def filter_params
        params.permit(:brand_id, :type_id, :size_id, :color_id, :finish_id, :search, :sort_by, :sort_direction, :items, :page)
      end
    end
  end
end