defmodule Takso.GuardianSerializer do
    @behaviour Guardian.Serializer
    
    def for_token(%Takso.User{} = user), do: {:ok, "User:#{user.id}"}
    def for_token(_), do: {:error, "unknown resource"}

    def from_token("User:"<>user_id), do: {:ok, Takso.repo.get(Takso.User, user_id)}
    def from_token(_), do: {:error, "unknown resource"}
end