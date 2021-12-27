dPrevention_open_gui:
    type: command
    debug: false
    name: flags
    description: opens the GUI for dPrevention claims
    usage: /flags
    permission: dPrevention.command.flags
    script:
    - define location <player.location>
    - define areas <[location].proc[dPrevention_get_areas]>
    - if <player.has_permission[dPrevention.admin]>:
        - if <[areas].is_empty>:
            - narrate "You're not inside an area. Default to current world: <player.location.world.name.custom_color[emphasis]>" format:dPrevention_format
            - run dPrevention_fill_flag_GUI def:<player.location.world>
            - stop
        - if <[areas].size> > 1:
            - run dPrevention_generate_clickables def:<list_single[<[areas]>]>
            - stop
        - run dPrevention_fill_flag_GUI def:<[areas].first>
        - stop
    - define ownership <[areas].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
    - if <[ownership].size> > 1:
        - narrate "There are multiple areas with ownerships at your location, please choose one." format:dPrevention_format
        - run dPrevention_generate_clickables def:<list_single[<[ownership]>]>
        - stop
    - if <[ownership].is_empty>:
        - narrate "You're not inside your own claim." format:dPrevention_format
        - stop
    - run dPrevention_fill_flag_GUI def:<[ownership].first>
dPrevention_main:
    type: command
    debug: false
    data:
        tools: Tools by mcmonkey<&co> <element[Polygon].on_click[https://forum.denizenscript.com/resources/polygon-selector-tool.2/].type[OPEN_URL]> <element[Ellipsoid].on_click[https://forum.denizenscript.com/resources/ellipsoid-selector-tool.3/].type[OPEN_URL]> <element[Cuboid].on_click[https://forum.denizenscript.com/resources/cuboid-selector-tool.1/].type[OPEN_URL]>
    name: dPrevention
    description: main command
    usage: /dPrevention [cuboid/ellipsoid/polygon/tool/info]
    permission: dPrevention.command.main
    tab completions:
        1: <player.has_permission[dPrevention.admin].if_true[cuboid|ellipsoid|polygon|tool|info|admininfo].if_false[tool|info]>
    script:
    - choose <context.args.size>:
        - case 1:
            - choose <context.args.first>:
                - case tool:
                    - if !<player.inventory.can_fit[dPrevention_tool]>:
                        - narrate "You can't hold the tool. Make some space." format:dPrevention_format
                        - stop
                    - give dPrevention_tool slot:hand
                - case info:
                    - run dPrevention_info_formatter def.cuboids:<player.flag[dPrevention.areas.cuboids].parse[as_cuboid].sort_by_value[world.name].if_null[<list>].exclude[null]> def.player:<player>
                - case admininfo:
                    - if !<player.has_permission[dPrevention.admin]>:
                        - narrate "You don't have permission to do that" format:dPrevention_format
                        - stop
                    - foreach <server.worlds> as:world:
                        - define data <[world].flag[dPrevention.areas.admin].if_null[null]>
                        - if <[data]> == null:
                            - foreach next
                        - define cuboids <[cuboids].if_null[<list>].include[<[data.cuboids].parse[as_cuboid].if_null[<list>]>]>
                        - define polygons <[polygons].if_null[<list>].include[<[data.polygons].parse[as_polygon].if_null[<list>]>]>
                        - define ellipsoids <[ellipsoids].if_null[<list>].include[<[data.ellipsoids].parse[as_ellipsoid].if_null[<list>]>]>
                    - run dPrevention_info_formatter def.cuboids:<[cuboids].if_null[<list>]> def.polygons:<[polygons].if_null[<list>]> def.ellipsoids:<[ellipsoids].if_null[<list>]> def.player:null
        - case 2:
            - if !<player.has_permission[dPrevention.admin]>:
                - narrate "You don't have permission to do that" format:dPrevention_format
                - stop
            - define argument <context.args.first>
            - choose <[argument]>:
                - case info:
                    - define player <server.match_offline_player[<context.args.last>].if_null[null]>
                    - if <[player]> == null:
                        - narrate "This player doesn't exist!"
                        - stop
                    - run dPrevention_info_formatter def.cuboids:<[player].flag[dPrevention.areas.cuboids].parse[as_cuboid].sort_by_value[world.name].if_null[<list>].exclude[null]> def.player:<[player]>
                - case cuboid:
                    - define area <player.flag[ctool_selection].if_null[null]>
                    - if <[area]> == null:
                        - narrate "You don't have cuboid area selected." format:dPrevention_format
                        - stop
                    - define id <context.args.get[2].trim_to_character_set[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890]>
                    - if <[area].world.flag[dPrevention.areas.admin.cuboids].contains[<[id]>].if_null[false]>:
                        - narrate "A cuboid with the id <[id].custom_color[emphasis]> exists already!" format:dPrevention_format
                        - stop
                    - flag <[area].world> dPrevention.areas.admin.cuboids:->:<[id]>
                    - note <[area]> as:<[id]>
                    - run dPrevention_area_creation def:<list.include[<cuboid[<[id]>]>]>
                    - narrate "You've created an admin claim called <[id].custom_color[emphasis]>!" format:dPrevention_format
                - case ellipsoid:
                    - define area <player.flag[elliptool_selection].if_null[null]>
                    - if <[area]> == null:
                        - narrate "You don't have any ellipsoid selected." format:dPrevention_format
                        - stop
                    - define id <context.args.get[2].trim_to_character_set[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890]>
                    - if <[area].world.flag[dPrevention.areas.admin.ellipsoids].contains[<[id]>].if_null[false]>:
                        - narrate "A ellipsoid with the name <[id].custom_color[emphasis]> exists already!" format:dPrevention_format
                        - stop
                    - flag <[area].world> dPrevention.areas.admin.ellipsoids:->:<[id]>
                    - note <[area]> as:<[id]>
                    - run dPrevention_area_creation def:<list.include[<ellipsoid[<[id]>]>]>
                    - narrate "You've created an admin claim called <[id].custom_color[emphasis]>!" format:dPrevention_format
                - case polygon:
                    - define area <player.flag[ptool_selection].if_null[null]>
                    - if <[area]> == null:
                        - narrate "You don't have any polygon selected." format:dPrevention_format
                        - stop
                    - define id <context.args.get[2].trim_to_character_set[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890]>
                    - if <[area].world.flag[dPrevention.areas.admin.polygons].contains[<[id]>].if_null[false]>:
                        - narrate "A ellipsoid with the name <[id].custom_color[emphasis]> exists already!" format:dPrevention_format
                        - stop
                    - flag <[area].world> dPrevention.areas.admin.polygons:->:<[id]>
                    - note <[area]> as:<[id]>
                    - run dPrevention_area_creation def:<list.include[<polygon[<[id]>]>]>
                    - narrate "You've created an admin claim called <[id].custom_color[emphasis]>!" format:dPrevention_format
                - default:
                    - narrate <script.data_key[usage].custom_color[emphasis]><n><script.parsed_key[data.tools]> format:dPrevention_format
        - default:
            - narrate <script.data_key[usage].custom_color[emphasis]><n><script.parsed_key[data.tools]> format:dPrevention_format
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