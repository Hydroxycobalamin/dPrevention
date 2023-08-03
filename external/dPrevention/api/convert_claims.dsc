## <--[task]
## @name dPrevention_api_convert_claim_player
## @input area:<AreaTag> owner:<PlayerTag>
## @description
## Converts an existing AreaObject into a dPrevention claim.
## @Usage
## # Use to convert an area into a dPrevention claim.
## - run dPrevention_api_convert_claim_player def.area:<cuboid[MyFancyCuboid]> def.owner:<player>
## @Script dPrevention
## -->
dPrevention_api_convert_claim_player:
    type: task
    debug: false
    definitions: area|owner
    script:
    - if <[area].as[CuboidTag].exists>:
        - define type cuboids
    - else if <[area].as[PolygonTag].exists>:
        - define type polygons
    - else if <[area].as[EllipsoidTag].exists>:
        - define type ellipsoids
    - else:
        - debug error "<&[error]>Area '<[area].custom_color[emphasis]>' is not a valid AreaTag."
        - stop
    - if !<[area].note_name.exists>:
        - debug error "<&[error]>Area is not a valid noted object. Did you forget to note it?"
        - stop
    - if !<[owner].as[PlayerTag].exists>:
        - debug error "<&[error]>Player '<[owner].custom_color[emphasis]>' is not a valid PlayerTag."
        - stop
    - flag <[owner]> dPrevention.areas.<[type]>:->:<[area]>
    - flag <[area].world> dPrevention.areas.<[type]>:->:<[area]>
    - run dPrevention_area_creation def.area:<[area]> def.owner:<[owner]>