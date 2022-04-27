dPrevention_area_creation:
    type: task
    debug: false
    definitions: area|owner
    script:
    - customevent id:dPrevention_area_created context:[is_userclaim=<[owner].exists>;area=<[area]>]
    - define config <script[dPrevention_config].data_key[claims]>
    - foreach <[config.flags]> key:flag as:value:
        - flag <[area]> dPrevention.flags.<[flag]>:<[value]>
    - flag <[area]> dPrevention.priority:<[config.priority]>
    - if <[owner].exists>:
        - flag <[area]> dPrevention.owners:->:<[owner]>
dPrevention_area_removal:
    type: task
    debug: false
    definitions: cuboid|player
    script:
    - run dPrevention_cancel_mode def:expand player:<[player]>
    - flag <[cuboid].world> dPrevention.areas.cuboids:<-:<[cuboid].note_name>
    - flag <[player]> dPrevention.areas.cuboids:<-:<[cuboid].note_name>
    - note remove as:<[cuboid].note_name>
    - run dPrevention_take_blocks def.type:in_use def.amount:<[cuboid].proc[dPrevention_get_costs]> player:<[player]>
dPrevention_area_admin_removal:
    type: task
    debug: false
    definitions: data
    script:
    - flag <[data.claim].world> dPrevention.areas.admin.<[data.path]>:<-:<[data.claim].note_name>
    - note remove as:<[data.claim].note_name>
dPrevention_check_intersections:
    type: task
    debug: false
    #This task script is usually injected via inject command.
    definitions: cuboid|selection
    script:
    - define area_map <[selection].world.flag[dPrevention.areas].if_null[<map>]>
    - define cuboids <[area_map.cuboids].if_null[<list>].include[<[area_map.admin.cuboids].if_null[<list>]>].parse[as_cuboid].exclude[<[cuboid].if_null[<empty>]>]>
    - define ellipsoids <[area_map.ellipsoids].if_null[<list>].include[<[area_map.admin.ellipsoids].if_null[<list>]>].parse[as_ellipsoid.bounding_box].exclude[<[cuboid].if_null[<empty>]>]>
    - define polygons <[area_map.polygons].if_null[<list>].include[<[area_map.admin.polygons].if_null[<list>]>].parse[as_polygon.bounding_box].exclude[<[cuboid].if_null[<empty>]>]>
    - define intersections <[cuboids].include[<[ellipsoids]>].include[<[polygons]>].filter_tag[<[filter_value].intersects[<[selection]>]>]>
    - define owned_areas <[intersections].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
    - define intersections <[intersections].exclude[<[owned_areas]>]>
    #If the selection intersects another claim which he the player doesn't own, he's not allowed to claim.
    - if !<[intersections].is_empty>:
        - narrate "Your selection intersects <[intersections].size.custom_color[emphasis]> other claims." format:dPrevention_format
        - playeffect effect:BARRIER at:<[intersections].parse[bounding_box.outline].combine> offset:0,0,0 targets:<player>
        - stop