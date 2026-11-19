module ReviewsHelper
  def stars(rating)
    filled = rating.to_f.round
    "⭐" * filled + "🌟" * (5 - filled)
  end
end
