dPrevention_open_gui:
    type: command
    debug: false
    name: flags
    description: opens the GUI for dPrevention claims
    usage: /flags
    permission: dPrevention.command.flags
    script:
    - define location <player.location>
    - define areas <[location].areas>
    #If the player is an admin, let him access all claims.
    - if <player.has_permission[dPrevention.admin]>:
        #If he's not inside an area, open the world flag GUI.
        - if <[areas].is_empty>:
            - narrate "You're not inside an area. Default to current world: <[location].world.name.custom_color[emphasis]>" format:dPrevention_format
            - run dPrevention_fill_flag_GUI def:<[location].world>
            - stop
        #If he's inside multiple areas, he can select one.
        - if <[areas].size> > 1:
            - run dPrevention_generate_clickables def.areas:<[areas]>
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
        - run dPrevention_generate_clickables def.areas:<[ownerships]>
        - stop
    #Open the GUI if he has only one.
    - run dPrevention_fill_flag_GUI def:<[ownerships].first>
dPrevention_main:
    type: command
    debug: false
    data:
        tools: <element[[Tool]].color_gradient[from=#ff3399;to=#cc0066]> <&[base]><element[Area Selector Tool by mcmonkey].on_click[https://forum.denizenscript.com/resources/area-selector-tool.1/].type[OPEN_URL].on_hover[Click here]>
    name: dPrevention
    description: main command
    usage: /dPrevention [cuboid/ellipsoid/polygon/tool/info]
    permission: dPrevention.command.main
    tab completions:
        1: <player.has_permission[dPrevention.admin].if_true[create|admininfo|tool|info].if_false[tool|info]>
        2: <player.has_permission[dPrevention.admin].and[<context.args.first.equals[info]>].if_true[<server.players.parse[name]>].if_false[<player.has_permission[dPrevention.admin].and[<context.args.first.equals[create]>].if_true[cuboid|polygon|ellipsoid|sphere].if_false[<empty>]>]>
    script:
    - define syntax <script.data_key[usage].custom_color[emphasis]><script[seltool_command].exists.if_true[<empty>].if_false[<n><script.parsed_key[data.tools]>]>
    - choose <context.args.size>:
        - case 1:
            - choose <context.args.first>:
                - case tool:
                    - if !<player.inventory.can_fit[dPrevention_tool]>:
                        - narrate "You can't hold the tool. Make some space." format:dPrevention_format
                        - stop
                    - give dPrevention_tool slot:hand
                    - narrate "You've obtained the <element[<item[dPrevention_tool].display>].on_hover[<item[dPrevention_tool]>].type[SHOW_ITEM]>." format:dPrevention_format
                - case info:
                    - run dPrevention_info_formatter def.cuboids:<player.flag[dPrevention.areas.cuboids].sort_by_value[world.name].if_null[<list>].exclude[null]> def.player:<player>
                - case admininfo:
                    - if !<player.has_permission[dPrevention.admin]>:
                        - narrate "You don't have permission to do that" format:dPrevention_format
                        - stop
                    - foreach <server.worlds> as:world:
                        - define data <[world].flag[dPrevention.areas.admin].if_null[null]>
                        - if <[data]> == null:
                            - foreach next
                        - define cuboids <[cuboids].if_null[<list>].include[<[data.cuboids].if_null[<list>]>]>
                        - define polygons <[polygons].if_null[<list>].include[<[data.polygons].if_null[<list>]>]>
                        - define ellipsoids <[ellipsoids].if_null[<list>].include[<[data.ellipsoids].if_null[<list>]>]>
                    - run dPrevention_info_formatter def.cuboids:<[cuboids].if_null[<list>]> def.polygons:<[polygons].if_null[<list>]> def.ellipsoids:<[ellipsoids].if_null[<list>]> def.player:null
                - default:
                    - narrate <[syntax]> format:dPrevention_format
        - case 2:
            - if !<player.has_permission[dPrevention.admin]>:
                - narrate "You don't have permission to do that" format:dPrevention_format
                - stop
            - define argument <context.args.first>
            - if <[argument]> != info:
                - narrate <[syntax]> format:dPrevention_format
                - stop
            - define player <server.match_offline_player[<context.args.last>].if_null[null]>
            - if <[player]> == null:
                - narrate "This player doesn't exist!" format:dPrevention_format
                - stop
            - run dPrevention_info_formatter def.cuboids:<[player].flag[dPrevention.areas.cuboids].sort_by_value[world.name].if_null[<list>].exclude[null]> def.player:<[player]>
        - case 3:
            - if !<player.has_permission[dPrevention.admin]>:
                - narrate "You don't have permission to do that" format:dPrevention_format
                - stop
            - define argument <context.args.get[2]>
            - if <context.args.first> != create:
                - narrate <[syntax]> format:dPrevention_format
                - stop
            - choose <context.args.get[2]>:
                - case cuboid:
                    - inject dPrevention_check_adminclaim_creation
                - case sphere:
                    - inject dPrevention_check_adminclaim_creation
                - case ellipsoid:
                    - inject dPrevention_check_adminclaim_creation
                - case polygon:
                    - inject dPrevention_check_adminclaim_creation
                - default:
                    - narrate <[syntax]> format:dPrevention_format
        - default:
            - narrate <[syntax]> format:dPrevention_format
dPrevention_check_adminclaim_creation:
    type: task
    debug: false
    definitions: argument
    script:
    - define type <player.flag[seltool_type].if_null[null]>
    - if <[type]> != <[argument]>:
        - narrate "You don't have a <[argument]> selected." format:dPrevention_format
        - stop
    - define area <player.flag[seltool_selection].if_null[null]>
    - if <[area]> == null:
        - narrate "You don't have an area selected." format:dPrevention_format
        - stop
    - if <[type]> == sphere:
        - define type ellipsoid
    - define id <context.args.get[3].trim_to_character_set[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890]>
    #If there's already a adminclaim with this name, stop.
    - if <[area].world.flag[dPrevention.areas.admin.<[type]>s].contains[<[id]>].if_null[false]>:
        - narrate "A <[type].custom_color[emphasis]> with the id <[id].custom_color[emphasis]> already exists!" format:dPrevention_format
        - stop
    #If a noted object already exists with this name, stop.
    - if <util.notes.parse[note_name].contains[<[id]>]>:
        - narrate "An object with this name already exists." format:dPrevention_format
        - stop
    - inject selector_tool_status_task path:<[type]>
    - note <[area]> as:<[id]>
    #Get the noted object.
    - choose <[type]>:
        - case ellipsoid:
            - define note <ellipsoid[<[id]>]>
        - case cuboid:
            - define note <cuboid[<[id]>]>
        - case polygon:
            - define note <polygon[<[id]>]>
        - default:
            - debug error "Something went wrong. Please report it to the author. Type: <[type]>"
    - flag <[area].world> dPrevention.areas.admin.<[type]>s:->:<[note]>
    #Make the noted object a dPrevention admin area.
    - run dPrevention_area_creation def.area:<[note]>
    - narrate "You've created an admin claim called <[id].custom_color[emphasis]>!" format:dPrevention_format
dPrevention_generate_clickables:
    type: task
    debug: false
    definitions: areas
    script:
    - foreach <[areas]> as:area:
        - clickable dPrevention_fill_flag_GUI def:<[area]> for:<player> until:1m save:<[loop_index]>
        - define clickables:->:<[area].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[area].note_name>]>
    - narrate <[clickables].space_separated.custom_color[emphasis]> format:dPrevention_format