defmodule ChiyaWeb.Format do
  def from_now(later, now \\ DateTime.utc_now()) do
      diff = DateTime.diff(now, later)
      cond do
        diff <= -24 * 3600 -> "in #{div(-diff, 24 * 3600)}d"
        diff <= -3600 -> "in #{div(-diff, 3600)}h"
        diff <= -60 -> "in #{div(-diff, 60)}m"
        diff <= -5 -> "in #{-diff}s"
        diff <= 5 -> "now"
        diff <= 60 -> "#{diff}s ago"
        diff <= 3600 -> "#{div(diff, 60)}m ago"
        diff <= 24 * 3600 -> "#{div(diff, 3600)}h ago"
        true -> "#{div(diff, 24 * 3600)}d ago"
      end
  end
end