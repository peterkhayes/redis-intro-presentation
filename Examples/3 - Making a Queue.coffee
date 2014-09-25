##############################
# Example 3 - Making a Queue #
##############################

# In this example, we're going to use redis to implement a queue.
# Our queue will be able to enqueue tasks, report its size, and reset.
# The queue will automatically begin passing tasks one at a time
# to a given processor function. 

makeRedisQueue = (queueName, processor) ->

  redisKey = ["queue", queueName].join(":") # "queue:listOfTasks"

  # Make the queue that we're going to return.
  queue = {
    # The enqueue function pushes the item into the redis list.
    enqueue: (task, callback) ->
      redis.rpush redisKey, JSON.stringify(task), callback

    # The size function returns the length of the list.
    size: (callback) ->
      redis.llen redisKey, callback

    # The clear function deletes the list at the given key.
    clear: (callback) ->
      redis.del redisKey, callback
  }

  # Define a function that will take items out of the
  # queue, one by one, and send them to the processor.
  
  # Let's assume that the processor is a function that takes
  # two arguments - an item and a callback, does some action
  # to the item, then calls the callback.
  processNext = () ->
    # To process an item, pop from the left side of the list.
    redis.lpop redisKey, (err, item) ->
      # If the queue is empty or errors, wait 1 second before trying again.
      if err? or not item
        setTimeout(processNext, 1000)

      # Otherwise, send the item to the processor, passing processNext
      # as a callback, so we move on to the next item immediately.
      processor(JSON.parse(item), processNext)

  # Begin processing.
  processNext()
  
  return queue