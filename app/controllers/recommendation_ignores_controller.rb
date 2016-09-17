class RecommendationIgnoresController < ShikimoriController
  before_filter :authenticate_user!

  def create
    render json: RecommendationIgnore.block(entry, current_user)
  end

  def cleanup
    current_user.recommendation_ignores.where(target_type: klass.name).delete_all
    render json: { notice: "Очистка списка заблокированных рекомендаций #{params[:target_type] == 'anime' ? 'аниме' : 'манги'} завершена" }
  end

private
  def entry
    klass.find params[:target_id]
  end

  def klass
    params[:target_type].capitalize.constantize
  end
end
