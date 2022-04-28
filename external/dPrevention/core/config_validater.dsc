dPrevention_config_validation:
    type: world
    debug: false
    data:
        default_options:
            shop:
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
            claims:
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
                worlds:
                    - world
                    - world_nether
                    - world_the_end
            scripters:
                flags:
                    - dPrevention
    events:
        after reload scripts:
        - run dPrevention_validate_config
        after server start:
        - run dPrevention_validate_config
dPrevention_validate_config:
    type: task
    debug: false
    script:
        - if !<script[dPrevention_config].exists>:
            - debug error "WARNING: no config file found. You MUST add the config of dPrevention into your server. Using default values Errors will follow."
            - announce to_ops "<&[error]>No dPrevention config file found! Check your console ASAP."
        - define script_path "<dark_red><script[dPrevention_config].relative_filename.if_null[config not found!]><white>"
        - define config <script[dPrevention_config].data_key[].if_null[null]>
        #Validate options.vehicle-hijacking
        - if !<[config.options.vehicle-hijacking].exists> || !<[config.options.vehicle-hijacking].is_boolean>:
            - flag server dPrevention.config.options.vehicle-hijacking:false
            - debug error "Config key: <yellow>options.vehicle-hijacking<white> doesn't exist or is not a valid integer. Check your <[script_path]> file! <dark_green>Default: false"
        - else:
            - flag server dPrevention.config.options.vehicle-hijacking:<[config.options.vehicle-hijacking]>
        #Validate claims.depth
        - if !<[config.claims.depth].exists> || !<[config.claims.depth].is_integer>:
            - debug error "Config key: <yellow>claims.depth<white> doesn't exist or is not a valid integer. Check your <[script_path]> file! <dark_green>Default: 0"
            - flag server dPrevention.config.claims.depth:0
        - else:
            - flag server dPrevention.config.claims.depth:<[config.claims.depth]>
        #Validate claims.flags
        - if !<[config.claims.flags].exists>:
            - debug error "Config key: <yellow>claims.flags<white> doesn't exist. Check your <[script_path]> file! <dark_green>Default: <script.data_key[data.default_options.claims.flags]>"
            - flag server dPrevention.config.claims.flags:<script.data_key[data.default_options.claims.flags]>
        - else if <[config.claims.flags]> == <empty>:
            - debug error "Config key: <yellow>claims.flags<white> is empty. Check your <[script_path]> file! <dark_green>Default: <script.data_key[data.default_options.claims.flags]>"
            - flag server dPrevention.config.claims.flags:<script.data_key[data.default_options.claims.flags]>
        - else if <[config.claims.flags].as_map.if_null[null]> == null:
            - debug error "Config key: <yellow>claims.flags<white> is not a valid map of flag: values. Check your <[script_path]> file! <dark_green>Default: <script.data_key[data.default_options.claims.flags]>"
            - flag server dPrevention.config.claims.flags:<script.data_key[data.default_options.claims.flags]>
        - else:
            - foreach <[config.claims.flags]> key:flag as:value:
                - choose <[flag]>:
                    - case entities:
                        #Check if the flag has values.
                        - if <[value]> == <empty>:
                            - debug error "Config key: <yellow>claims.flags.entities<white> doesn't has a value. Check your <[script_path]> file! Ignoring flag."
                            - foreach next
                        #Filter invalid and valid entities out.
                        - define invalid_entities <[value].filter_tag[<[filter_value].as_entity.if_null[null].equals[null]>]>
                        - define valid_entities <[value].exclude[<[invalid_entities]>]>
                        #Output errors.
                        - if <[invalid_entities].any>:
                            - debug error "Config key: <yellow>claims.flags.entities<white> has invalid values: <[invalid_entities].space_separated>. Check your <[script_path]> file! Ignoring them."
                            - flag server dPrevention.config.claims.flags.entities:<[valid_entities]>
                            - foreach next
                        - flag server dPrevention.config.claims.flags.entities:<[valid_entities]>
                    - case vehicle-place:
                        #Check if the flag has values.
                        - if <[value]> == <empty>:
                            - debug error "Config key: <yellow>claims.flags.vehicle-place<white> doesn't has a value. Check your <[script_path]> file! Ignoring flag."
                            - foreach next
                        #Filter invalid and valid vehicles out
                        - define vehicle_types <server.material_types.filter[advanced_matches[*boat|*minecart]].parse[name]>
                        - define invalid_vehicles <[value].filter_tag[<[vehicle_types].contains[<[filter_value]>].not>]>
                        - define valid_vehicles <[value].exclude[<[invalid_vehicles]>]>
                        #Output errors.
                        - if <[invalid_vehicles].any>:
                            - debug error "Config key: <yellow>claims.flags.vehicle-place<white> has invalid values: <[invalid_vehicles].space_separated>. Check your <[script_path]> file! Ignoring them."
                            - flag server dPrevention.config.claims.flags.vehicle-place:<[valid_vehicles]>
                            - foreach next
                        - flag server dPrevention.config.claims.flags.vehicle-place:<[valid_vehicles]>
                    - default:
                        #Check if the flag exists.
                        - if !<script[dPrevention_flag_data].data_key[flags].values.contains[<[flag]>]>:
                            - debug error "Flag <[flag]> doesn't exist. Did you make a typo? Check your <[script_path]> file! Ignoring flag."
                            - foreach next
                        #Check if the value is a boolean.
                        - if !<[value].is_boolean>:
                            - debug error "Flag <[flag]> need a boolean input. <[value]> is not a boolean. Check your <[script_path]> file! <dark_green>Default: true."
                            - flag server dPrevention.config.claims.flags.<[flag]>:true
                            - foreach next
                        - else:
                            - flag server dPrevention.config.claims.flags.<[flag]>:<[value]>
        #Validate claims.priority
        - if !<[config.claims.priority].exists> || !<[config.claims.priority].is_integer>:
            - flag server dPrevention.config.claims.priority:0
            - debug error "Config key: <yellow>claims.priority<white> doesn't exist or is not a valid integer. Check your <[script_path]> file! <dark_green>Default: 0"
        - else:
            - flag server dPrevention.config.claims.priority:<[config.claims.priority]>
        #Validate claims.worlds
        - if !<[config.claims.worlds].exists>:
            - flag server dPrevention.config.claims.worlds:<script.data_key[data.default_options.claims.worlds]>
            - debug error "Config key: <yellow>claims.worlds<white> doesn't exist. Check your <[script_path]> file! <dark_green>Default: <script.data_key[data.default_options.claims.worlds].space_separated>"
        - else if <[config.claims.worlds]> == <empty>:
            - flag server dPrevention.config.claims.worlds:<script.data_key[data.default_options.claims.worlds]>
            - debug error "Config key: <yellow>claims.worlds<white> is empty. Check your <[script_path]> file! <dark_green>Default: <script.data_key[data.default_options.claims.worlds].space_separated>"
        - else:
            - foreach <[config.claims.worlds]> as:world_name:
                - define world <world[<[world_name]>].if_null[null]>
                - if <[world]> == null:
                    - debug error "World: <[world_name].color[yellow]> doesn't exist or isn't loaded. Check your <[script_path]> file! Ignoring it."
                - else:
                    - define valid_worlds:->:<[world_name]>
            - flag server dPrevention.config.claims.worlds:<[valid_worlds]>
        #Validate user.max-blocks-per-time
        - if !<[config.user.max-blocks-per-time].exists> || !<[config.user.max-blocks-per-time].is_integer>:
            - flag server dPrevention.config.user.max-blocks-per-time:2000
            - debug error "Config key: <yellow>user.max-blocks-per-time<white> doesn't exist or is not a valid integer. Check your <[script_path]> file! <dark_green>Default: 2000"
        - else:
            - flag server dPrevention.config.user.max-blocks-per-time:<[config.user.max-blocks-per-time]>
        #Validate user.max-blocks-per-time-per-player
        - if !<[config.user.blocks-per-5-min].exists> || !<[config.user.blocks-per-5-min].is_decimal>:
            - flag server dPrevention.config.user.blocks-per-5-min:25
            - debug error "Config key: <yellow>user.blocks-per-5-min<white> doesn't exist or is not a valid decimal. Check your <[script_path]> file! <dark_green>Default: 25"
        - else:
            - flag server dPrevention.config.user.blocks-per-5-min:<[config.user.blocks-per-5-min]>
        #Validate shop.block-price
        - if !<[config.shop.block-price].exists> || !<[config.shop.block-price].is_decimal>:
            - flag server dPrevention.config.shop.block-price:1.5
            - debug error "Config key: <yellow>shop.block-price<white> doesn't exist or is not a valid decimal. Check your <[script_path]> file! <dark_green>Default: 1.5"
        - else:
            - flag server dPrevention.config.shop.block-price:<[config.shop.block-price]>
        #Validate shop.blocks
        - if !<[config.shop.blocks].exists>:
            - debug error "Config key: <yellow>shop.blocks<white> doesn't exist. <dark_green>Default: <script.data_key[data.default_options.shop.blocks].space_separated>"
            - flag server dPrevention.config.shop.blocks:<script.data_key[data.default_options.shop.blocks]>
        - else if <[config.shop.blocks]> == <empty>:
            - debug error "Config key: <yellow>shop.blocks<white> is empty. <dark_green>Default: <script.data_key[data.default_options.shop.blocks].space_separated>"
            - flag server dPrevention.config.shop.blocks:<script.data_key[data.default_options.shop.blocks]>
        - else:
            - foreach <[config.shop.blocks]> as:number:
                - if !<[number].is_integer>:
                    - debug error "Config key: <yellow>shop.blocks<white> has invalid values: <[number]>. Check your <[script_path]> file! Ignoring them."
                    - foreach next
                - else:
                    - define valid_numbers:->:<[number]>
            - flag server dPrevention.config.shop.blocks:<[valid_numbers]>
        #Validate inventories.filler_item
        - define item <[config.inventories.filler_item].as_item.if_null[null]>
        - if <[item]> == null:
            - flag server dPrevention.config.inventories.filler_item:air
            - debug error "Config key: <yellow>inventories.filler_item<white> doesn't exist or isn't a valid item. Check your <[script_path]> file! <dark_green>Default: air"
        - else:
            - flag server dPrevention.config.inventories.filler_item:<[config.inventories.filler_item]>
        #Validate scripters.flags
        - if !<[config.scripters.flags].exists>:
            - flag server dPrevention.config.scripters.flags:<script.data_key[data.default_options.scripters.flags]>
            - debug error "Config key: <yellow>scripters.flags<white> doesn't exist. Check your <[script_path]> file! <dark_green>Default: <script.data_key[data.default_options.scripters.flags].space_separated>"
        - else if !<[config.scripters.flags].contains[dPrevention]>:
            - debug error "Config key: <yellow>scripters.flags<white> value dPrevention was removed in your config file. Check your <[script_path]> file! <dark_green>Default: <script.data_key[data.default_options.scripters.flags].space_separated>"
            - flag server dPrevention.config.scripters.flags:<script.data_key[data.default_options.scripters.flags]>
        - else:
            - flag server dPrevention.config.scripters.flags:<[config.scripters.flags]>
        - run dPrevention_apply_config_depth
dPrevention_apply_config_depth:
    type: task
    debug: false
    script:
    #Get all current worlds
    - define worlds <server.flag[dPrevention.config.claims.worlds].parse[as_world]>
    #Get all cuboid shaped player areas
    - define cuboid_areas <[worlds].filter_tag[<[filter_value].has_flag[dPrevention.areas.cuboids]>].parse_tag[<[parse_value].flag[dPrevention.areas.cuboids]>].combine>
    - foreach <[cuboid_areas]> as:note_name:
        - define cuboid <cuboid[<[note_name]>]>
        #If the cuboid min y is equal depth config, skip.
        - if <[cuboid].min.y> == <server.flag[dPrevention.config.claims.depth]>:
            - foreach next
        #Else, save the flags for later use
        - foreach <server.flag[dPrevention.config.scripters.flags]> as:flag:
            - if !<[cuboid].has_flag[<[flag]>]>:
                - foreach next
            - define data.<[flag]>:<[cuboid].flag[<[flag]>]>
        #Note the new cuboid
        - note <[cuboid].with_min[<[cuboid].min.with_y[<server.flag[dPrevention.config.claims.depth]>]>]> as:<[note_name]>
        - define new_cuboid <cuboid[<[note_name]>]>
        #Apply flags on the new cuboid
        - foreach <[data]> key:name as:value:
            - flag <[new_cuboid]> <[name]>:<[value]>