defmodule DiscussWeb.TopicHTML do
  use DiscussWeb, :html

  import DiscussWeb.ErrorHelpers
  import Phoenix.HTML.Form
  import Phoenix.HTML.Link

  embed_templates "topic_html/*"
end
