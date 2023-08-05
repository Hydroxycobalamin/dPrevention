## <--[script]
## @name dPrevention
## @group LargeScripts
## @description
## dPrevention is an script that prevents grief and let your players claim their land on your Minecraft server.
##
## Players can claim their areas by using a currency called "blocks". These blocks can be obtained through playtime or can be purchased in a shop.
## Players can expand and shrink the areas using the dPrevention tool, which they can acquire by executing the "/dPrevention tool" command.
## They also have the ability to add or remove flags to their claims, if they have the appropriate permission to do so. Also it's possible to let specific players bypass these flags.
## To view information about their blocks and current claims, players can utilize the "/dPrevention info" command.
## There are limitations on the number of blocks players can obtain. They can acquire a maximum of 2000 blocks at a time and receive 25 blocks every 5 minutes. These values can be adjusted in the configuration settings.
##
## Administrators have additional privileges in the dPrevention system. They can create admin claims using commands such as /dPrevention [cuboid/ellipsoid/polygon] [<name>].
## Admin claims can be managed through the /dprevention admininfo command.
## Administrators can access information about player claims by using the /dprevention info <name> command.
## Administrators can bypass flags if they possess the necessary permission, which follows the format: dPrevention.bypass.<flag>.
##
## By default, a claim extends from ground level to the maximum height limit. However, the default depth can be adjusted in the configuration settings, which is particularly useful for 1.18+ servers.
## Claims have a priority system, primarily beneficial for admin claims. However, this feature is currently unavailable to players.
## Vehicles are protected as long as the vehicle-hijacking configuration option is set to false.
##
## @Download https://forum.denizenscript.com/resources/dprevention.76/
## -->
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
    - ratelimit <player.uuid>/<[arguments.flag]> 2s
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
    #Return all dPrevention areas, if null return the current world.
    - determine <[location].areas[area_flagged:dPrevention].sort_by_number[flag[dPrevention.priority]].first.if_null[<[location].world>]>