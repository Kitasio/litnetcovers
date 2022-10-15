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
end
