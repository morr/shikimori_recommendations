# NOTE: в конфиге мемкеша должна быть опция -I 32M
# иначе кеш оценок пользователей не влезет в мемкеш!
class Recommendations::RatesFetcher
  MinimumScores = 20

  attr_writer :user_ids
  attr_writer :target_ids
  attr_writer :by_user
  attr_writer :with_deletion
  attr_writer :user_cache_key

  def initialize klass, user_ids=nil
    @klass = klass
    @user_ids = user_ids
    @data = {}
    @by_user = true
    @with_deletion = true
  end

  # кешируемые нормализованные оценки по всем или конкретным пользователям
  def fetch normalization
    key = "#{cache_key}_#{normalization.class.name}"
    @data[key] ||= Rails.cache.fetch key, expires_in: 2.weeks do
      fetch_raw.each_with_object({}) do |(user_id, data), memo|
        memo[user_id] = normalization.normalize data, user_id
      end
    end
  end

  def fetch_raw
    @raw_data ||= Rails.cache.fetch cache_key, expires_in: 2.weeks do
      if @with_deletion
        fetch_rates(@klass).delete_if {|k,v| v.size < MinimumScores }
      else
        fetch_rates(@klass)
      end
    end
  end

  class << self
    def join_query klass
      "inner join #{klass.table_name} a on a.id = #{UserRate.table_name}.target_id and a.kind != 'special' and a.kind != 'music'"
    end

    def rate_query
      "#{UserRate.table_name}.status != '#{UserRate.status_id :planned}' and (#{UserRate.table_name}.score is not null and #{UserRate.table_name}.score > 0)"
    end
  end

private

  # выборка всех оценок из базы
  def fetch_rates klass
    data = {}

    query = UserRate
      .where(target_type: klass.name)
      .where(self.class.rate_query)
      .joins(self.class.join_query klass)

    query = query.where(user_id: @user_ids) if @user_ids.present?
    query = query.where(target_id: @target_ids) if @target_ids.present?

    query.find_each(batch_size: 20000) do |rate|
      if @by_user
        data[rate.user_id] ||= {}
        data[rate.user_id][rate.target_id] = rate.score
      else
        data[rate.target_id] ||= {}
        data[rate.target_id][rate.user_id] = rate.score
      end
    end

    data
  end

  def cache_key
    [
      :raw_user_rates,
      @klass.name,
      MinimumScores,
      @by_user,
      @with_deletion,
      @user_ids,
      @user_cache_key,
      @target_ids
    ].join '_'
  end
end
