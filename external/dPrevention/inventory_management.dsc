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


dPrevention_info_data:
    type: procedure
    debug: false
    data:
        cuboid:
        - <&[base]>Location: <[data.min].custom_color[emphasis]> to <[data.max].custom_color[emphasis]> in <[data.world].custom_color[emphasis]>
        - <&[base]>Size: <[data.size].color[#00ccff]> Priority: <[data.priority].custom_color[emphasis]>
        - <&[base]>Costs: <[data.costs].color[#cc0066]>
        polygon:
        - <[data.corner].parse_tag[<&[base]>Corner: <[parse_value].custom_color[emphasis]>].separated_by[<n>]>
        - <&[base]>World: <[data.world].custom_color[emphasis]> Priority: <[data.priority].custom_color[emphasis]>
        - <&[base]>Height: <[data.min_y].custom_color[emphasis]> to <[data.max_y].custom_color[emphasis]>
        ellipsoid:
        - <&[base]>Priority: <[data.priority].custom_color[emphasis]>
        - <&[base]>Location: <[data.location].custom_color[emphasis]> in <[data.world].custom_color[emphasis]>
    definitions: areas|player
    script:
    - define page 1
    - foreach <[areas]> key:type as:areas:
        - choose <[type]>:
            - case cuboids:
                - repeat <[areas].size>:
                    - define area <[areas].get[<[value]>]>
                    - definemap data "min:<[area].min.xyz.replace_text[,].with[ ]>" "max:<[area].max.xyz.replace_text[,].with[ ]>" world:<[area].world.name> "size:<[area].size.xyz.replace_text[,].with[ ]>" costs:<[area].proc[dPrevention_get_costs]> priority:<[area].flag[dPrevention.priority]>
                    - define inventory_menu.pages.<[page]>:->:<item[dPrevention_menu_item].with[lore=<script.parsed_key[data.cuboid]>].with_flag[claim:<[area]>].with_flag[holder:<[player]>].with_flag[type:<[type]>]>
                    - if <[loop_index].mod[45]> == 0:
                        - define page:++
            - case polygons:
                - repeat <[areas].size>:
                    - define area <[areas].get[<[value]>]>
                    - definemap data "corner:<[area].corners.parse_tag[<[parse_value].xyz.replace_text[,].with[ ]>]>" world:<[area].world.name> min_y:<[area].min_y> max_y:<[area].max_y> priority:<[area].flag[dPrevention.priority]>
                    - define inventory_menu.pages.<[page]>:->:<item[dPrevention_menu_item].with[lore=<script.parsed_key[data.polygon]>].with_flag[claim:<[area]>].with_flag[holder:<[player]>].with_flag[type:<[type]>]>
                    - if <[loop_index].mod[45]> == 0:
                        - define page:++
            - case ellipsoids:
                - repeat <[areas].size>:
                    - define area <[areas].get[<[value]>]>
                    - definemap data "location:<[area].location.xyz.replace_text[,].with[ ]>" world:<[area].world.name> priority:<[area].flag[dPrevention.priority]>
                    - define inventory_menu.pages.<[page]>:->:<item[dPrevention_menu_item].with[lore=<script.parsed_key[data.ellipsoid]>].with_flag[claim:<[area]>].with_flag[holder:<[player]>].with_flag[type:<[type]>]>
                    - if <[loop_index].mod[45]> == 0:
                        - define page:++
    #Dummy if there aren't any claims yet.
    - if !<[inventory_menu.pages.1].exists>:
        - define inventory_menu.pages.1:<list[air]>
    - determine <[inventory_menu]>
dPrevention_info_formatter:
    debug: false
    type: task
    definitions: cuboids|polygons|ellipsoids|player
    script:
    - definemap areas cuboids:<[cuboids].if_null[<list>]> polygons:<[polygons].if_null[<list>]> ellipsoids:<[ellipsoids].if_null[<list>]>
    - define data <[areas].proc[dPrevention_info_data].context[<[player]>]>
    - flag <player> dPrevention.inventory_menu:<[data]>
    - inventory open destination:dPrevention_menu
    - wait 1t
    - inventory set origin:<[data.pages.1]> destination:<player.open_inventory>
dPrevention_menu:
    type: inventory
    debug: false
    inventory: CHEST
    title: Menu
    gui: true
    definitions:
        blocks: <item[dPrevention_menu_item].with[display=<white>Blocks;lore=<element[From play:].color_gradient[from=#009933;to=#00ff55]> <player.flag[dPrevention.blocks.amount.per_time].if_null[0]>|<element[From blocks:].color_gradient[from=#009933;to=#00ff55]> <player.flag[dPrevention.blocks.amount.per_block].if_null[0]>|<element[In Use:].color_gradient[from=#ff3399;to=#cc0066]> <player.flag[dPrevention.blocks.amount.in_use].if_null[0]>|<element[Left to spent:].color_gradient[from=#00ffff;to=#009999]> <player.proc[dPrevention_get_blocks]>]>
        page: <item[dPrevention_page_item].with[display=<white>Page;lore=Current Page:1/<player.flag[dPrevention.inventory_menu.pages].keys.highest>].with_flag[page:1]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [blocks] [] [] [page] []
dPrevention_menu_item:
    type: item
    debug: false
    material: grass_block
    display name: <white>Claim
dPrevention_page_item:
    type: item
    debug: false
    material: stone
dPrevention_menu_handler:
    type: world
    debug: false
    pager:
    - define max <player.flag[dPrevention.inventory_menu.pages].keys.highest>
    - if !<player.has_flag[dPrevention.inventory_menu.pages.<[page]>]>:
        - stop
    - inventory set origin:<player.flag[dPrevention.inventory_menu.pages.<[page]>]> destination:<player.open_inventory>
    - inventory flag slot:<context.slot> page:<[page]> destination:<player.open_inventory>
    - inventory set "origin:<context.item.with[lore=Current Page:<[page]>/<[max]>].with_flag[page:<[page]>]>" slot:<context.slot> destination:<player.open_inventory>
    events:
        after player left clicks dPrevention_page_item in dPrevention_menu:
        - define page <context.item.flag[page].add[1]>
        - inject <script> path:pager
        after player right clicks dPrevention_page_item in dPrevention_menu:
        - define page <context.item.flag[page].sub[1]>
        - inject <script> path:pager
        after player left clicks dPrevention_menu_item in dPrevention_menu:
        - run dPrevention_fill_flag_GUI def:<context.item.flag[claim]>
        after player right clicks dPrevention_menu_item in dPrevention_menu:
        - definemap data claim:<context.item.flag[claim]> holder:<context.item.flag[holder]> type:<context.item.flag[type]>
        - flag <player> dPrevention.remove_area:<[data]> expire:30s
        - inventory close
        - narrate "Type 'delete' if want to remove this area." format:dPrevention_format
        after player shift_left clicks dPrevention_menu_item in dPrevention_menu:
        - if !<player.has_permission[dPrevention.admin]>:
            - narrate "You're not allowed to change the priority of your claim." format:dPrevention_format
            - inventory close
            - stop
        - narrate "Type an integer to change it's priority." format:dPrevention_format
        - flag <player> dPrevention.type_integer:<context.item.flag[claim]> expire:30s
        - inventory close
        on player chats flagged:dPrevention.type_integer:
        - determine passively cancelled
        - define integer <context.message.split.first>
        - if !<[integer].is_integer>:
            - narrate "You must provide an integer!" format:dPrevention_format
            - flag <player> dPrevention.type_integer:!
            - stop
        - flag <player.flag[dPrevention.type_integer]> dPrevention.priority:<[integer]>
        - narrate "The Claims priority was set to <[integer].custom_color[emphasis]>" format:dPrevention_format
        - flag <player> dPrevention.type_integer:!
        on player chats flagged:dPrevention.remove_area:
        - determine cancelled passively
        - if <context.message.split.first> != delete:
            - narrate "This claim was not removed." format:dPrevention_format
            - flag <player> dPrevention.remove_area:!
            - stop
        - define data <player.flag[dPrevention.remove_area]>
        - if <player.flag[dPrevention.remove_area.holder]> == null:
            - narrate "The claim <[data.claim].note_name.custom_color[emphasis]> was removed." format:dPrevention_format
            - run dPrevention_area_admin_removal def:<list_single[<[data]>]>
            - stop
        - narrate "This claim was removed. You received <[data.claim].proc[dPrevention_get_costs].custom_color[emphasis]> blocks back!" format:dPrevention_format
        - run dPrevention_area_removal def:<[data.claim]>|<player.flag[dPrevention.remove_area.holder]>
        - flag <player> dPrevention.remove_area:!