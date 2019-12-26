-module(nova_jwt).
-export([
         get_user/2,
         get_user/4,
         get_user_from_jwt/2,
         remove_user/1,
         create_user/3,
         have_permission/2,
         add_permission/2,
         revoke_permission/2
        ]).

-include_lib("nova/include/nova.hrl").

-define(JWT_ALGO, <<"HS256">>).

-spec get_user(Username :: binary(), Password :: binary()) -> {ok, User :: nova_jwt_db:nova_jwt_user()} |
                                                              {error, Reason :: atom()}.
get_user(Username, Password) ->
    Mod = get_db_module(),
    Mod:nova_jwt_get_user(Username, Password).


-spec get_user(Username :: binary(), Password :: binary(), JWTSecret :: binary(), Expiration :: integer()) ->
                      {ok, User :: nova_jwt_db:nova_jwt_user(), Token :: binary()} | {error, Reason :: atom()}.
get_user(Username, Password, JWTSecret, Expiration) ->
    case get_user(Username, Password) of
        {ok, User} ->
            {ok, Token} = jwt:encode(?JWT_ALGO, User, Expiration, JWTSecret),
            {ok, User, Token};
        Error ->
            Error
    end.


-spec get_user_from_jwt(Token :: binary(), JWTSecret :: binary()) -> {ok, User :: nova_jwt_db:nova_jwt_user()} |
                                                                     {error, Reason :: any()}.
get_user_from_jwt(Token, JWTSecret) ->
    jwt:decode(Token, JWTSecret).

-spec remove_user(User :: nova_jwt_db:nova_jwt_user()) -> ok | {error, Reason :: atom()}.
remove_user(User) ->
    Mod = get_db_module(),
    Mod:nova_jwt_remove_user(User).

-spec create_user(Username :: binary(), Password :: binary(), Permissions :: [atom()]) ->
                         {ok, NewUser :: nova_jwt_db:nova_jwt_user()} | {error, Reason :: atom()}.
create_user(Username, Password, Permissions) ->
    Mod = get_db_module(),
    Mod:nova_jwt_create_user(Username, Password, Permissions).


-spec have_permission(User :: nova_jwt_db:nova_jwt_user(), Permission :: atom()) -> boolean().
have_permission(#{permissions := Permissions}, Permission) ->
    lists:any(fun(P) ->
                      P == Permission
              end, Permissions).

-spec add_permission(User :: nova_jwt_db:nova_jwt_user(), Permission :: atom()) ->
                            {ok, UpdatedUser :: nova_jwt_db:nova_jwt_user()} | {error, Reason :: atom()}.
add_permission(User, Permission) ->
    Mod = get_db_module(),
    Mod:nova_jwt_add_permission(User, Permission).

-spec revoke_permission(User :: nova_jwt_db:nova_jwt_user(), Permission :: atom()) ->
                               {ok, UpdatedUser :: nova_jwt_db:nova_jwt_user()} | {error, Reason :: atom()}.
revoke_permission(User, Permission) ->
    Mod = get_db_module(),
    Mod:nova_jwt_revoke_permission(User, Permission).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Private function     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
-spec get_db_module() -> Module :: atom() | no_return().
get_db_module() ->
    case application:get_env(nova_jwt, db_module, undefined) of
        undefined ->
            ?ERROR("Could not find config db_module for nova_jwt. Please check the manual and configure db_module", []),
            erlang:throw({error, nova_jwt_get_db_module});
        Module ->
            Module
    end.
