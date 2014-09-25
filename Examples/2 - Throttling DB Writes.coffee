##########################################
# Example 2 - Throttling Database Writes #
##########################################

# In this example, we're going to use Redis to avoid making too many database writes.

# We want to record the last time used our site, but we don't need it to be more
# accurate than one hour.  So, we use redis to store whether an update has been
# made recently.  The key will expire in one hour.  We'll only write to the db
# if we don't find a key.


lastAccessUpdateMiddleware = (req, res, next) ->

  # Make a key that represents the last time we saved
  # the time of a user's most recent request.
  userId = req.user.id
  redisKey = ["lastAccessUpdate", userId].join(":") # "lastAccessUpdate:user1"

  redis.get redisKey, (err, result) ->
    if err?
      return next(err)

    # If it's been less than an hour since the last update,
    # return early.  We won't worry about updating lastAccess
    if result?
      return next()

    # Otherwise, save the user's last access to the database.
    updateUserAccess userId, (err) ->
      if err?
        return next(err)

      # And save a token indicating that we've updated last access
      # to Redis, with an expiration of 1 hour (3600 seconds)
      redis.setex redisKey, 3600, true, next