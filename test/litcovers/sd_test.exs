defmodule Litcovers.SdTest do
  use Litcovers.DataCase

  alias Litcovers.Sd

  describe "sentiments" do
    alias Litcovers.Sd.Sentiment

    import Litcovers.SdFixtures

    @invalid_attrs %{title: nil}

    test "list_sentiments/0 returns all sentiments" do
      sentiment = sentiment_fixture()
      assert Sd.list_sentiments() == [sentiment]
    end

    test "get_sentiment!/1 returns the sentiment with given id" do
      sentiment = sentiment_fixture()
      assert Sd.get_sentiment!(sentiment.id) == sentiment
    end

    test "create_sentiment/1 with valid data creates a sentiment" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Sentiment{} = sentiment} = Sd.create_sentiment(valid_attrs)
      assert sentiment.title == "some title"
    end

    test "create_sentiment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sd.create_sentiment(@invalid_attrs)
    end

    test "update_sentiment/2 with valid data updates the sentiment" do
      sentiment = sentiment_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Sentiment{} = sentiment} = Sd.update_sentiment(sentiment, update_attrs)
      assert sentiment.title == "some updated title"
    end

    test "update_sentiment/2 with invalid data returns error changeset" do
      sentiment = sentiment_fixture()
      assert {:error, %Ecto.Changeset{}} = Sd.update_sentiment(sentiment, @invalid_attrs)
      assert sentiment == Sd.get_sentiment!(sentiment.id)
    end

    test "delete_sentiment/1 deletes the sentiment" do
      sentiment = sentiment_fixture()
      assert {:ok, %Sentiment{}} = Sd.delete_sentiment(sentiment)
      assert_raise Ecto.NoResultsError, fn -> Sd.get_sentiment!(sentiment.id) end
    end

    test "change_sentiment/1 returns a sentiment changeset" do
      sentiment = sentiment_fixture()
      assert %Ecto.Changeset{} = Sd.change_sentiment(sentiment)
    end
  end

  describe "realms" do
    alias Litcovers.Sd.Realm

    import Litcovers.SdFixtures

    @invalid_attrs %{title: nil}

    test "list_realms/0 returns all realms" do
      realm = realm_fixture()
      assert Sd.list_realms() == [realm]
    end

    test "get_realm!/1 returns the realm with given id" do
      realm = realm_fixture()
      assert Sd.get_realm!(realm.id) == realm
    end

    test "create_realm/1 with valid data creates a realm" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Realm{} = realm} = Sd.create_realm(valid_attrs)
      assert realm.title == "some title"
    end

    test "create_realm/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sd.create_realm(@invalid_attrs)
    end

    test "update_realm/2 with valid data updates the realm" do
      realm = realm_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Realm{} = realm} = Sd.update_realm(realm, update_attrs)
      assert realm.title == "some updated title"
    end

    test "update_realm/2 with invalid data returns error changeset" do
      realm = realm_fixture()
      assert {:error, %Ecto.Changeset{}} = Sd.update_realm(realm, @invalid_attrs)
      assert realm == Sd.get_realm!(realm.id)
    end

    test "delete_realm/1 deletes the realm" do
      realm = realm_fixture()
      assert {:ok, %Realm{}} = Sd.delete_realm(realm)
      assert_raise Ecto.NoResultsError, fn -> Sd.get_realm!(realm.id) end
    end

    test "change_realm/1 returns a realm changeset" do
      realm = realm_fixture()
      assert %Ecto.Changeset{} = Sd.change_realm(realm)
    end
  end

  describe "types" do
    alias Litcovers.Sd.Type

    import Litcovers.SdFixtures

    @invalid_attrs %{title: nil}

    test "list_types/0 returns all types" do
      type = type_fixture()
      assert Sd.list_types() == [type]
    end

    test "get_type!/1 returns the type with given id" do
      type = type_fixture()
      assert Sd.get_type!(type.id) == type
    end

    test "create_type/1 with valid data creates a type" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Type{} = type} = Sd.create_type(valid_attrs)
      assert type.title == "some title"
    end

    test "create_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sd.create_type(@invalid_attrs)
    end

    test "update_type/2 with valid data updates the type" do
      type = type_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Type{} = type} = Sd.update_type(type, update_attrs)
      assert type.title == "some updated title"
    end

    test "update_type/2 with invalid data returns error changeset" do
      type = type_fixture()
      assert {:error, %Ecto.Changeset{}} = Sd.update_type(type, @invalid_attrs)
      assert type == Sd.get_type!(type.id)
    end

    test "delete_type/1 deletes the type" do
      type = type_fixture()
      assert {:ok, %Type{}} = Sd.delete_type(type)
      assert_raise Ecto.NoResultsError, fn -> Sd.get_type!(type.id) end
    end

    test "change_type/1 returns a type changeset" do
      type = type_fixture()
      assert %Ecto.Changeset{} = Sd.change_type(type)
    end
  end

  describe "prompts" do
    alias Litcovers.Sd.Prompt

    import Litcovers.SdFixtures

    @invalid_attrs %{final_prompt: nil, name: nil, realm: nil, sentiment: nil, style_prompt: nil, type: nil}

    test "list_prompts/0 returns all prompts" do
      prompt = prompt_fixture()
      assert Sd.list_prompts() == [prompt]
    end

    test "get_prompt!/1 returns the prompt with given id" do
      prompt = prompt_fixture()
      assert Sd.get_prompt!(prompt.id) == prompt
    end

    test "create_prompt/1 with valid data creates a prompt" do
      valid_attrs = %{final_prompt: "some final_prompt", name: "some name", realm: :fantasy, sentiment: :positive, style_prompt: "some style_prompt", type: :object}

      assert {:ok, %Prompt{} = prompt} = Sd.create_prompt(valid_attrs)
      assert prompt.final_prompt == "some final_prompt"
      assert prompt.name == "some name"
      assert prompt.realm == :fantasy
      assert prompt.sentiment == :positive
      assert prompt.style_prompt == "some style_prompt"
      assert prompt.type == :object
    end

    test "create_prompt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sd.create_prompt(@invalid_attrs)
    end

    test "update_prompt/2 with valid data updates the prompt" do
      prompt = prompt_fixture()
      update_attrs = %{final_prompt: "some updated final_prompt", name: "some updated name", realm: :realism, sentiment: :neutral, style_prompt: "some updated style_prompt", type: :subject}

      assert {:ok, %Prompt{} = prompt} = Sd.update_prompt(prompt, update_attrs)
      assert prompt.final_prompt == "some updated final_prompt"
      assert prompt.name == "some updated name"
      assert prompt.realm == :realism
      assert prompt.sentiment == :neutral
      assert prompt.style_prompt == "some updated style_prompt"
      assert prompt.type == :subject
    end

    test "update_prompt/2 with invalid data returns error changeset" do
      prompt = prompt_fixture()
      assert {:error, %Ecto.Changeset{}} = Sd.update_prompt(prompt, @invalid_attrs)
      assert prompt == Sd.get_prompt!(prompt.id)
    end

    test "delete_prompt/1 deletes the prompt" do
      prompt = prompt_fixture()
      assert {:ok, %Prompt{}} = Sd.delete_prompt(prompt)
      assert_raise Ecto.NoResultsError, fn -> Sd.get_prompt!(prompt.id) end
    end

    test "change_prompt/1 returns a prompt changeset" do
      prompt = prompt_fixture()
      assert %Ecto.Changeset{} = Sd.change_prompt(prompt)
    end
  end
end
