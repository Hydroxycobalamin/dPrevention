dPrevention_saver:
    type: world
    debug: false
    events:
    #Save denizen files every 15 minutes to prevent data loss on crash.
        on system time minutely every:15:
        - adjust server save