#TODO: dynmap support
dPrevention_flag_GUI_handler:
    type: world
    debug: false
    data:
        chat_input:
        - entities
    events:
        on player chats flagged:dPrevention.add_flag:
        - determine cancelled passively
        - if <context.message.split.first> == cancel:
            - narrate "Adding or removing flags cancelled." format:dPrevention_format
            - flag <player> dPrevention.add_flag:!
            - stop
        - define flag <player.flag[dPrevention.add_flag.flag]>
        - define area <player.flag[dPrevention.flaggui]>
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
                        - flag <player> dPrevention.add_flag.flag:<[flag]> expire:30s
                        - flag <player> dPrevention.add_flag.area:<[area]> expire:30s
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
                    - flag <player> dPrevention.add_flag:!
                    - narrate "This claims doesn't prevent any entity anymore." format:dPrevention_format
                    - stop
                - flag <player> dPrevention.add_flag:!
                - narrate "This claim prevents <[area].flag[dPrevention.flags.<[flag]>].space_separated.to_titlecase.custom_color[emphasis]> from spawning." format:dPrevention_format
        after player left clicks item_flagged:flag in dPrevention_flag_GUI:
        - define flag <context.item.flag[flag]>
        #If the player doesn't have permission to change the flag stop.
        - if !<player.has_permission[dPrevention.flag.<[flag]>]>:
            - narrate "You don't have permission to change the <[flag].custom_color[emphasis]> flag." format:dPrevention_format
            - stop
        #If a flag needs separate input. Listen to the chat event.
        - if <script.data_key[data.chat_input].contains[<[flag]>]>:
            - flag <player> dPrevention.add_flag.area:<player.flag[dPrevention.flaggui]> expire:30s
            - flag <player> dPrevention.add_flag.flag:<[flag]> expire:30s
            - narrate "Type the strings. Seperate multiple by space. 30 Seconds." format:dPrevention_format
            - inventory close
            - stop
        - define area <player.flag[dPrevention.flaggui]>
        #If the flag is set to false, display true.
        - if <[area].has_flag[dPrevention.flags.<[flag]>]>:
            - flag <[area]> dPrevention.flags.<[flag]>:!
            - inventory adjust slot:<context.slot> lore:<script[dPrevention_fill_flag_GUI].parsed_key[data.format.allowed]> destination:<player.open_inventory>
        #Else display false.
        - else:
            - flag <[area]> dPrevention.flags.<[flag]>
            - inventory adjust slot:<context.slot> lore:<script[dPrevention_fill_flag_GUI].parsed_key[data.format.denied]> destination:<player.open_inventory>
        after player shift_right clicks item_flagged:flag in dPrevention_flag_GUI:
        #Checks for all users which are whitelisted on this claim to bypass the flag.
        - define flag <context.item.flag[flag]>
        - define users <player.flag[dPrevention.flaggui].flag[dPrevention.permissions.<[flag]>].if_null[<list>].parse[as_player]>
        - if <[users].is_empty>:
            - narrate "The are no players whitelisted for <[flag].custom_color[emphasis]>" format:dPrevention_format
            - inventory close
            - stop
        - narrate <[users].parse[name].space_separated.custom_color[emphasis]> format:dPrevention_format
        - inventory close
        after player shift_left clicks item_flagged:flag in dPrevention_flag_GUI:
        - define flag <context.item.flag[flag]>
        - if !<script[dPrevention_flag_data].data_key[player_flags].contains[<[flag]>]>:
            - narrate "You can't whitelist a player on the flag <[flag].custom_color[emphasis]>!" format:dPrevention_format
            - inventory close
            - stop
        #Listen to the Chat event, to allow specific players to bypass the player related flag.
        - flag <player> dPrevention.add_bypass_user.area:<player.flag[dPrevention.flaggui]> expire:30s
        - flag <player> dPrevention.add_bypass_user.flag:<context.item.flag[flag]> expire:30s
        - narrate "Type the name of the player into the chat, to add or remove him. Write cancel, to cancel it." format:dPrevention_format
        - inventory close
        on player chats flagged:dPrevention.add_bypass_user:
        - determine cancelled passively
        - define message <context.message.split.first>
        - define flag <player.flag[dPrevention.add_bypass_user.flag]>
        - if <[message]> == cancel:
            - flag <player> dPrevention.add_bypass_user:!
            - narrate "Add users to bypass <[flag]> cancelled." format:dPrevention_format
            - stop
        - define player <server.match_offline_player[<[message]>].if_null[null]>
        - if <[player]> == null:
            - narrate "This user doesn't exist." format:dPrevention_format
            - flag <player> dPrevention.add_bypass_user:!
            - stop
        - if <[player].is_in[dPrevention.permissions.<[flag]>]>:
            - flag <player.flag[dPrevention.add_bypass_user.area]> dPrevention.permissions.<[flag]>:<-:<[player].uuid>
            - narrate "<player.name.custom_color[emphasis]> isn't whitelisted to bypass <[flag].custom_color[emphasis]> anymore." format:dPrevention_format
            - flag <player> dPrevention.add_bypass_user:!
            - stop
        - flag <player.flag[dPrevention.add_bypass_user.area]> dPrevention.permissions.<[flag]>:->:<[player].uuid>
        - narrate "<player.name.custom_color[emphasis]> is whitelisted to bypass <[flag].custom_color[emphasis]>" format:dPrevention_format
        - flag <player> dPrevention.add_bypass_user:!
dPrevention_flag_GUI:
    type: inventory
    debug: false
    inventory: CHEST
    title: Flags
    gui: true
    size: 27
dPrevention_fill_flag_GUI:
    type: task
    data:
        format:
            display: <[flag].color[gray]>
            denied:
            - <dark_gray>Status: <red>Denied
            allowed:
            - <dark_gray>Status: <green>Allowed
            input:
            - <dark_gray>Denied<&co>
            - <[status].split[<n>].parse_tag[<[parse_value].color[red]>].separated_by[<n>]>
    debug: false
    definitions: area
    script:
    #Check if it's already a dclaim first.
    - if !<[area].has_flag[dPrevention]> && !<world[<[area]>].exists>:
        - inject dPrevention_check_dclaim
        - stop
    #Loop through all existing flags.
    - foreach <script[dPrevention_flag_data].data_key[flags]> key:item as:flag:
        - if <[area].has_flag[dPrevention.flags.<[flag]>]>:
            - define lore <script.parsed_key[data.format.denied]>
            #If the flag has additional input, separate it into three entries per line.
            - if <[flag].is_in[<script[dPrevention_flag_GUI_handler].data_key[data.chat_input]>]>:
                - define status <[area].flag[dPrevention.flags.<[flag]>].alphabetical.space_separated.split_lines_by_width[240]>
                - define lore <script.parsed_key[data.format.input]>
        - else:
            - define lore <script.parsed_key[data.format.allowed]>
        - define items:->:<item[<[item]>].with[display=<script.parsed_key[data.format.display]>;lore=<[lore]>;hides=ALL].with_flag[flag:<[flag]>]>
        - define bool:!
    - flag <player> dPrevention.flaggui:<[area]>
    - inventory open destination:dPrevention_flag_GUI
    - wait 1t
    - inventory set origin:<[items]> destination:<player.open_inventory>
dPrevention_generate_clickables:
    type: task
    debug: false
    definitions: areas
    script:
    - foreach <[areas]> as:area:
        - clickable dPrevention_fill_flag_GUI def:<[area]> for:<player> until:1m save:<[loop_index]>
        - define clickables:->:<[area].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[area].note_name>]>
    - narrate <[clickables].space_separated.custom_color[emphasis]> format:dPrevention_format