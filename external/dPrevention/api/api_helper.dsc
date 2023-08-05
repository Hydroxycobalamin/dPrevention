dP_get_area:
    type: procedure
    debug: false
    definitions: area
    script:
    - if <[area].as[CuboidTag].exists>:
        - determine cuboids
    - else if <[area].as[PolygonTag].exists>:
        - determine polygons
    - else if <[area].as[EllipsoidTag].exists>:
        - determine ellipsoids
    - else:
        - determine null
dP_area_is_valid:
    type: procedure
    debug: false
    definitions: area
    script:
    - if <[area].as[WorldTag].exists>:
        - determine true
    - define admin_areas <[area].world.flag[dPrevention.areas.admin].values.combine.if_null[<list>]>
    - define player_areas <[area].world.flag[dPrevention.areas].exclude[admin].values.combine.if_null[<list>]>
    - define areas <[admin_areas].include[<[player_areas]>]>
    - if <[areas]> not contains <[area]>:
        - determine false
    - if !<[area].has_flag[dPrevention]>:
        - determine false
    - determine true