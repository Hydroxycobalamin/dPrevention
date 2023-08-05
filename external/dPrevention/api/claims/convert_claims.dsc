## <--[task]
## @name dPrevention_api_convert_claim_player
## @input area:<AreaTag> owner:<PlayerTag>
## @description
## Converts an already noted AreaObject into a dPrevention claim.
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
    - define type <[area].proc[dp_get_area]>
    - if <[type]> == null:
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
## <--[task]
## @name dPrevention_api_convert_claim_admin
## @input area:<AreaTag>
## @description
## Converts an already noted AreaObject into a dPrevention admin claim.
## @Usage
## # Use to convert an area into a dPrevention admin claim.
## - run dPrevention_api_convert_claim_player def.area:<cuboid[MyFancyCuboid]>
## @Script dPrevention
## -->
dPrevention_api_convert_claim_admin:
    type: task
    debug: false
    definitions: area
    script:
    - define type <[area].proc[dp_get_area]>
    - if <[type]> == null:
        - debug error "<&[error]>Area '<[area].custom_color[emphasis]>' is not a valid AreaTag."
        - stop
    - if !<[area].note_name.exists>:
        - debug error "<&[error]>Area is not a valid noted object. Did you forget to note it?"
        - stop
    - if <[area].world.flag[dPrevention.areas.admin.<[type]>].contains[<[area]>].if_null[false]>:
        - debug error "<[area].note_name.custom_color[emphasis]> <&[error]>is already an admin claim."
        - stop
    - flag <[area].world> dPrevention.areas.admin.<[type]>:->:<[area]>
    - run dPrevention_area_creation def.area:<[area]>