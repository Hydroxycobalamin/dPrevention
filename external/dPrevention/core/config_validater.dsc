## Default config, DO NOT TOUCH.
dPrevention_default_config:
    type: data
    options:
        vehicle-hijacking: false
    claims:
        depth: 0
        flags:
            block-break: true
            block-place: true
            tnt: true
            lighter: true
            pvp: true
            piston: true
            container-access: true
            teleport-item: true
            item-frame-rotation: true
            vehicle-move: true
            vehicle-place:
                - HOPPER_MINECART
        priority: 1
        worlds:
        - world
        - world_nether
        - world_the_end
    user:
        max-blocks-per-time: 2000
        blocks-per-5-min: 25
    shop:
        block-price: 1.5
        blocks:
            - 1
            - 2
            - 10
            - 25
            - 50
            - 100
            - 250
            - 500
            - 1000
    inventories:
        filler-item: air
        hide-flag-permissions: true
        hide-flag-item: gray_stained_glass_pane
dPrevention_config_validation:
    type: world
    debug: false
    events:
        after scripts loaded:
        - run dPrevention_validate_config
dPrevention_validate_config:
    type: task
    debug: false
    script:
        - if !<script[dPrevention_config].exists>:
            - debug error "WARNING: no config file found. You MUST add the config of dPrevention into your server. Using default values Errors will follow."
            - announce to_ops "<&[error]>No dPrevention config file found! Check your console ASAP."
        - define file_path "<dark_red><script[dPrevention_config].relative_filename.if_null[Config file is missing!]><white>"
        #Validate options.vehicle-hijacking
        - run dPrevention_validate_check_boolean def.path:options.vehicle-hijacking def.file_path:<[file_path]>
        #Validate claims.depth
        - run dPrevention_validate_check_integer def.path:claims.depth def.file_path:<[file_path]>
        #Validate claims.flags
        - run dPrevention_validate_check_map def.path:claims.flags def.file_path:<[file_path]>
        - run dPrevention_validate_check_flags def.path:claims.flags def.file_path:<[file_path]>
        #Validate claims.priority
        - run dPrevention_validate_check_integer def.path:claims.priority def.file_path:<[file_path]>
        #Validate claims.worlds
        - run dPrevention_validate_check_list def.path:claims.worlds def.file_path:<[file_path]>
        - run dPrevention_validate_check_worlds def.path:claims.worlds def.file_path:<[file_path]>
        #Validate user.max-blocks-per-time
        - run dPrevention_validate_check_decimal def.path:user.max-blocks-per-time def.file_path:<[file_path]>
        #Validate user.blocks-per-5-min
        - run dPrevention_validate_check_decimal def.path:user.blocks-per-5-min def.file_path:<[file_path]>
        #Validate shop.block-price
        - run dPrevention_validate_check_decimal def.path:shop.block-price def.file_path:<[file_path]>
        #Validate shop.blocks
        - run dPrevention_validate_check_list def.path:shop.blocks def.file_path:<[file_path]>
        - run dPrevention_validate_check_prices def.path:shop.blocks def.file_path:<[file_path]>
        # Validate inventories.filler-item
        - run dPrevention_validate_check_item def.path:inventories.filler-item def.file_path:<[file_path]>
        # Validate inventories.hide-flag-permissions
        - run dPrevention_validate_check_boolean def.path:inventories.hide-flag-permissions def.file_path:<[file_path]>
        # Validate inventories.hide-flag-item
        - run dPrevention_validate_check_item def.path:inventories.hide-flag-item def.file_path:<[file_path]>
        # Apply reconfig depth
        - run dPrevention_apply_config_depth
dPrevention_apply_config_depth:
    type: task
    debug: false
    script:
    # Get all current worlds
    - define worlds <server.flag[dPrevention.config.claims.worlds].parse[as[world]]>
    # Get all cuboid shaped player areas
    - define cuboid_areas <[worlds].filter_tag[<[filter_value].has_flag[dPrevention.areas.cuboids]>].parse_tag[<[parse_value].flag[dPrevention.areas.cuboids]>].combine>
    - foreach <[cuboid_areas]> as:note_name:
        - define cuboid <cuboid[<[note_name]>]>
        # If the cuboid min y is equal depth config, skip.
        - if <[cuboid].min.y> == <server.flag[dPrevention.config.claims.depth]>:
            - foreach next
        # Adjust y of the new cuboid
        - adjust <[cuboid]> set_member:<[cuboid].with_min[<[cuboid].min.with_y[<server.flag[dPrevention.config.claims.depth]>]>]>
dPrevention_validate_get_options:
    type: task
    debug: false
    definitions: path
    script:
    - definemap options:
        config: <script[dPrevention_config].parsed_key[<[path]>].if_null[null]>
        default: <script[dPrevention_default_config].data_key[<[path]>]>
dPrevention_validate_check_boolean:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - if <[options.config]> == null || !<[options.config].is_boolean>:
        - flag server dPrevention.config.<[path]>:<[options.default]>
        - debug error "Config key: <yellow><[path]><white> doesn't exist or is not a valid boolean. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
    - else:
        - flag server dPrevention.config.<[path]>:<[options.config]>
dPrevention_validate_check_decimal:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - if <[options.config]> == null || !<[options.config].is_decimal>:
        - flag server dPrevention.config.<[path]>:<[options.default]>
        - debug error "Config key: <yellow><[path]><white> doesn't exist or is not a valid decimal. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
    - else:
        - flag server dPrevention.config.<[path]>:<[options.config]>
dPrevention_validate_check_list:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - if <[options.config]> == null || !<[options.config].as[list].exists>:
        - debug error "Config key: <yellow><[path]><white> doesn't exist or is not a valid list. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
        - flag server dPrevention.config.<[path]>:<[options.default]>
    - else if <[options.config].is_empty> || <[options.config]> == <empty>:
        - debug error "Config key: <yellow><[path]><white> is empty. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
        - flag server dPrevention.config.<[path]>:<[options.default]>
    - else:
        - flag server dPrevention.config.<[path]>:<[options.config]>
dPrevention_validate_check_map:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - if <[options.config]> == null || !<[options.config].as[map].exists>:
        - flag server dPrevention.config.<[path]>:<[options.default]>
        - debug error "Config key: <yellow><[path]><white> doesn't exist or is not a valid map. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
    - else if <[options.config].is_empty> || <[options.config]> == <empty>:
        - flag server dPrevention.config.<[path]>:<[options.default]>
        - debug error "Config key: <yellow><[path]><white> is empty. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
    - else:
        - flag server dPrevention.config.<[path]>:<[options.config]>
dPrevention_validate_check_item:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - if <[options.config]> == null || !<[options.config].as[item].exists>:
        - flag server dPrevention.config.<[path]>:<[options.default]>
        - debug error "Config key: <yellow><[path]><white> doesn't exist or isn't a valid item. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
    - else:
        - flag server dPrevention.config.<[path]>:<[options.config]>
dPrevention_validate_check_integer:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - if <[options.config]> == null || !<[options.config].is_integer>:
        - flag server dPrevention.config.<[path]>:<[options.default]>
        - debug error "Config key: <yellow><[path]><white> doesn't exist or is not a valid integer. Check your <[file_path]> file! <dark_green>Default: <[options.default]>"
    - else:
        - flag server dPrevention.config.<[path]>:<[options.config]>
dPrevention_validate_check_flags:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - foreach <[options.config]> key:flag as:value:
        - choose <[flag]>:
            - case entities:
                #Check if the flag has values.
                - if <[value]> == <empty>:
                    - debug error "Config key: <yellow>claims.flags.entities<white> doesn't has a value. Check your <[file_path]> file! Ignoring flag."
                    - foreach next
                #Filter invalid and valid entities out.
                - define invalid_entities <[value].filter_tag[<[filter_value].as[entity].if_null[null].equals[null]>]>
                - define valid_entities <[value].exclude[<[invalid_entities]>]>
                #Output errors.
                - if <[invalid_entities].any>:
                    - debug error "Config key: <yellow>claims.flags.entities<white> has invalid values: <[invalid_entities].space_separated>. Check your <[file_path]> file! Ignoring them."
                    - flag server dPrevention.config.claims.flags.entities:<[valid_entities]>
                    - foreach next
                - flag server dPrevention.config.claims.flags.entities:<[valid_entities]>
            - case vehicle-place:
                #Check if the flag has values.
                - if <[value]> == <empty>:
                    - debug error "Config key: <yellow>claims.flags.vehicle-place<white> doesn't has a value. Check your <[file_path]> file! Ignoring flag."
                    - foreach next
                #Filter invalid and valid vehicles out
                - define vehicle_types <server.material_types.filter[advanced_matches[*boat|*minecart]].parse[name]>
                - define invalid_vehicles <[value].filter_tag[<[vehicle_types].contains[<[filter_value]>].not>]>
                - define valid_vehicles <[value].exclude[<[invalid_vehicles]>]>
                #Output errors.
                - if <[invalid_vehicles].any>:
                    - debug error "Config key: <yellow>claims.flags.vehicle-place<white> has invalid values: <[invalid_vehicles].space_separated>. Check your <[file_path]> file! Ignoring them."
                    - flag server dPrevention.config.claims.flags.vehicle-place:<[valid_vehicles]>
                    - foreach next
                - flag server dPrevention.config.claims.flags.vehicle-place:<[valid_vehicles]>
            - default:
                #Check if the flag exists.
                - if !<script[dPrevention_flag_data].data_key[flags].values.contains[<[flag]>]>:
                    - debug error "Flag <[flag]> doesn't exist. Did you make a typo? Check your <[file_path]> file! Ignoring flag."
                    - foreach next
                #Check if the flag has a value.
                - if <[value]> == <empty>:
                    - debug error "Config key: <yellow>claims.flags.vehicle-place<white> doesn't has a value. Check your <[file_path]> file! Ignoring flag."
                    - foreach next
                #Check if the value is a boolean.
                - if !<[value].is_boolean>:
                    - debug error "Flag <[flag]> need a boolean input. <[value]> is not a boolean. Check your <[file_path]> file! <dark_green>Default: true."
                    - flag server dPrevention.config.claims.flags.<[flag]>:true
                    - foreach next
                - else:
                    - flag server dPrevention.config.claims.flags.<[flag]>:<[value]>
dPrevention_validate_check_worlds:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - foreach <[options.config]> as:world_name:
        - define world <world[<[world_name]>].if_null[null]>
        - if <[world]> == null:
            - debug error "World: <[world_name].color[yellow]> doesn't exist or isn't loaded. Check your <[file_path]> file! Ignoring it."
        - else:
            - define valid_worlds:->:<[world_name]>
    - flag server dPrevention.config.<[path]>:<[valid_worlds]>
dPrevention_validate_check_prices:
    type: task
    debug: false
    definitions: path|file_path
    script:
    - inject dPrevention_validate_get_options
    - foreach <[options.config]> as:number:
        - if !<[number].is_integer>:
            - debug error "Config key: <yellow>shop.blocks<white> has invalid values: <[number]>. Check your <[file_path]> file! Ignoring them."
            - foreach next
        - else:
            - define valid_numbers:->:<[number]>
    - flag server dPrevention.config.shop.blocks:<[valid_numbers]>