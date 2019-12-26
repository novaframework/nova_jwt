-module(nova_jwt_db).

-type nova_jwt_user() :: #{
                           id => integer(),
                           username => binary(),
                           password => binary(),
                           permissions => [atom()]
                          }.
-export_type([nova_jwt_user/0]).


-callback nova_jwt_get_user(Username :: binary(), Password :: binary()) ->
    {ok, User :: nova_jwt_user()} |
    {error, Reason :: atom()}.

-callback nova_jwt_remove_user(User :: nova_jwt_user()) -> ok | {error, Reason :: atom()}.

-callback nova_jwt_create_user(Username :: binary(), Password :: binary(), Permissions :: [atom()]) ->
    {ok, NewUser :: nova_jwt_user()} |
    {error, Reason :: atom()}.

-callback nova_jwt_add_permission(User :: nova_jwt_user(), Permission :: atom()) ->
    {ok, UpdatedUser :: nova_jwt_user()} |
    {error, Reason :: atom()}.

-callback nova_jwt_revoke_permission(User :: nova_jwt_user(), Permission :: atom()) ->
    {ok, UpdatedUser :: nova_jwt_user()} |
    {error, Reason :: atom()}.
