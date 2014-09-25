#################################
# Initializing Redis in Node.js #
#################################

# Such easy!  Very wow!
redisLib = require("redis")

domain = '127.0.0.1'
port = 6379
options = {}

redis = redisLib.createClient(port, domain, options)




##################
# Basic commands #
##################

# Setting
redis.set "myKey", "value", (err) ->

# Getting
redis.get "myKey", (err, result) ->
  # result is "value"

# Setting hash values
redis.hmset "myHashKey", {key: "value"}, (err) ->

# Getting one hash value
redis.hget "myHashKey", "key", (err, result) ->
  # result is "value"

# Getting all hash values
redis.hgetall "myHashKey", (err, result) ->
  # result is {key: "value"}

# Setting TTLs
redis.expire "myKey", 100, (err) ->
  # myKey will disappear in 100 seconds.

# Setting TTLs
redis.expireat "myKey", 1411603652, (err) ->
  # myKey will disappear at the indicated time, in unix-seconds.

# Deleting a key
redis.del "myKey", (err) ->
  # myKey no longer exists.



##################
# `Multi` syntax #
##################

rmulti = redis.multi()

rmulti.set "key1", "val1"
rmulti.set "key2", "val2"
rmulti.get "key1"
rmulti.get "key2"

rmulti.exec (err, result) ->
  # result is ['ok', 'ok', 'val1', 'val2']