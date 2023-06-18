dPrevention_flag_GUI_handler:
    type: world
    debug: false
    data:
        chat_input:
        - entities
        - vehicle-place
    events:
        after player left clicks item_flagged:flag in dPrevention_flag_GUI:
        - define flag <context.item.flag[flag]>
        #If the player doesn't have permission to change the flag stop.
        - if !<player.has_permission[dPrevention.flag.<[flag]>]>:
            - narrate "You don't have permission to change the <[flag].custom_color[emphasis]> flag." format:dPrevention_format
            - stop
        #If a flag needs separate input. Listen to the chat event.
        - if <script.data_key[data.chat_input].contains[<[flag]>]>:
            - definemap data area:<player.flag[dPrevention.flaggui]> flag:<[flag]> type:add_flag
            - flag <player> dPrevention.chat_input:<[data]> expire:30s
            - choose <[flag]>:
                - case entities:
                    - narrate "Type the entity type in chat. Seperate multiple by space. Valid matchers are: monster, animal, mob, living." format:dPrevention_format
                - case vehicle-place:
                    - narrate "Type the vehicle type in chat. Seperate multiple by space. Valid matcher is: all" format:dPrevention_format
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
        - definemap data type:add_bypass_user area:<player.flag[dPrevention.flaggui]> flag:<context.item.flag[flag]>
        - flag <player> dPrevention.chat_input:<[data]> expire:30s
        - narrate "Type the name of the player into the chat, to add or remove him. Write cancel, to cancel it." format:dPrevention_format
        - inventory close
        after player closes dPrevention_flag_GUI flagged:dPrevention.flaggui:
        - flag <player.flag[dPrevention.flaggui]> dPrevention.in_use.<player.uuid>:!
dPrevention_flag_GUI:
    type: inventory
    data:
        info_lore:
        - <gold>Left-Click<&co>
        - <&[base]>Toggle flag
    #    - <gold>Right-Click<&co>
        - <gold>Shift-Rightclick<&co>
        - <&[base]>List whitelisted players
        - <gold>Shift-Leftclick<&co>
        - <&[base]>Whitelist player
    debug: false
    inventory: CHEST
    title: Flags
    gui: true
    definitions:
        info: <item[light].with[display=<white>Info;lore=<script.parsed_key[data.info_lore]>]>
        x: <server.flag[dPrevention.config.inventories.filler-item]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [x] [x] [x] [x] [info] [x] [x] [x] [x]
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
    - define config <server.flag[dPrevention.config.inventories]>
    # Check if it's already a dclaim first.
    - if !<[area].has_flag[dPrevention]> && !<world[<[area]>].exists>:
        - inject dPrevention_check_dclaim
        - stop
    # If the claim is in deletion, stop.
    - inject dPrevention_in_delete
    - flag <[area]> dPrevention.in_use.<player.uuid>
    # Loop through all existing flags.
    - foreach <script[dPrevention_flag_data].data_key[flags]> key:item as:flag:
        - if <[area].has_flag[dPrevention.flags.<[flag]>]>:
            - define lore <script.parsed_key[data.format.denied]>
            # If the flag has additional input, separate it into three entries per line.
            - if <[flag].is_in[<script[dPrevention_flag_GUI_handler].data_key[data.chat_input]>]>:
                - define status <[area].flag[dPrevention.flags.<[flag]>].alphabetical.space_separated.split_lines_by_width[240]>
                - define lore <script.parsed_key[data.format.input]>
        - else:
            - define lore <script.parsed_key[data.format.allowed]>
        # Config option hide-flag-permissions
        - if <[config.hide-flag-permissions]> && !<player.has_permission[dPrevention.flag.<[flag]>]>:
            - define item <[config.hide-flag-item]>
        - define items:->:<item[<[item]>].with[display=<script.parsed_key[data.format.display]>;lore=<[lore]>;hides=ALL].with_flag[flag:<[flag]>]>
    - flag <player> dPrevention.flaggui:<[area]>
    - inventory open destination:dPrevention_flag_GUI
    - wait 1t
    - inventory set origin:<[items]> destination:<player.open_inventory>
dPrevention_info_data:
    type: procedure
    debug: false
    data:
        cuboids:
        - <&[base]>Location: <[parse_value].min.xyz.replace_text[,].with[ ].custom_color[emphasis]> to <[parse_value].max.xyz.replace_text[,].with[ ].custom_color[emphasis]> in <[parse_value].world.name.custom_color[emphasis]>
        - <&[base]>Size: <[parse_value].size.xyz.replace_text[,].with[ ].color[#00ccff]> Priority: <[parse_value].flag[dPrevention.priority].custom_color[emphasis]>
        - <&[base]>Costs: <[parse_value].proc[dPrevention_get_costs].color[#cc0066]>
        polygons:
        - <[parse_value].corners.parse_tag[<&[base]>Corner: <[parse_value].xyz.replace_text[,].with[ ].custom_color[emphasis]>].separated_by[<n>]>
        - <&[base]>World: <[parse_value].world.name.custom_color[emphasis]> Priority: <[parse_value].flag[dPrevention.priority].custom_color[emphasis]>
        - <&[base]>Height: <[parse_value].min_y.custom_color[emphasis]> to <[parse_value].max_y.custom_color[emphasis]>
        ellipsoids:
        - <&[base]>Priority: <[parse_value].flag[dPrevention.priority].custom_color[emphasis]>
        - <&[base]>Location: <[parse_value].location.xyz.replace_text[,].with[ ].custom_color[emphasis]> in <[parse_value].world.name.custom_color[emphasis]>
    definitions: areas_map|player
    script:
    - define page 1
    # Save data from key to increase speed.
    - define data <script.data_key[data]>
    - foreach <[areas_map]> key:type as:areas:
        - choose <[type]>:
            - case cuboids:
                - define list:|:<[areas].parse_tag[dPrevention_menu_item[display=<[parse_value].flag[dPrevention.name].parse_color.if_null[<white>Claim]>;lore=<[data.<[type]>].unescaped.parsed>;flag=claim:<[parse_value]>;flag=holder:<[player]>;flag=type:<[type]>]]>
            - case polygons:
                - define list:|:<[areas].parse_tag[dPrevention_menu_item[display=<[parse_value].flag[dPrevention.name].parse_color.if_null[<white>Claim]>;lore=<[data.<[type]>].unescaped.parsed>;flag=claim:<[parse_value]>;flag=holder:<[player]>;flag=type:<[type]>]]>
            - case ellipsoids:
                - define list:|:<[areas].parse_tag[dPrevention_menu_item[display=<[parse_value].flag[dPrevention.name].parse_color.if_null[<white>Claim]>;lore=<[data.<[type]>].unescaped.parsed>;flag=claim:<[parse_value]>;flag=holder:<[player]>;flag=type:<[type]>]]>
    - define pages <[list].sub_lists[45].if_null[<list>]>
    #Dummy if there aren't any claims yet.
    - if <[pages].is_empty>:
        - define pages:->:air
    - determine <[pages]> passively
dPrevention_info_formatter:
    debug: false
    type: task
    definitions: cuboids|polygons|ellipsoids|player
    script:
    - definemap areas cuboids:<[cuboids].if_null[<list>]> polygons:<[polygons].if_null[<list>]> ellipsoids:<[ellipsoids].if_null[<list>]>
    - define pages <[areas].proc[dPrevention_info_data].context[<[player]>]>
    - flag <player> dPrevention.inventory_menu:<[pages]>
    - inventory open destination:dPrevention_menu
    - wait 1t
    - inventory set origin:<[pages].first> destination:<player.open_inventory>
dPrevention_menu:
    type: inventory
    data:
        block_lore:
        - <element[From play:].color_gradient[from=#009933;to=#00ff55]> <[player].if_null[<player>].flag[dPrevention.blocks.amount.per_time].if_null[0]>
        - <element[From blocks:].color_gradient[from=#009933;to=#00ff55]> <[player].if_null[<player>].flag[dPrevention.blocks.amount.per_block].if_null[0]>
        - <element[In Use:].color_gradient[from=#ff3399;to=#cc0066]> <[player].if_null[<player>].flag[dPrevention.blocks.amount.in_use].if_null[0]>
        - <element[Left to spent:].color_gradient[from=#00ffff;to=#009999]> <[player].if_null[<player>].proc[dPrevention_get_blocks]>
        info_lore:
        - <gold>Left-Click<&co>
        - <&[base]>Opens the Flag-Menu
        - <gold>Right-Click<&co>
        - <&[base]>Rename the claim
        - <gold>Shift-Rightclick<&co>
        - <&[base]>Delete the claim
        - <gold>Shift-Leftclick<&co>
        - <&[base]>Change the priority
    debug: false
    inventory: CHEST
    title: Menu
    gui: true
    definitions:
        x: <server.flag[dPrevention.config.inventories.filler-item]>
        blocks: <item[dPrevention_block_item].with[lore=<script.parsed_key[data.block_lore]>]>
        page: <item[dPrevention_page_item].with[lore=<&[base]>Current Page - 1/<player.flag[dPrevention.inventory_menu].size>]>
        info: <item[light].with[display=<white>Info;lore=<script.parsed_key[data.info_lore]>]>
        horse: <item[dPrevention_ride_whitelist_item].with[lore=<[player].if_null[<player>].flag[dPrevention.ride_whitelist].parse_tag[<&[base]><player[<[parse_value]>].name>].if_null[<empty>]>].with_flag[holder:<[player]>]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [x] [info] [x] [x] [blocks] [horse] [x] [page] [x]
dPrevention_menu_item:
    type: item
    debug: false
    material: grass_block
dPrevention_page_item:
    type: item
    debug: false
    material: stone
    display name: <white>Page
    flags:
        page: 1
dPrevention_ride_whitelist_item:
    type: item
    debug: false
    material: saddle
    display name: <white>Ride-Whitelist
dPrevention_block_item:
    type: item
    debug: false
    material: grass_block
    display name: <white>Blocks
dPrevention_menu_handler:
    type: world
    debug: false
    pager:
    - define pages <player.flag[dPrevention.inventory_menu]>
    - define max <[pages].size>
    - if <[max]> < <[page]>:
        - stop
    - if <[page]> < 1:
        - stop
    - inventory set origin:<[pages].get[<[page]>].pad_right[45].with[air]> destination:<player.open_inventory>
    - inventory flag slot:<context.slot> page:<[page]> destination:<player.open_inventory>
    - inventory adjust slot:<context.slot> destination:<player.open_inventory> "lore:<&[base]>Current Page - <[page]>/<[max]>"
    events:
        ## Changes the page.
        after player left clicks dPrevention_page_item in dPrevention_menu:
        - define page <context.item.flag[page].add[1]>
        - inject <script> path:pager
        after player right clicks dPrevention_page_item in dPrevention_menu:
        - define page <context.item.flag[page].sub[1]>
        - inject <script> path:pager
        ## Opens the  flag menu.
        after player left clicks dPrevention_menu_item in dPrevention_menu:
        - define area <context.item.flag[claim]>
        - run dPrevention_fill_flag_GUI def:<[area]>
        ## Delete an area.
        after player shift_right clicks dPrevention_menu_item in dPrevention_menu:
        - define area <context.item.flag[claim]>
        # Check if the claim is going to be configured by another player.
        - inject dPrevention_in_use
        # Check if another player is going to delete it.
        - inject dPrevention_in_delete
        - definemap data area:<[area]> holder:<context.item.flag[holder]> path:<context.item.flag[type]> type:remove_area
        - flag <player> dPrevention.chat_input:<[data]> expire:30s
        - flag <[area]> dPrevention.in_delete expire:30s
        - inventory close
        - narrate "Type 'delete' if want to remove this area." format:dPrevention_format
        ## Change the area's priority.
        after player shift_left clicks dPrevention_menu_item in dPrevention_menu:
        - if !<player.has_permission[dPrevention.admin]>:
            - narrate "You're not allowed to change the priority of your claim." format:dPrevention_format
            - inventory close
            - stop
        - define area <context.item.flag[claim]>
        # If the claim is in deletion, stop.
        - inject dPrevention_in_delete
        - narrate "Type an integer to change it's priority." format:dPrevention_format
        - definemap data area:<[area]> type:set_priority
        - flag <player> dPrevention.chat_input:<[data]> expire:30s
        - flag <[area]> dPrevention.in_use.<player.uuid> expire:30s
        - inventory close
        ## Rename an area.
        after player right clicks dPrevention_menu_item in dPrevention_menu:
        - define area <context.item.flag[claim]>
        # If the claim is in deletion, stop.
        - inject dPrevention_in_delete
        - definemap data area:<[area]> holder:<context.item.flag[holder]> type:rename_area
        - flag <player> dPrevention.chat_input:<[data]> expire:30s
        - flag <[area]> dPrevention.in_use.<player.uuid> expire:30s
        - inventory close
        - narrate "Type the new name of your area. Type 'cancel' if you want to cancel the rename or wait 30 seconds." format:dPrevention_format
        ## Add a player to the ride whitelist.
        after player left clicks dPrevention_ride_whitelist_item in dPrevention_menu:
        - if <context.item.flag[holder]> != <player>:
            - narrate "It's not possible to edit the ride-whitelist of another player." format:dPrevention_format
            - inventory close
            - stop
        - flag <player> dPrevention.chat_input.type:add_ride_whitelist expire:30s
        - narrate "Type the player's name you want to allow to ride your tamed entities. Type 'cancel' to cancel or wait 30 seconds." format:dPrevention_format
        - inventory close
        #Remove a player from the ride whitelist.
        after player right clicks dPrevention_ride_whitelist_item in dPrevention_menu:
        - if <context.item.flag[holder]> != <player>:
            - narrate "It's not possible to edit the ride-whitelist of another player." format:dPrevention_format
            - inventory close
            - stop
        - flag <player> dPrevention.chat_input.type:remove_ride_whitelist expire:30s
        - narrate "Type the player's name you want to remove the access to your tamed entities. Type 'cancel' to cancel or wait 30 seconds." format:dPrevention_format
        - inventory close
dPrevention_in_use:
    type: task
    debug: false
    definitions: area
    script:
    - if <[area].flag[dPrevention.in_use].any.if_null[false]>:
        - narrate "You can't delete this claim since another player configures it." format:dPrevention_format
        - inventory close
        - stop
dPrevention_in_delete:
    type: task
    debug: false
    definitions: area
    script:
    - if <[area].has_flag[dPrevention.in_delete]>:
        - narrate "You can't edit this claim because another player is going to delete it." format:dPrevention_format
        - inventory close
        - stop