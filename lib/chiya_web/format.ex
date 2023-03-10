defmodule ChiyaWeb.Format do
  def from_now(later) do
      now = DateTime.utc_now()
      diff = DateTime.diff(now, later)
      do_from_now(diff)
  end

  def from_now_naive(later) do
      now = NaiveDateTime.utc_now()
      diff = NaiveDateTime.diff(now, later)
      do_from_now(diff)
  end

  def do_from_now(diff) do 
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