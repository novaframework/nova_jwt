## Nova JWErl

### Usage

Since *nova* does not have any abstraction layer for models we had to be a little creative. In order to use this library
you need to create a module that links the model and nova_jwt. Create a module that uses the `nova_jwt_db` behaviour and implement all the required callbacks.
This should be straight forward and gives the implementor the freedom to extend the models.

When all of that is done all you have to do is to have the following configuration in your `sys.config`-file:
```
{nova_jwt, [{nova_jwt_get_db_module, MY_MODULE}]}
```
Where `MY_MODULE` is swapped for the name of your module containing the callbacks you just implemented.

**NOTE!** This is not a nova_application - just include it as a regular dependency in your `rebar.config`-file
