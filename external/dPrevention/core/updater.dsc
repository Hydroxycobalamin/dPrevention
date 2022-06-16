# The usage of this script is to update areas automatically, if breaking changes were made.
dPrevention_updater:
    type: world
    debug: false
    version: 2
    updates:
        1: teleport
        2: object_storage
    events:
        after server start:
        # If it's a server, updated from a pre-cache version, which haven't updated teleports flags yet.
        - if !<server.has_flag[dPrevention.update.version]> && <server.has_flag[dPrevention.updated.teleport]>:
            - flag server dPrevention.update.version:1
        # Try updates.
        - repeat <script.data_key[version]> as:n:
            - if <server.flag[dPrevention.update.version].if_null[0]> < <[n]>:
                - ~run dPrevention_update_task def.path:<script.data_key[updates.<[n]>]>
        # Set version as cache to prevent further updates.
        - flag server dPrevention.update.version:<script.data_key[version]>
dPrevention_update_task:
    type: task
    debug: false
    definitions: path
    object_storage:
    # Get all current worlds
    - define worlds <server.flag[dPrevention.config.claims.worlds].parse[as_world].filter[has_flag[dPrevention.areas]]>
    # Convert the note_name to the object and save it.
    - foreach <[worlds]> as:world:
        - if <[world].has_flag[dPrevention.areas.cuboids]>:
            - flag <[world]> dPrevention.areas.cuboids:<[world].flag[dPrevention.areas.cuboids].parse[as_cuboid]>
        - if <[world].has_flag[dPrevention.areas.ellipsoids]>:
            - flag <[world]> dPrevention.areas.ellipsoids:<[world].flag[dPrevention.areas.ellipsoids].parse[as_ellipsoid]>
        - if <[world].has_flag[dPrevention.areas.polygons]>:
            - flag <[world]> dPrevention.areas.polygons:<[world].flag[dPrevention.areas.polygons].parse[as_polygon]>
        - if <[world].has_flag[dPrevention.areas.admin.cuboids]>:
            - flag <[world]> dPrevention.areas.admin.cuboids:<[world].flag[dPrevention.areas.admin.cuboids].parse[as_cuboid]>
        - if <[world].has_flag[dPrevention.areas.admin.ellipsoids]>:
            - flag <[world]> dPrevention.areas.admin.ellipsoids:<[world].flag[dPrevention.areas.admin.ellipsoids].parse[as_ellipsoid]>
        - if <[world].has_flag[dPrevention.areas.admin.polygons]>:
            - flag <[world]> dPrevention.areas.admin.polygons:<[world].flag[dPrevention.areas.admin.polygons].parse[as_polygon]>
    - foreach <server.players_flagged[dPrevention.areas.cuboids]> as:player:
        - flag <[player]> dPrevention.areas.cuboids:<[player].flag[dPrevention.areas.cuboids].parse[as_cuboid]>
    teleport:
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
    - flag server dPrevention.updated:!
    script:
    - inject <script> path:<[path]>