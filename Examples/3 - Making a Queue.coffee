##############################
# Example 3 - Making a Queue #
##############################

# In this example, we're going to use redis to implement a queue.
# Our queue will be able to enqueue tasks, report its size, and reset.
# The queue will automatically begin passing tasks one at a time
# to a given processor function. 

makeRedisQueue = (queueName, processor) ->

  processNext = () ->
    # To process an item, pop from the left side of the list.
    redis.lpop queueName, (err, item) ->
      # If the queue is empty or errors, wait 100ms before trying again.
      if err? or not item
        setTimeout(processNext, 100)

      # Otherwise, send the item to the processor, passing processNext
      # as a callback, so we move on to the next item immediately.
      processor(item, processNext)


  return {
    # The enqueue function pushes the item into the redis list.
    enqueue: (task, callback) ->
      redis.rpush queueName, task, callback

    # The size function returns the length of the list.
    size: (callback) ->
      redis.llen queueName, callback

    # The clear function deletes the list at the given key.
    clear: (callback) ->
      redis.del queueName, callback
  }