dPrevention_chat_tasks:
    type: task
    debug: false
    chat_input_cancel:
    - flag <player> dPrevention.chat_input:!
    - flag <[data.area]> dPrevention.in_use.<player.uuid>:!
    chat_input_reapply:
    - flag <player> dPrevention.chat_input:<player.flag[dPrevention.chat_input]> expire:30s
    - flag <[data.area]> dPrevention.in_use.<player.uuid> expire:30s
    add_bypass_user:
    - define message <context.message.split.first>
    - define flag <[data.flag]>
    - if <[message]> == cancel:
        - inject <script> path:chat_input_cancel
        - narrate "Add users to bypass <[flag]> cancelled." format:dPrevention_format
        - stop
    - define player <server.match_offline_player[<[message]>].if_null[null]>
    - if <[player]> == null:
        - narrate "This user doesn't exist." format:dPrevention_format
        - inject <script> path:chat_input_cancel
        - stop
    - if <[player].uuid.is_in[<[data.area].flag[dPrevention.permissions.<[flag]>].if_null[<list>]>]>:
        - flag <[data.area]> dPrevention.permissions.<[flag]>:<-:<[player].uuid>
        - narrate "<[player].name.custom_color[emphasis]> isn't whitelisted to bypass <[flag].custom_color[emphasis]> anymore." format:dPrevention_format
        - inject <script> path:chat_input_cancel
        - stop
    - flag <[data.area]> dPrevention.permissions.<[flag]>:->:<[player].uuid>
    - narrate "<[player].name.custom_color[emphasis]> is whitelisted to bypass <[flag].custom_color[emphasis]>" format:dPrevention_format
    - inject <script> path:chat_input_cancel
    ## Rename
    rename_area:
    - define name "<context.message.trim_to_character_set[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890&# ]>"
    - flag <[data.area]> dPrevention.name:<white><[name].parse_color>
    - narrate "You're claim was renamed to '<white><[name].parse_color><&[base]>'" format:dPrevention_format
    - inject <script> path:chat_input_cancel
    set_priority:
    - define integer <context.message.split.first>
    - if !<[integer].is_integer>:
        - narrate "You must provide an integer!" format:dPrevention_format
        - inject <script> path:chat_input_cancel
        - stop
    - flag <[data.area]> dPrevention.priority:<[integer]>
    - narrate "The Claims priority was set to <[integer].custom_color[emphasis]>" format:dPrevention_format
    - inject <script> path:chat_input_cancel
    remove_area:
    - if <context.message.split.first> != delete:
        - narrate "This claim was not removed." format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - flag <[data.area]> dPrevention.in_delete:!
        - stop
    - if <[data.holder]> == null:
        - narrate "The claim <[data.area].note_name.custom_color[emphasis]> was removed." format:dPrevention_format
        - run dPrevention_area_admin_removal def.data:<[data]>
        - flag <player> dPrevention.chat_input:!
        - flag <[data.area]> dPrevention.in_delete:!
        - stop
    - narrate "This claim was removed. You received <[data.area].proc[dPrevention_get_costs].custom_color[emphasis]> blocks back!" format:dPrevention_format
    - run dPrevention_area_removal def:<[data.area]>|<[data.holder]>
    - flag <player> dPrevention.chat_input:!
    - flag <[data.area]> dPrevention.in_delete:!
    add_flag:
    - if <context.message.split.first> == cancel:
        - narrate "Adding or removing flags cancelled." format:dPrevention_format
        - inject <script> path:chat_input_cancel
        - stop
    - define flag <[data.flag]>
    - define area <[data.area]>
    - choose <[flag]>:
        - case entities:
            - define entities <context.message.split>
            - define entity_types <server.entity_types.exclude[PLAYER].parse[as_entity]>
            #Matcherhandling
            - foreach monster|animal|mob|living as:matcher:
                - if <[entities].contains[<[matcher]>]>:
                    - define entities <[entities].replace[<[matcher]>].with[<[entity_types].filter[advanced_matches[<[matcher]>]].parse[entity_type]>]>
            - foreach <[entities].combine.deduplicate> as:entity:
                #If a provided entity is not a valid entity, stop.
                - if <entity[<[entity]>].if_null[null]> == null:
                    - narrate "<[entity].custom_color[emphasis]> is not a valid entity. Try again or Type cancel. 30 Seconds." format:dPrevention_format
                    - inject <script> path:chat_input_reapply
                    - stop
                #If the entity is already in the list, remove it.
                - if <[area].flag[dPrevention.flags.<[flag]>].if_null[<list>].contains[<[entity]>]>:
                    - flag <[area]> dPrevention.flags.<[flag]>:<-:<[entity]>
                    - foreach next
                #If the entity is not in the list, add it.
                - flag <[area]> dPrevention.flags.<[flag]>:->:<[entity]>
            #If the list of entities is empty, remove the flag.
            - if <[area].flag[dPrevention.flags.<[flag]>].is_empty>:
                - flag <[area]> dPrevention.flags.<[flag]>:!
                - inject <script> path:chat_input_cancel
                - narrate "This claim doesn't prevent any entity anymore." format:dPrevention_format
                - stop
            - inject <script> path:chat_input_cancel
            - narrate "This claim prevents <[area].flag[dPrevention.flags.<[flag]>].space_separated.to_titlecase.custom_color[emphasis]> from spawning." format:dPrevention_format
        - case vehicle-place:
            - define vehicles <context.message.split>
            - define vehicle_types <server.material_types.filter[advanced_matches[*boat|*minecart]].parse[name]>
            #Matcherhandling
            - if <[vehicles].contains[all]>:
                - define vehicles <[vehicle_types]>
            - foreach <[vehicles]> as:vehicle:
                #If a provided vehicle is not a valid vehicle, stop.
                - if !<[vehicle_types].contains[<[vehicle]>]>:
                    - narrate "<[entity].custom_color[emphasis]> is not a valid vehicle. Try again or Type cancel. 30 Seconds." format:dPrevention_format
                    - inject <script> path:chat_input_reapply
                    - stop
                #If the vehicle is already in the list, remove it.
                - if <[area].flag[dPrevention.flags.<[flag]>].if_null[<list>].contains[<[vehicle]>]>:
                    - flag <[area]> dPrevention.flags.<[flag]>:<-:<[vehicle].to_uppercase>
                    - foreach next
                #If the vehicle is not in the list, add it.
                - flag <[area]> dPrevention.flags.<[flag]>:->:<[vehicle].to_uppercase>
            #If the list of vehicles is empty, remove the flag.
            - if <[area].flag[dPrevention.flags.<[flag]>].is_empty>:
                - flag <[area]> dPrevention.flags.<[flag]>:!
                - inject <script> path:chat_input_cancel
                - narrate "This claim doesn't prevent any vehicle anymore." format:dPrevention_format
                - stop
            - inject <script> path:chat_input_cancel
            - narrate "This claim prevents <[area].flag[dPrevention.flags.<[flag]>].space_separated.to_titlecase.custom_color[emphasis]> from being placed." format:dPrevention_format
    add_ride_whitelist:
    - if <context.message.split.first> == cancel:
        - narrate "Adding players to the ride-whitelist cancelled." format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - stop
    - define player <server.match_offline_player[<context.message.split.first>].if_null[null]>
    - if <[player]> == null:
        - narrate "The player does not exist. Try again." format:dPrevention_format
        - stop
    - if <player.flag[dPrevention.ride_whitelist].contains[<[player].uuid>].if_null[false]>:
        - narrate "The player is already in your ride whitelist. Try again." format:dPrevention_format
        - stop
    - flag <player> dPrevention.ride_whitelist:->:<[player].uuid>
    - flag <player> dPrevention.chat_input:!
    - narrate "<[player].name.custom_color[emphasis]> was sucessfully added to your ride whitelist!" format:dPrevention_format
    remove_ride_whitelist:
    - if <context.message.split.first> == cancel:
        - narrate "Removing players from the ride-whitelist cancelled." format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - stop
    - define player <server.match_offline_player[<context.message.split.first>].if_null[null]>
    - if <[player]> == null:
        - narrate "The player does not exist. Try again." format:dPrevention_format
        - stop
    - if !<player.flag[dPrevention.ride_whitelist].contains[<[player].uuid>].if_null[false]>:
        - narrate "The player is not in your ride whitelist. Try again." format:dPrevention_format
        - stop
    - flag <player> dPrevention.ride_whitelist:<-:<[player].uuid>
    - flag <player> dPrevention.chat_input:!
    - narrate "<[player].name.custom_color[emphasis]> was sucessfully removed from your ride whitelist!" format:dPrevention_format
    script:
    - inject <script> path:<player.flag[dPrevention.chat_input.type]>
dPrevention_chat_handler:
    type: world
    debug: false
    events:
        on player chats flagged:dPrevention.chat_input ignorecancelled:true priority:-100:
        - determine cancelled passively
        - define data <player.flag[dPrevention.chat_input]>
        - inject dPrevention_chat_tasks