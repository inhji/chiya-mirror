defmodule ChiyaWeb.Format do
  def from_now(%DateTime{} = later) do
    now = NaiveDateTime.local_now()
    diff = DateTime.diff(now, later)
    do_from_now(diff)
  end

  def from_now(%NaiveDateTime{} = later) do
    now = NaiveDateTime.local_now()
    diff = NaiveDateTime.diff(now, later)
    do_from_now(diff)
  end

  def from_now(_), do: "never"

  def do_from_now(diff) do
    cond do
      diff <= -24 * 3600 -> "in #{div(-diff, 24 * 3600)} days"
      diff <= -3600 -> "in #{div(-diff, 3600)} hours"
      diff <= -60 -> "in #{div(-diff, 60)} minutes"
      diff <= -5 -> "in #{-diff} seconds"
      diff <= 5 -> "now"
      diff <= 60 -> "#{diff} seconds ago"
      diff <= 3600 -> "#{div(diff, 60)} minutes ago"
      diff <= 24 * 3600 -> "#{div(diff, 3600)} hours ago"
      true -> "#{div(diff, 24 * 3600)} days ago"
    end
  end

  def pretty_date(%NaiveDateTime{} = date), do: Calendar.strftime(date, "%d.%m.%Y")
  def pretty_date(_), do: ""

  def pretty_datetime(%NaiveDateTime{} = date), do: Calendar.strftime(date, "%d.%m.%Y %H:%M")
  def pretty_datetime(_), do: ""

  def datetime(%NaiveDateTime{} = date), do: Calendar.strftime(date, "%c")
  def datetime(_), do: ""
end
