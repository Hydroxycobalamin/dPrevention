dPrevention_updater:
    type: world
    debug: false
    events:
        after server start:
        - if !<server.flag[dPrevention.updated].keys.contains[teleport].if_null[false]>:
            - run dPrevention_update_teleport
dPrevention_update_teleport:
    type: task
    debug: false
    script:
    #Get all current worlds
    - define worlds <server.flag[dPrevention.config.claims.worlds].parse[as_world].filter[has_flag[dPrevention.areas]]>
    #Get all areas
    - define player_cuboids <[worlds].filter[has_flag[dPrevention.areas.cuboids]].parse[flag[dPrevention.areas.cuboids]].combine>
    #- define player_polygons <[worlds].filter[has_flag[dPrevention.areas.polygons]].parse[flag[dPrevention.areas.polygons]].combine>
    #- define player_ellipsoids <[worlds].filter[has_flag[dPrevention.areas.ellipsoids]].parse[flag[dPrevention.areas.ellipsoids]].combine>
    - define admin_cuboids <[worlds].filter[has_flag[dPrevention.areas.admin.cuboids]].parse[flag[dPrevention.areas.admin.cuboids]].combine>
    - define admin_polygons <[worlds].filter[has_flag[dPrevention.areas.admin.polygons]].parse[flag[dPrevention.areas.admin.polygons]].combine>
    - define admin_ellipsoids <[worlds].filter[has_flag[dPrevention.areas.admin.ellipsoids]].parse[flag[dPrevention.areas.admin.ellipsoids]].combine>
    - define cuboids <[player_cuboids].include[<[admin_cuboids]>]>
    #- define polygons <[player_polygons].include[<[admin_polygons]>]>
    #- define ellipsoids <[player_ellipsoids].include[<[admin_ellipsoids]>]>
    - definemap area_map cuboids:<[cuboids]> polygons:<[admin_polygons]> ellipsoids:<[admin_ellipsoids]>
    #Loop through all areas.
    - foreach <[area_map]> key:type as:areas:
        - foreach <[areas]> as:note_name:
            # Get the area object.
            - choose <[type]>:
                - case cuboids:
                    - define area <[note_name].as_cuboid>
                - case ellipsoids:
                    - define area <[note_name].as_ellipsoid>
                - case polygons:
                    - define area <[note_name].as_polygon>
                - default:
                    - debug error "Something went really wrong. Please report it to the author. Found type: <[type]>"
                    - stop
            #Update areas to fix area borks.
            - announce to_console "Checking area: <[area].note_name.color[aqua]>"
            - if <[area].has_flag[dPrevention.flags.teleport]>:
                - announce to_console "Found <[area].note_name.color[aqua]> with non-existent teleport flag. Renaming flag <element[teleport].color[green]> to <element[teleport-item].color[yellow]>."
                - flag <[area]> dPrevention.flags.teleport:!
                - flag <[area]> dPrevention.flags.teleport-item
    - flag server "dPrevention.updated.teleport:Renamed flags teleport to teleport-item"
dPrevention_manual_update:
    type: command
    debug: false
    name: update_dPrevention
    usage: /update_dPrevention [type]
    description: Updates dPrevention manually.
    tab completions:
        1: teleport|show
    permission: dPrevention.update
    script:
    - if <context.source_type> != SERVER:
        - narrate "<&[error]>This command must be run from the console!" format:dPrevention_format
    - if <context.args.size> != 1:
        - announce to_console "Syntax: <script.data_key[usage].custom_color[emphasis]>"
        - stop
    - choose <context.args.first>:
        - case teleport:
            - if <server.has_flag[dPrevention.update.teleport]>:
                - run dPrevention_update_teleport
                - flag server dPrevention.update.teleport:!
                - announce to_console "Updating teleport flags. Watch your console!"
                - stop
            - flag server dPrevention.update.teleport duration:10s
            - announce to_console "Are you sure you want manually updating teleport flags? This checks all current areas and renames the flag 'teleport' to 'teleport-item'. This will take a few seconds. Type the command again, to continue." format:dPrevention_format
        - case show:
            - announce to_console "Printing out applied updated"
            - foreach <server.flag[dPrevention.updated].if_null[<map>]> key:type as:description:
                - announce to_console "Updated <element[<[type]>].color[green]>: <element[<[description]>].color[yellow]>"
        - default:
            - announce to_console "Syntax: <script.data_key[usage].custom_color[emphasis]>"