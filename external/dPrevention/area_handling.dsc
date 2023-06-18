dPrevention_area_creation:
    type: task
    debug: false
    definitions: area|owner
    script:
    - define config <server.flag[dPrevention.config.claims]>
    - foreach <[config.flags]> key:flag as:value:
        - flag <[area]> dPrevention.flags.<[flag]>:<[value]>
    - flag <[area]> dPrevention.priority:<[config.priority]>
    - if <[owner].exists>:
        - flag <[area]> dPrevention.owners:->:<[owner]>
    - customevent id:dPrevention_area_created context:[is_userclaim=<[owner].exists>;area=<[area]>]
dPrevention_area_removal:
    type: task
    debug: false
    definitions: cuboid|player
    script:
    - run dPrevention_cancel_mode def:expand player:<[player]>
    - flag <[cuboid].world> dPrevention.areas.cuboids:<-:<[cuboid]>
    - flag <[player]> dPrevention.areas.cuboids:<-:<[cuboid]>
    - note remove as:<[cuboid].note_name>
    - run dPrevention_take_blocks def.type:in_use def.amount:<[cuboid].proc[dPrevention_get_costs]> player:<[player]>
dPrevention_area_admin_removal:
    type: task
    debug: false
    definitions: data
    script:
    - flag <[data.area].world> dPrevention.areas.admin.<[data.path]>:<-:<[data.area]>
    - note remove as:<[data.area].note_name>
dPrevention_check_intersections:
    type: task
    debug: false
    # This task script is usually injected via inject command.
    definitions: cuboid|selection
    script:
    # Get all dPrevention areas, as cuboid.
    - define area_map <[selection].world.flag[dPrevention.areas].if_null[<map>]>
    - definemap admin_areas:
        admin_cuboids: <[area_map.admin.cuboids].if_null[<list>]>
        admin_ellipsoids: <[area_map.admin.ellipsoids].if_null[<list>].parse[bounding_box]>
        admin_polygons: <[area_map.admin.polygons].if_null[<list>].parse[bounding_box]>
    - definemap player_areas:
        cuboids: <[area_map.cuboids].if_null[<list>]>
        ellipsoids: <[area_map.ellipsoids].if_null[<list>].parse[bounding_box]>
        polygons: <[area_map.polygons].if_null[<list>].parse[bounding_box]>
    - define cuboids <[player_areas].values.combine>
    # Define owned areas.
    - define owned_areas <[cuboids].filter_tag[<player.uuid.is_in[<[filter_value].flag[dPrevention.owners].if_null[<list>]>]>]>
    # If a cuboid is expanded
    - if <[cuboid].if_null[null]> != null:
        # If a user claim is expanded, exclude owned areas and include admin areas.
        - if <[cuboid].flag[dPrevention.owners].exists>:
            - define cuboids <[cuboids].exclude[<[owned_areas]>].include[<[admin_areas].values.combine>]>
        # Elsewise, admin claims are ignored because it's an admin claim.
    # If a cuboid is created, exclude owned areas and include admin areas.
    - else:
        - define cuboids <[cuboids].exclude[<[owned_areas]>].include[<[admin_areas].values.combine>]>
    # Check for intersections.
    - define intersections <[cuboids].exclude[<[cuboid].if_null[null]>].filter_tag[<[filter_value].intersects[<[selection]>]>]>
    # If the selection intersects another claim which he the player doesn't own, he's not allowed to claim.
    - if !<[intersections].is_empty>:
        - narrate "Your selection intersects <[intersections].size.custom_color[emphasis]> other claims." format:dPrevention_format
        - foreach <[intersections]> as:intersection:
            - define created_corner <[intersection].proc[dPrevention_create_corner].context[<[intersection].min>]>
            - define corners:|:<[created_corner].proc[dPrevention_copy_corner].context[<[intersection].max.y>].include[<[created_corner]>]>
        - debugblock <[corners]> color:<color[0,255,0,255]>
        - stop