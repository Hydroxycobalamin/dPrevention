dPrevention_open_gui:
    type: command
    name: flags
    description: opens the GUI for dPrevention claims
    usage: /flags
    permission: dPrevention.flaggui
    script:
    - choose <context.args.size>:
        - case 0:
            - define location <player.location>
            - define areas <[location].proc[dPrevention_get_areas]>
            - if <player.has_permission[dPrevention.admin]>:
                - if <[areas].is_empty>:
                    - narrate "Not inside a region. Default to world: <player.location.world.name>"
                    - run dPrevention_fill_flag_GUI def:<player.location.world>
                    - stop
                - if <[areas].size> > 1:
                    - run dPrevention_generate_clickables def:<list_single[<[areas]>]>
                    - stop
                - run dPrevention_fill_flag_GUI def:<[areas].first>
                - stop
            - define ownership <[areas].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
            - if <[ownership].size> > 1:
                - narrate "There are multiple regions, with ownerships at your location, please choose one."
                - foreach <[ownership]> as:area:
                    - clickable dPrevention_fill_flag_GUI def:<[area]> for:<player> until:1m save:<[loop_index]>
                    - define clickables:->:<[area].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[area].note_name>]>
                - narrate <[clickables].space_separated>
                - stop
            - run dPrevention_fill_flag_GUI def:<[ownership].first>
dPrevention_main:
    type: command
    data:
        tools: Tools by mcmonkey<&co> <element[Polygon].on_click[https://forum.denizenscript.com/resources/polygon-selector-tool.2/].type[OPEN_URL]> <element[Ellipsoid].on_click[https://forum.denizenscript.com/resources/ellipsoid-selector-tool.3/].type[OPEN_URL]> <element[Cuboid].on_click[https://forum.denizenscript.com/resources/cuboid-selector-tool.1/].type[OPEN_URL]>
    name: dPrevention
    description: main command
    usage: /dPrevention [cuboid/ellipsoid/polygon/tool/info]
    permission: dPrevention.command
    tab completions:
        1: <player.has_permission[dPrevention.admin].if_true[cuboid|ellipsoid|polygon|tool|info].if_false[tool|info]>
    script:
    - choose <context.args.size>:
        - case 1:
            - define argument <context.args.first>
            - choose <[argument]>:
                - case cuboid:
                    - if !<player.has_flag[ctool_selection]>:
                        - narrate "<red>You don't have any ellipsoid selected."
                        - stop
                    - define uuid <util.random_uuid>
                    - flag <player.world> dPrevention.areas.cuboids:->:<[uuid]>
                    - note <player.flag[ctool_selection]> as:<[uuid]>
                    - run dPrevention_area_creation def:<list.include[<cuboid[<[uuid]>]>]>
                - case ellipsoid:
                    - if !<player.has_flag[elliptool_selection]>:
                        - narrate "<red>You don't have any ellipsoid selected."
                        - stop
                    - define uuid <util.random_uuid>
                    - flag <player.world> dPrevention.areas.ellipsoids:->:<[uuid]>
                    - note <player.flag[elliptool_selection]> as:<[uuid]>
                    - run dPrevention_area_creation def:<list.include[<ellipsoid[<[uuid]>]>]>
                - case polygon:
                    - if !<player.has_flag[ptool_selection]>:
                        - narrate "<red>You don't have any ellipsoid selected."
                        - stop
                    - define uuid <util.random_uuid>
                    - flag <player.world> dPrevention.areas.polygons:->:<[uuid]>
                    - note <player.flag[ptool_selection]> as:<[uuid]>
                    - run dPrevention_area_creation def:<list.include[<polygon[<[uuid]>]>]>
                - case tool:
                    - if !<player.inventory.can_fit[dPrevention_tool]>:
                        - narrate "You can't hold the tool. Make some space."
                        - stop
                    - give dPrevention_tool slot:hand
                - case info:
                    - inject dPrevention_info_formatter
                - default:
                    - narrate <script.data_key[usage]><n><script.parsed_key[data.tools]>
        - default:
            - narrate <script.data_key[usage]><n><script.parsed_key[data.tools]>
dPrevention_info_data:
    type: procedure
    data:
        format:
        - Size: <[data.min_x]>,<[data.min_z]> to <[data.max_x]>,<[data.max_z]> in <[data.world]>
        - Costs: <[data.costs]>
    script:
    - define page 1
    - foreach <player.flag[dPrevention.areas.cuboids].parse[as_cuboid].sort_by_value[world.name].if_null[<list>].exclude[null]> as:cuboid:
        - definemap data min_x:<[cuboid].min.x> min_z:<[cuboid].min.z> max_x:<[cuboid].max.x> max_z:<[cuboid].max.z> world:<[cuboid].world.name> costs:<[cuboid].proc[dPrevention_get_costs]>
        - define inventory_menu.pages.<[page]>:->:<item[dPrevention_menu_item].with[lore=<script.parsed_key[data.format]>]>
        - if <[loop_index].mod[45]> == 0:
            - define page:++
    - determine <[inventory_menu]>
dPrevention_info_formatter:
    type: task
    script:
    - define data <proc[dPrevention_info_data]>
    - flag <player> dPrevention.inventory_menu:<[data]>
    - inventory open destination:dPrevention_menu
    - wait 1t
    - inventory set origin:<[data.pages.1]> destination:<player.open_inventory>
dPrevention_menu:
    type: inventory
    inventory: CHEST
    title: Menu
    gui: true
    definitions:
        blocks: "<item[dPrevention_menu_item].with[lore=From play: <player.flag[dPrevention.blocks.amount.per_time].if_null[0]>|From blocks: <player.flag[dPrevention.blocks.amount.per_block].if_null[0]>]>"
        page: "<item[dPrevention_page_item].with[lore=Current Page:1/<player.flag[dPrevention.inventory_menu.pages].keys.highest>].with_flag[page:1]>"
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [blocks] [] [] [page] []
dPrevention_menu_item:
    type: item
    material: grass_block
dPrevention_page_item:
    type: item
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