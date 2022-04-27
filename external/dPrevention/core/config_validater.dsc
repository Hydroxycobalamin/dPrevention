config_validation:
    type: world
    debug: false
    data:
        default_options:
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
            worlds:
                - world
                - world_nether
                - world_the_end
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
    events:
        after reload scripts:
        - if !<script[dPrevention_config].exists>:
            - debug error "WARNING: no config file found. You MUST add the config of dPrevention into your server. Using default values."
        - define config <script[dPrevention_config].data_key[].if_null[null]>
        #Validate options.vehicle-hijacking
        - if !<[config.options.vehicle-hijacking].exists> || !<[config.options.vehicle-hijacking].is_boolean>:
            - flag server dPrevention.config.options.vehicle-hijacking:false
            - debug error "Config key: options.vehicle-hijacking doesn't exist or is not a valid integer. Check your dPrevention/config.dsc file! Default: false"
        - else:
            - flag server dPrevention.config.options.vehicle-hijacking:<[config.options.vehicle-hijacking]>
        #Validate claims.depth
        - if !<[config.claims.depth].exists> || !<[config.claims.depth].is_integer>:
            - debug error "Config key: claims.depth doesn't exist or is not a valid integer. Check your dPrevention/config.dsc file! Default: 0"
            - flag server dPrevention.config.claims.depth:0
        - else:
            - flag server dPrevention.config.claims.depth:<[config.claims.depth]>
        #Validate claims.flags
        - if !<[config.claims.flags].exists>:
            - debug error "Config key: claims.flags doesn't exist. Check your dPrevention/config.dsc file! Default: <script.data_key[data.default_options.flags]>"
            - flag server dPrevention.config.claims.flags:<script.data_key[data.default_options.flags]>
        - if <[config.claims.flags]> == <empty>:
            - debug error "Config key: claims.flags is empty. Check your dPrevention/config.dsc file! Default: <script.data_key[data.default_options.flags]>"
            - flag server dPrevention.config.claims.flags:<script.data_key[data.default_options.flags]>
        - if <[config.claims.flags].as_map.if_null[null]> == null:
            - debug error "Config key: claims.flags is not a valid map of flag: values. Check your dPrevention/config.dsc file! Default: <script.data_key[data.default_options.flags]>"
            - flag server dPrevention.config.claims.flags:<script.data_key[data.default_options.flags]>
        - else:
            - foreach <[config.claims.flags]> key:flag as:value:
                - choose <[flag]>:
                    - case entities:
                        #Check if the flag has values.
                        - if <[value]> == <empty>:
                            - debug error "Config key: claims.flags.entities doesn't has a value. Check your dPrevention/config.dsc file! Ignoring flag."
                            - foreach next
                        #Filter invalid and valid entities out.
                        - define invalid_entities <[value].filter_tag[<[filter_value].as_entity.if_null[null].equals[null]>]>
                        - define valid_entities <[value].exclude[<[invalid_entities]>]>
                        #Output errors.
                        - if <[invalid_entities].any>:
                            - debug error "Config key: claims.flags.entities has invalid values: <[invalid_entities].space_separated>. Check your dPrevention/config.dsc file! Ignoring them."
                            - flag server dPrevention.config.claims.flags.entities:<[valid_entities]>
                            - foreach next
                        - flag server dPrevention.config.claims.flags.entities:<[valid_entities]>
                    - case vehicle-place:
                        #Check if the flag has values.
                        - if <[value]> == <empty>:
                            - debug error "Config key: claims.flags.vehicle-place doesn't has a value. Check your dPrevention/config.dsc file! Ignoring flag."
                            - foreach next
                        #Filter invalid and valid vehicles out
                        - define vehicle_types <server.material_types.filter[advanced_matches[*boat|*minecart]].parse[name]>
                        - define invalid_vehicles <[value].filter_tag[<[vehicle_types].contains[<[filter_value]>].not>]>
                        - define valid_vehicles <[value].exclude[<[invalid_vehicles]>]>
                        #Output errors.
                        - if <[invalid_vehicles].any>:
                            - debug error "Config key: claims.flags.vehicle-place has invalid values: <[invalid_vehicles].space_separated>. Check your dPrevention/config.dsc file! Ignoring them."
                            - flag server dPrevention.config.claims.flags.vehicle-place:<[valid_vehicles]>
                            - foreach next
                        - flag server dPrevention.config.claims.flags.vehicle-place:<[valid_vehicles]>
                    - default:
                        #Check if the flag exists.
                        - if !<script[dPrevention_flag_data].data_key[flags].values.contains[<[flag]>]>:
                            - debug error "Flag <[flag]> doesn't exist. Did you make a typo? Check your dPrevention/config.dsc file! Ignoring flag."
                            - foreach next
                        #Check if the value is a boolean.
                        - if !<[value].is_boolean>:
                            - debug error "Flag <[flag]> need a boolean input. <[value]> is not a boolean. Check your dPrevention/config.dsc file! Default: true."
                            - flag server dPrevention.config.claims.flags.<[flag]>:true
                            - foreach next
                        - else:
                            - flag server dPrevention.config.claims.flags.<[flag]>:<[value]>
        #Validate claims.priority
        - if !<[config.claims.priority].exists> || !<[config.claims.priority].is_integer>:
            - flag server dPrevention.config.claims.priority:0
            - debug error "Config key: claims.priority doesn't exist or is not a valid integer. Check your dPrevention/config.dsc file! Default: 0"
        - else:
            - flag server dPrevention.config.claims.priority:<[config.claims.priority]>
        #Validate claims.worlds
        - if !<[config.claims.worlds].exists>:
            - flag server dPrevention.config.claims.worlds:<script.data_key[data.default_options.worlds]>
            - debug error "Config key: claims.worlds doesn't exist. Check your dPrevention/config.dsc file! Default: <script.data_key[data.default_options.worlds].space_separated>"
        - else if <[config.claims.worlds]> == <empty>:
            - flag server dPrevention.config.claims.worlds:<script.data_key[data.default_options.worlds]>
            - debug error "Config key: claims.worlds is empty. Check your dPrevention/config.dsc file! Default: <script.data_key[data.default_options.worlds].space_separated>"
        - else:
            - foreach <[config.claims.worlds]> as:world_name:
                - define world <world[<[world_name]>].if_null[null]>
                - if <[world]> == null:
                    - debug error "World: <[world_name]> doesn't exist or isn't loaded. Check your dPrevention/config.dsc file! Ignoring it."
                - else:
                    - define valid_worlds:->:<[world_name]>
            - flag server dPrevention.config.claims.worlds:<[valid_worlds]>
        #Validate user.max-blocks-per-time
        - if !<[config.user.max-blocks-per-time].exists> || !<[config.user.max-blocks-per-time].is_integer>:
            - flag server dPrevention.config.user.max-blocks-per-time:2000
            - debug error "Config key: user.max-blocks-per-time doesn't exist or is not a valid integer. Check your dPrevention/config.dsc file! Default: 2000"
        - else:
            - flag server dPrevention.config.user.max-blocks-per-time:<[config.user.max-blocks-per-time]>
        #Validate user.max-blocks-per-time-per-player
        - if !<[config.user.blocks-per-5-min].exists> || !<[config.user.blocks-per-5-min].is_decimal>:
            - flag server dPrevention.config.user.blocks-per-5-min:25
            - debug error "Config key: user.blocks-per-5-min doesn't exist or is not a valid decimal. Check your dPrevention/config.dsc file! Default: 25"
        - else:
            - flag server dPrevention.config.user.blocks-per-5-min:<[config.user.blocks-per-5-min]>
        #Validate shop.block-price
        - if !<[config.shop.block-price].exists> || !<[config.shop.block-price].is_decimal>:
            - flag server dPrevention.config.shop.block-price:1.5
            - debug error "Config key: shop.block-price doesn't exist or is not a valid decimal. Check your dPrevention/config.dsc file! Default: 1.5"
        - else:
            - flag server dPrevention.config.shop.block-price:<[config.shop.block-price]>
        #Validate shop.blocks
        - if !<[config.shop.blocks].exists>:
            - debug error "Config key: shop.blocks doesn't exist. Default: <script.data_key[data.default_options.blocks].space_separated>"
            - flag server dPrevention.config.shop.blocks:<script.data_key[data.default_options.blocks]>
        - else if <[config.shop.blocks]> == <empty>:
            - debug error "Config key: shop.blocks is empty. Default: <script.data_key[data.default_options.blocks].space_separated>"
            - flag server dPrevention.config.shop.blocks:<script.data_key[data.default_options.blocks]>
        - else:
            - foreach <[config.shop.blocks]> as:number:
                - if !<[number].is_integer>:
                    - debug error "Config key: shop.blocks has invalid values: <[number]>. Check your dPrevention/config.dsc file! Ignoring them."
                    - foreach next
                - else:
                    - define valid_numbers:->:<[number]>
            - flag server dPrevention.config.shop.blocks:<[valid_numbers]>
        #Validate inventories.filler_item
        - define item <[config.inventories.filler_item].as_item.if_null[null]>
        - if <[item]> == null:
            - flag server dPrevention.config.inventories.filler_item:air
            - debug error "Config key: inventories.filler_item doesn't exist or isn't a valid item. Check your dPrevention/config.dsc file! Default: air"
        - else:
            - flag server dPrevention.config.inventories.filler_item:<[config.inventories.filler_item]>