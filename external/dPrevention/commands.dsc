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
    usage: /dPrevention [cuboid/ellipsoid/polygon/tool]
    permission: dPrevention.command
    tab completions:
        1: <player.has_permission[dPrevention.admin].if_true[cuboid|ellipsoid|polygon|tool].if_false[tool]>
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
                - default:
                    - narrate <script.data_key[usage]><n><script.parsed_key[data.tools]>
        - default:
            - narrate <script.data_key[usage]><n><script.parsed_key[data.tools]>
dPrevention_info:
    type: command
    name: info
    description: lists details about owned claims and current blocks
    usage: /info
    tab completions:
        1: blocks|claims
    script:
    - define argument <context.args.first.if_null[null]>
    - choose <[argument]>:
        - case null:
            - narrate "From play: <player.flag[dPrevention.blocks.amount.per_time].if_null[0]><n>From blocks:<player.flag[dPrevention.blocks.amount.per_blocks].if_null[0]><n><proc[dPrevention_info_formatter]>"
        - case blocks:
            - narrate "From play: <player.flag[dPrevention.blocks.amount.per_time].if_null[0]><n>From blocks:<player.flag[dPrevention.blocks.amount.per_blocks].if_null[0]>"
        - case claims:
            - narrate <proc[dPrevention_info_formatter]>
dPrevention_info_formatter:
    type: procedure
    script:
    - foreach <player.flag[dPrevention.areas.cuboids].parse[as_cuboid].sort_by_value[world.name]> as:cuboid:
        - definemap data min_x:<[cuboid].min.x> min_z:<[cuboid].min.z> max_x:<[cuboid].max.x> max_z:<[cuboid].max.z> world:<[cuboid].world.name> costs:<[cuboid].proc[dPrevention_get_costs]>
        - define "format:->:Size: <[data.min_x]>,<[data.min_z]> to <[data.max_x]>,<[data.max_z]> in <[data.world]> Costs: <[data.costs]>"
    - determine <[format].separated_by[<n>]>