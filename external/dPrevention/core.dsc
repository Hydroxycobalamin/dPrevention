dPrevention_initial_block_check:
    #This task MUST be injected. Provide a map called arguments, with flag:<ElementTag> and location:<LocationTag>
    #It's called by dPrevention_generic_flag_handlers
    type: task
    definitions: arguments
    debug: false
    script:
    - define area <[arguments.location].proc[dPrevention_get_areas]>
    - if <[area].proc[dPrevention_check_flag].context[<[arguments.flag]>]>:
        - stop
    - determine cancelled
dPrevention_initial_check:
    #This task MUST be injected. Provide map called arguments, with flag:<ElementTag> location:<LocationTag> and reason:<ElementTag>
    #It's called by dPrevention_player_flag_handlers
    type: task
    debug: false
    definitions: arguments
    script:
    #Allow players to bypass the flag, if they have the specific permission.
    - if <player.has_permission[dPrevention.bypass.<[arguments.flag]>]>:
        - stop
    - inject dPrevention_check_membership
    - determine cancelled passively
    - ratelimit <player> 2s
    - narrate <[arguments.reason]> format:dPrevention_format
dPrevention_check_membership:
    #This task MUST be injected.
    type: task
    debug: false
    script:
    ##Avoid multifiring of this task by flagging the player, if he's allowed
    - if <player.has_flag[dPrevention.allow.<[arguments.flag]>.<[arguments.location].simple>]>:
        - stop
    #Check if player is inside an dPrevention area
    - define area <[arguments.location].proc[dPrevention_get_areas]>
    #Check for flags
    - if <[area].proc[dPrevention_check_flag].context[<[arguments.flag]>]>:
        ##Flag the player to reduce multifiring if he's inside a claim and the world is also flagged, if no dPrevention.allow flag is applied, events with world_flagged matchers would run too.
        - flag <player> dPrevention.allow.<[arguments.flag]>.<[arguments.location].simple> expire:1t
        - stop
    #If he is owner of the region on this location, stop the queue
    - if <[area].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>:
        - stop
    #Event cancelled
dPrevention_check_flag:
    type: procedure
    debug: false
    definitions: area|flag
    script:
    #If the user is whitelisted in this area to bypass the flag, allow it.
    - if <[area].flag[dPrevention.permissions.<[flag]>].contains[<player.uuid.if_null[null]>].if_null[false]>:
        - determine true
    #If an area doesn't allow it, stop
    - if <[area].has_flag[dPrevention.flags.<[flag]>]>:
        - determine false
    - else:
        #Allow it
        - determine true
dPrevention_get_areas:
    type: procedure
    debug: false
    definitions: location
    script:
    - determine <[location].cuboids.include[<[location].ellipsoids>].include[<[location].polygons>].filter[has_flag[dPrevention]].sort_by_number[flag[dPrevention.priority]].first.if_null[<[location].world>]>