dPrevention_chat_tasks:
    type: task
    debug: false
    add_bypass_user:
    - define message <context.message.split.first>
    - define flag <[data.flag]>
    - if <[message]> == cancel:
        - flag <player> dPrevention.chat_input:!
        - narrate "Add users to bypass <[flag]> cancelled." format:dPrevention_format
        - stop
    - define player <server.match_offline_player[<[message]>].if_null[null]>
    - if <[player]> == null:
        - narrate "This user doesn't exist." format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - stop
    - if <[player].uuid.is_in[<[data.area].flag[dPrevention.permissions.<[flag]>].if_null[<list>]>]>:
        - flag <[data.area]> dPrevention.permissions.<[flag]>:<-:<[player].uuid>
        - narrate "<[player].name.custom_color[emphasis]> isn't whitelisted to bypass <[flag].custom_color[emphasis]> anymore." format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - stop
    - flag <[data.area]> dPrevention.permissions.<[flag]>:->:<[player].uuid>
    - narrate "<[player].name.custom_color[emphasis]> is whitelisted to bypass <[flag].custom_color[emphasis]>" format:dPrevention_format
    - flag <player> dPrevention.chat_input:!
    rename_area:
    - define name "<context.message.trim_to_character_set[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890&# ]>"
    - flag <[data.claim]> dPrevention.name:<white><[name].parse_color>
    - narrate "You're claim was renamed to '<white><[name].parse_color><&[base]>'" format:dPrevention_format
    - flag <player> dPrevention.chat_input:!
    set_priority:
    - define integer <context.message.split.first>
    - if !<[integer].is_integer>:
        - narrate "You must provide an integer!" format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - stop
    - flag <[data.claim]> dPrevention.priority:<[integer]>
    - narrate "The Claims priority was set to <[integer].custom_color[emphasis]>" format:dPrevention_format
    - flag <player> dPrevention.chat_input:!
    remove_area:
    - if <context.message.split.first> != delete:
        - narrate "This claim was not removed." format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - stop
    - if <[data.holder]> == null:
        - narrate "The claim <[data.claim].note_name.custom_color[emphasis]> was removed." format:dPrevention_format
        - run dPrevention_area_admin_removal def:<list_single[<[data]>]>
        - flag <player> dPrevention.chat_input:!
        - stop
    - narrate "This claim was removed. You received <[data.claim].proc[dPrevention_get_costs].custom_color[emphasis]> blocks back!" format:dPrevention_format
    - run dPrevention_area_removal def:<[data.claim]>|<[data.holder]>
    - flag <player> dPrevention.chat_input:!
    add_flag:
    - if <context.message.split.first> == cancel:
        - narrate "Adding or removing flags cancelled." format:dPrevention_format
        - flag <player> dPrevention.chat_input:!
        - stop
    - define flag <[data.flag]>
    - define area <[data.area]>
    - choose <[flag]>:
        - case entities:
            - define entities <context.message.split>
            - define entity_types <server.entity_types.exclude[PLAYER].parse[as_entity]>
            - foreach monster|animal|mob|living as:matcher:
                - if <[entities].contains[<[matcher]>]>:
                    - define entities <[entities].replace[<[matcher]>].with[<[entity_types].filter[advanced_matches[<[matcher]>]].parse[entity_type]>]>
            - foreach <[entities].combine> as:entity:
                #If an provided entity is not a valid entity, stop.
                - if <entity[<[entity]>].if_null[null]> == null:
                    - narrate "<[entity].custom_color[emphasis]> is not a valid entity. Try again or Type cancel. 30 Seconds." format:dPrevention_format
                    - flag <player> dPrevention.chat_input:<player.flag[dPrevention.chat_input]> expire:30s
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
                - flag <player> dPrevention.chat_input:!
                - narrate "This claims doesn't prevent any entity anymore." format:dPrevention_format
                - stop
            - flag <player> dPrevention.chat_input:!
            - narrate "This claim prevents <[area].flag[dPrevention.flags.<[flag]>].space_separated.to_titlecase.custom_color[emphasis]> from spawning." format:dPrevention_format
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
        on player chats flagged:dPrevention.chat_input:
        - determine cancelled passively
        - define data <player.flag[dPrevention.chat_input]>
        - inject dPrevention_chat_tasks