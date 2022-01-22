dPrevention_open_gui:
    type: command
    debug: false
    name: flags
    description: opens the GUI for dPrevention claims
    usage: /flags
    permission: dPrevention.command.flags
    script:
    - define location <player.location>
    - define areas <[location].cuboids.include[<[location].ellipsoids>].include[<[location].polygons>]>
    #If the player is an admin, let him access all claims.
    - if <player.has_permission[dPrevention.admin]>:
        #If he's not inside an area, open the world flag GUI.
        - if <[areas].is_empty>:
            - narrate "You're not inside an area. Default to current world: <[location].world.name.custom_color[emphasis]>" format:dPrevention_format
            - run dPrevention_fill_flag_GUI def:<[location].world>
            - stop
        #If he's inside multiple areas, he can select one.
        - if <[areas].size> > 1:
            - run dPrevention_generate_clickables def:<list_single[<[areas]>]>
            - stop
        #Open the GUI if he's only in one.
        - run dPrevention_fill_flag_GUI def:<[areas].first>
        - stop
    #User
    - define ownerships <[areas].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
    #If the user is note inside his claim, stop.
    - if <[ownerships].is_empty>:
        - narrate "You're not inside your own claim." format:dPrevention_format
        - stop
    #If the user has multiple ownerships, he can select one.
    - if <[ownerships].size> > 1:
        - narrate "There are multiple areas with ownerships at your location, please choose one." format:dPrevention_format
        - run dPrevention_generate_clickables def:<list_single[<[ownerships]>]>
        - stop
    #Open the GUI if he has only one.
    - run dPrevention_fill_flag_GUI def:<[ownerships].first>
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
                    - run cuboid_tool_status_task
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
                    - run ellipsoid_tool_status_task
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
                    - run polygon_tool_status_task
                    - flag <[area].world> dPrevention.areas.admin.polygons:->:<[id]>
                    - note <[area]> as:<[id]>
                    - run dPrevention_area_creation def:<list.include[<polygon[<[id]>]>]>
                    - narrate "You've created an admin claim called <[id].custom_color[emphasis]>!" format:dPrevention_format
                - default:
                    - narrate <script.data_key[usage].custom_color[emphasis]><n><script.parsed_key[data.tools]> format:dPrevention_format
        - default:
            - narrate <script.data_key[usage].custom_color[emphasis]><n><script.parsed_key[data.tools]> format:dPrevention_format
dPrevention_generate_clickables:
    type: task
    debug: false
    definitions: areas
    script:
    - foreach <[areas]> as:area:
        - clickable dPrevention_fill_flag_GUI def:<[area]> for:<player> until:1m save:<[loop_index]>
        - define clickables:->:<[area].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[area].note_name>]>
    - narrate <[clickables].space_separated.custom_color[emphasis]> format:dPrevention_format