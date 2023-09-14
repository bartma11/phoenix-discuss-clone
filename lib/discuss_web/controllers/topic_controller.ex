defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Repo
  alias Discuss.Topic

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :edit, :create, :update, :delete]
  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, :index, topics: topics
  end

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id)
    render conn, "show.html", topic: topic
  end

  def new(conn, _params) do
    render conn, :new, changeset: Topic.changeset(%Topic{}, %{})
  end

  def edit(conn, %{"id" => topic_id}) do
    changeset = Repo.get(Topic, topic_id) |> Topic.changeset(%{})
    render conn, :edit, changeset: changeset, topic_id: topic_id
  end

  def create(conn, %{"topic" => topic}) do
    changeset =
      conn.assigns[:user]
      |> Ecto.build_assoc(:topics)
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: path(conn, DiscussWeb.Router, ~p"/topics"))
      {:error, changeset} ->
        render conn, :new, changeset: changeset
    end
  end

  def update(conn, %{"id" => topic_id, "topic" => update_attrs}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic, update_attrs)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: path(conn, DiscussWeb.Router, ~p"/topics"))
      {:error, changeset} ->
        render conn, :edit, changeset: changeset, topic_id: topic_id
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: path(conn, DiscussWeb.Router, ~p"/topics"))
  end

  defp check_topic_owner(%{params: %{"id" => topic_id}} = conn, _params) do
    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "Only the owner can edit the topic")
      |> redirect(to: path(conn, DiscussWeb.Router, ~p"/topics"))
      |> halt()
    end
  end
end
