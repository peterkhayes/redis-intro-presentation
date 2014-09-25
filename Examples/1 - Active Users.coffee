###############################################################
# Example 1 - Getting accurate daily and weekly active lists. #
###############################################################

# In this example, we're going to make an express middleware that keeps
# counts of our site's active users, by day.  We'll then write functions
# that query redis to get the active users by day and by week.

# Code for Express middleware
activeUsersMiddleware = (req, res, next) ->

  # Make a key representing the number of active users today.
  date = new Date()
  dayString = date.toISOString().slice(0, 10) # "YYYY-MM-DD"
  dayKey = ["activeUsers", dayString].join(":") # "activeUsers:YYYY-MM-DD"

  # The id of the current user.
  userId = req.user.id

  # Also see: Hyperloglog!  Because aww yeah.
  redis.sadd dayKey, userId, next

# To query daily active users (given a javascript date).
getDailyActiveUsers = (date, callback) ->

  # Make the same key string
  dayString = date.toISOString().slice(0, 10)
  key = ["activeUsers", dayString].join(":")

  # `smembers` returns an array of set members
  redis.smembers key, callback

# To query weekly active users, given the initial day.
getWeeklyActiveUsers = (date, callback) ->

  # Get redis keys for each day this week.
  keys = [0..7].map (n) ->
    today = new Date(date + i*86400000) # 86,400,000 is the number of ms in a day.
    dayString = today.toISOString().slice(0, 10)
    return ["activeUsers", dayString].join(":")

  # `sunion` returns an array of the union of several sets.
  redis.sunion keys, callback