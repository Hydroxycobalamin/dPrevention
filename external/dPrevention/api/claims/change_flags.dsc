## <--[task]
## @name dPrevention_api_change_flags
## @input area:<AreaTag> flag:<flag_name> value:<ListTag(EntityTag/MaterialTag)>/Boolean
## @description
## Toggles or sets a flag value.
## For 'entities' the value is a ListTag of entities, that should be prevent from spawning. An empty <list> input will allow any mob to spawn.
## For 'vehicle-place' the value is a ListTag of materials, that should be prevent from placing. An empty <list> input will allow any vehicle to place.
## For everything else, the value is a boolean. Set 'true' to prevent, 'false' to allow.
## @Usage
## # Use to prevent tnt from exploding on a claim.
## - run dPrevention_api_change_flags def.area:<cuboid[dPrevention_claim]> flag:tnt value:true
## @Script dPrevention
## -->
dPrevention_api_change_flags:
    type: task
    debug: false
    definitions: area|flag|value
    script:
    - if !<[area].exists>:
        - debug error "<&[error]>Definition '<element[area].custom_color[emphasis]>' does not exist. Did you forget to pass it over?"
        - stop
    - if !<[value].exists>:
        - debug error "<&[error]>Definition '<element[value].custom_color[emphasis]>' does not exist. Did you forget to pass it over?"
        - stop
    - if !<proc[dP_area_is_valid].context[<[area]>]>:
        - debug error "<&[error]>Area '<[area].custom_color[emphasis]>' is not a valid dPrevention area. Did you forget to convert it first?"
        - stop
    - define toggleable_flags <script[dPrevention_flag_data].data_key[toggleable_flags]>
    - define input_flags <script[dPrevention_flag_data].data_key[input_flags]>
    # Toggleable
    - if <[toggleable_flags]> contains <[flag]>:
        - if <[value]>:
            - flag <[area]> dPrevention.flags.<[flag]>
        - else:
            - flag <[area]> dPrevention.flags.<[flag]>:!
    # Input
    - else if <[input_flags]> contains <[flag]>:
        # 'entities'
        - if <[flag]> == entities:
            - define value <[value].as[ListTag].if_null[null]>
            - if <[value]> == null:
                - debug error "<&[error]>Input is not valid. Input was '<[value]>' which is not a valid ListTag or ElementTag."
                - stop
            - if <[value].is_empty>:
                - flag <[area]> dPrevention.flags.<[flag]>:!
            - define entity_types <server.entity_types.exclude[PLAYER].parse[as_entity]>
            - foreach monster|animal|mob|living as:matcher:
                - if <[value]> contains <[matcher]>:
                    - define value <[value].replace[<[matcher]>].with[<[entity_types].filter[advanced_matches[<[matcher]>]].parse[entity_type]>]>
            - foreach <[value].combine.deduplicate> as:entity:
                - if !<[entity].as[EntityTag].exists>:
                    - debug error "<&[error]>'<[entity].custom_color[emphasis]> is not a valid entity type. Did you mean '<[entity_types].closest_to[<[entity]>]>'?"
                    - stop
                - define entities:->:<[entity].to_uppercase>
            - flag <[area]> dPrevention.flags.<[flag]>:<[entities]>
        # 'vehicle-place'
        - else if <[flag]> == vehicle-place:
            - define value <[value].as[ListTag].if_null[null]>
            - if <[value]> == null:
                - debug error "<&[error]>Input is not valid. Input was '<[value]>' which is not a valid ListTag or ElementTag."
                - stop
            - if <[value].is_empty>:
                - flag <[area]> dPrevention.flags.<[flag]>:!
            - define vehicle_types <server.material_types.filter[advanced_matches[*boat|*minecart]].parse[name]>
            - if <[value]> contains all:
                - define value <[vehicle_types]>
            - foreach <[value].combine.deduplicate> as:material:
                - if !<[material].as[ItemTag].exists>:
                    - debug error "<&[error]>'<[material].custom_color[emphasis]> is not a valid ItemTag. Did you mean '<[vehicle_types].closest_to[<[entity]>]>'?"
                    - stop
                - define vehicles:->:<[entity].to_uppercase>
            - flag <[area]> dPrevention.flags.<[flag]>:<[vehicles]>
    - else:
        - debug error "<&[error]>'<[flag].custom_color[emphasis]>' is not a valid flag. Did you mean '<[toggleable_flags].include[<[input_flags]>].closest_to[<[flag]>].custom_color[emphasis]>'?"