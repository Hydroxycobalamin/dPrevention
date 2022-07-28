dPrevention_player_flag_handlers:
    type: world
    debug: false
    events:
        ##block-break
        on player breaks block in:world_flagged:dPrevention.flags.block-break priority:100:
        - definemap arguments flag:block-break "reason:You can't break this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player breaks block in:area_flagged:dPrevention.flags.block-break priority:50:
        - definemap arguments flag:block-break "reason:You can't break this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player breaks hanging in:world_flagged:dPrevention.flags.block-break priority:100:
        - definemap arguments flag:block-break "reason:You can't break this hanging here." location:<context.hanging.location>
        - inject dPrevention_initial_check
        on player breaks hanging in:area_flagged:dPrevention.flags.block-break priority:50:
        - definemap arguments flag:block-break "reason:You can't break this hanging here." location:<context.hanging.location>
        - inject dPrevention_initial_check
        on player fills bucket in:world_flagged:dPrevention.flags.block-break priority:100:
        - definemap arguments flag:block-break "reason:You can't break this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player fills bucket in:area_flagged:dPrevention.flags.block-break priority:50:
        - definemap arguments flag:block-break "reason:You can't break this block here." location:<context.location>
        - inject dPrevention_initial_check
        ##block-place
        on player places hanging in:area_flagged:dPrevention.flags.block-place priority:50:
        - definemap arguments flag:block-place "reason:You can't place this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player places hanging in:world_flagged:dPrevention.flags.block-place priority:100:
        - definemap arguments flag:block-place "reason:You can't place this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player places block in:world_flagged:dPrevention.flags.block-place priority:100:
        - definemap arguments flag:block-place "reason:You can't place this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player places block in:area_flagged:dPrevention.flags.block-place priority:50:
        - definemap arguments flag:block-place "reason:You can't place this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks *item_frame in:world_flagged:dPrevention.flags.block-place priority:100 with:!air:
        - if <context.entity.has_framed_item>:
            - stop
        - definemap arguments flag:block-place "reason:You can't put your item into this item frame." location:<context.entity.location>
        - inject dPrevention_initial_check
        on player right clicks *item_frame in:area_flagged:dPrevention.flags.block-place priority:50 with:!air:
        - if <context.entity.has_framed_item>:
            - stop
        - definemap arguments flag:block-place "reason:You can't put your item into this item frame." location:<context.entity.location>
        - inject dPrevention_initial_check
        on player empties bucket in:world_flagged:dPrevention.flags.block-place priority:100:
        - definemap arguments flag:block-place "reason: You can't place this block here." location:<context.relative>
        - inject dPrevention_initial_check
        on player empties bucket in:area_flagged:dPrevention.flags.block-place priority:50:
        - definemap arguments flag:block-place "reason: You can't place this block here." location:<context.relative>
        - inject dPrevention_initial_check
        ##use
        on player right clicks *door|lever|*_button|anvil|*campfire in:world_flagged:dPrevention.flags.use priority:100:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks *door|lever|*_button|anvil|*campfire in:area_flagged:dPrevention.flags.use priority:50:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player stands on material in:world_flagged:dPrevention.flags.use priority:100:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player stands on material in:area_flagged:dPrevention.flags.use priority:50:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        ##lighter
        on player right clicks !*air with:flint_and_steel|fire_charge in:world_flagged:dPrevention.flags.lighter priority:100:
        - definemap arguments flag:lighter "reason:You can't use this item here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks !*air with:flint_and_steel|fire_charge in:area_flagged:dPrevention.flags.lighter priority:50:
        - definemap arguments flag:lighter "reason:You can't use this item here." location:<context.location>
        - inject dPrevention_initial_check
        ##pvp
        on player damaged by player in:world_flagged:dPrevention.flags.pvp priority:100:
        - definemap arguments flag:pvp "reason:PvP is disabled in this region." location:<context.entity.location>
        - inject dPrevention_initial_check
        on player damaged by player in:area_flagged:dPrevention.flags.pvp priority:50:
        - definemap arguments flag:pvp "reason:PvP is disabled in this region." location:<context.entity.location>
        - inject dPrevention_initial_check
        ##container-access
        on player opens inventory in:world_flagged:dPrevention.flags.container-access priority:100:
        - define id_holder <context.inventory.id_holder>
        - define id_type <context.inventory.id_type>
        #Allow opening of enderchests.
        - if <[id_holder]> == ender_chest:
            - stop
        #If it's not a block with an persistent inventory(like workbenches, smithing tables, grindstones), allow it.
        - if <[id_type]> != location && <[id_type]> != entity:
            - stop
        #Allow any script inventories.
        - if <context.inventory.id_type> == script:
            - stop
        - definemap arguments flag:container-access "reason:You can't open that here." location:<[id_holder].location.if_null[<[id_holder]>]>
        - inject dPrevention_initial_check
        on player opens inventory in:area_flagged:dPrevention.flags.container-access priority:50:
        - define id_holder <context.inventory.id_holder>
        - define id_type <context.inventory.id_type>
        #Allow opening of enderchests.
        - if <[id_holder]> == ender_chest:
            - stop
        #If it's not a block with an persistent inventory(like workbenches, smithing tables, grindstones), allow it.
        - if <[id_type]> != location && <[id_type]> != entity:
            - stop
        #Allow any script inventories.
        - if <context.inventory.id_type> == script:
            - stop
        - definemap arguments flag:container-access "reason:You can't open that here." location:<[id_holder].location.if_null[<[id_holder]>]>
        - inject dPrevention_initial_check
        #Prevent the player from taking items out of item frames.
        on *item_frame damaged by player in:area_flagged:dPrevention.flags.container-access priority:50:
        - definemap arguments flag:container-access "reason:You can't take this item." location:<context.entity.location>
        - inject dPrevention_initial_check
        on *item_frame damaged by player in:world_flagged:dPrevention.flags.container-access priority:100:
        - definemap arguments flag:container-access "reason:You can't take this item." location:<context.entity.location>
        - inject dPrevention_initial_check
        ##teleport-item
        on player teleports cause:CHORUS_FRUIT|ENDER_PEARL:
        - definemap arguments flag:teleport-item "reason:You can't teleport in this area." location:<context.destination>
        - inject dPrevention_initial_check
        ##item-frame-rotation
        on player right clicks *item_frame in:world_flagged:dPrevention.flags.item-frame-rotation priority:100:
        - definemap arguments flag:item-frame-rotation "reason:You can't turn this here" location:<context.entity.location>
        - inject dPrevention_initial_check
        on player right clicks *item_frame in:area_flagged:dPrevention.flags.item-frame-rotation priority:50:
        - definemap arguments flag:item-frame-rotation "reason:You can't turn this here" location:<context.entity.location>
        - inject dPrevention_initial_check
        ##vehicle-ride
        on player enters vehicle priority:100:
        - definemap arguments flag:vehicle-ride "reason:You can't enter this vehicle here." location:<context.entity.location>
        - inject dPrevention_prevent_vehicle_hijacking
        ##vehicle-placed
        on player right clicks !*air with:*boat|*minecart in:world_flagged:dPrevention.flags.vehicle-place priority:100:
        - definemap arguments flag:vehicle-place "reason:You can't place this here." location:<context.location>
        - inject dPrevention_prevent_vehicle_placing
        on player right clicks !*air with:*boat|*minecart in:area_flagged:dPrevention.flags.vehicle-place priority:50:
        - definemap arguments flag:vehicle-place "reason:You can't place this here." location:<context.location>
        - inject dPrevention_prevent_vehicle_placing
dPrevention_generic_flag_handlers:
    type: world
    debug: false
    events:
        ##fire-damage
        on block burns in:world_flagged:dPrevention.flags.fire-damage priority:100:
        - definemap arguments flag:fire-damage location:<context.location>
        - inject dPrevention_initial_block_check
        on block burns in:area_flagged:dPrevention.flags.fire-damage priority:50:
        - definemap arguments flag:fire-damage location:<context.location>
        - inject dPrevention_initial_block_check
        ##block-fades
        on block fades in:world_flagged:dPrevention.flags.block-fades priority:100:
        - definemap arguments flag:block-fades location:<context.location>
        - inject dPrevention_initial_block_check
        on block fades in:area_flagged:dPrevention.flags.block-fades priority:50:
        - definemap arguments flag:block-fades location:<context.location>
        - inject dPrevention_initial_block_check
        ##block-growth
        on block grows in:world_flagged:dPrevention.flags.block-growth priority:100:
        - definemap arguments flag:block-growth location:<context.location>
        - inject dPrevention_initial_block_check
        on block grows in:area_flagged:dPrevention.flags.block-growth priority:50:
        - definemap arguments flag:block-growth location:<context.location>
        - inject dPrevention_initial_block_check
        on block spreads type:vine|*mushroom in:world_flagged:dPrevention.flags.block-growth priority:100:
        - definemap arguments flag:block-growth location:<context.source_location>
        - inject dPrevention_initial_block_check
        on block spreads type:vine|*mushroom in:area_flagged:dPrevention.flags.block-growth priority:50:
        - definemap arguments flag:block-growth location:<context.source_location>
        - inject dPrevention_initial_block_check
        ##block-spreads
        on block spreads type:!vine|*mushroom in:world_flagged:dPrevention.flags.block-spreads priority:100:
        - definemap arguments flag:block-spreads location:<context.source_location>
        - inject dPrevention_initial_block_check
        on block spreads type:!vine|*mushroom in:area_flagged:dPrevention.flags.block-spreads priority:50:
        - definemap arguments flag:block-spreads location:<context.source_location>
        - inject dPrevention_initial_block_check
        ##block-ignites
        on block ignites in:world_flagged:dPrevention.flags.block-ignites priority:100:
        - definemap arguments flag:block-ignites location:<context.location>
        - inject dPrevention_initial_block_check
        on block ignites in:area_flagged:dPrevention.flags.block-ignites priority:50:
        - definemap arguments flag:block-ignites location:<context.location>
        - inject dPrevention_initial_block_check
        ##tnt
        on block destroyed by explosion in:world_flagged:dPrevention.flags.tnt priority:100:
        - definemap arguments flag:tnt location:<context.block>
        - inject dPrevention_initial_block_check
        on block destroyed by explosion in:area_flagged:dPrevention.flags.tnt priority:50:
        - definemap arguments flag:tnt location:<context.block>
        - inject dPrevention_initial_block_check
        on entity explodes in:world_flagged:dPrevention.flags.tnt priority:100:
        - definemap arguments flag:tnt location:<context.location>
        - inject dPrevention_initial_block_check
        on entity explodes in:area_flagged:dPrevention.flags.tnt priority:50:
        - definemap arguments flag:tnt location:<context.location>
        - inject dPrevention_initial_block_check
        ##vehicle-break
        on vehicle destroyed in:world_flagged:dPrevention.flags.vehicle-break priority:100:
        - definemap arguments flag:vehicle-break location:<context.vehicle.location>
        - inject dPrevention_initial_block_check
        on vehicle destroyed in:area_flagged:dPrevention.flags.vehicle-break priority:50:
        - definemap arguments flag:vehicle-break location:<context.vehicle.location>
        - inject dPrevention_initial_block_check
        ##vehicle-place
        on block dispenses *minecart|*boat in:world_flagged:dPrevention.flags.vehicle-place priority:100:
        - definemap arguments flag:vehicle-place location:<context.location.add[<context.location.block_facing>]>
        - define area <[arguments.location].proc[dPrevention_get_areas]>
        - if <[area].flag[dPrevention.flags.vehicle-place].contains[<context.item.material.name>].if_null[false]>:
            - determine cancelled
        on block dispenses *minecart|*boat in:area_flagged:dPrevention.flags.vehicle-place priority:50:
        - definemap arguments flag:vehicle-place location:<context.location.add[<context.location.block_facing>]>
        - define area <[arguments.location].proc[dPrevention_get_areas]>
        - if <[area].flag[dPrevention.flags.vehicle-place].contains[<context.item.material.name>].if_null[false]>:
            - determine cancelled
        ##block-change
        on entity changes block in:world_flagged:dPrevention.flags.block-change priority:100:
        - definemap arguments flag:block-change location:<context.location>
        - inject dPrevention_initial_block_check
        on entity changes block in:area_flagged:dPrevention.flags.block-change priority:50:
        - definemap arguments flag:block-change location:<context.location>
        - inject dPrevention_initial_block_check
        ##entity-damage
        on entity damaged in:world_flagged:dPrevention.flags.entity-damage priority:100:
        - definemap arguments flag:entity-damage location:<context.entity.location>
        - inject dPrevention_initial_block_check
        on entity damaged in:area_flagged:dPrevention.flags.entity-damage priority:50:
        - definemap arguments flag:entity-damage location:<context.entity.location>
        - inject dPrevention_initial_block_check
        ##use
        on entity interacts with material in:world_flagged:dPrevention.flags.use priority:100:
        - definemap arguments flag:use location:<context.location>
        - inject dPrevention_initial_block_check
        on entity interacts with material in:area_flagged:dPrevention.flags.use priority:50:
        - definemap arguments flag:use location:<context.location>
        - inject dPrevention_initial_block_check
        ##piston
        on piston extends priority:100:
        - define location <context.location>
        - define blocks <context.blocks.include[<[location].add[<context.direction>]>].include[<[location]>]>
        - inject dPrevention_prevent_piston_grief
        on piston retracts priority:100:
        - define location <context.location>
        - define blocks <context.blocks.include[<[location]>]>
        - inject dPrevention_prevent_piston_grief
        ##lava-spread
        on liquid spreads type:lava in:world_flagged:dPrevention.flags.lava-spread priority:100:
        - definemap arguments flag:lava-spread location:<context.destination>
        - inject dPrevention_initial_block_check
        on liquid spreads type:lava in:area_flagged:dPrevention.flags.lava-spread priority:50:
        - definemap arguments flag:lava-spread location:<context.destination>
        - inject dPrevention_initial_block_check
        ##water-spread
        on liquid spreads type:water in:area_flagged:dPrevention.flags.water-spread priority:50:
        - definemap arguments flag:water-spread location:<context.destination>
        - inject dPrevention_initial_block_check
        on liquid spreads type:water in:world_flagged:dPrevention.flags.water-spread priority:100:
        - definemap arguments flag:water-spread location:<context.destination>
        - inject dPrevention_initial_block_check
        ##entities
        on entity spawns in:world_flagged:dPrevention.flags.entities priority:100:
        - define area <context.location.proc[dPrevention_get_areas]>
        #Add a fallback if the area that is on the first priority doesn't has the flag.
        - if <[area].flag[dPrevention.flags.entities].contains[<context.entity.entity_type>].if_null[false]>:
            - determine cancelled
        on entity spawns in:area_flagged:dPrevention.flags.entities priority:50:
        - define area <context.location.proc[dPrevention_get_areas]>
        #Add a fallback if the area that is on the first priority doesn't has the flag.
        - if <[area].flag[dPrevention.flags.entities].contains[<context.entity.entity_type>].if_null[false]>:
            - determine cancelled
        ##vehicle move
        on vehicle collides with entity in:world_flagged:dPrevention.flags.vehicle-move priority:100:
        - definemap arguments flag:vehicle-move "reason:You can't move this here" location:<context.vehicle.location>
        - if <context.entity.entity_type> == PLAYER:
            - inject dPrevention_initial_check
        - else:
            - inject dPrevention_initial_block_check
        on vehicle collides with entity in:area_flagged:dPrevention.flags.vehicle-move priority:50:
        - definemap arguments flag:vehicle-move "reason:You can't move this here" location:<context.vehicle.location>
        - if <context.entity.entity_type> == PLAYER:
            - inject dPrevention_initial_check
        - else:
            - inject dPrevention_initial_block_check
dPrevention_prevent_vehicle_placing:
    type: task
    debug: false
    script:
    - define area <[arguments.location].proc[dPrevention_get_areas]>
    #Allow players to bypass the flag, if they have the specific permission.
    - if <player.has_permission[dPrevention.bypass.<[arguments.flag]>]>:
        - stop
    #If he is owner of the region on this location, allow it.
    - if <[area].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>:
        - stop
    #If the user can build in this area, allow it.
    - if <[area].flag[dPrevention.permissions.block-place].contains[<player.uuid>].if_null[false]>:
        - stop
    #If the vehicle is blocked, deny it.
    - if <[area].flag[dPrevention.flags.vehicle-place].contains[<context.item.material.name>].if_null[false]>:
        - narrate <[arguments.reason]> format:dPrevention_format
        - determine cancelled
dPrevention_prevent_piston_grief:
    type: task
    debug: false
    script:
    - define area <[location].proc[dPrevention_get_areas]>
    - define modified_areas <[blocks].parse_tag[<[parse_value].proc[dPrevention_get_areas]>].combine.deduplicate>
    #If the piston makes changes in another area, cancel it.
    - if <[modified_areas].size> > 1:
        - determine cancelled
    #If the piston makes changes in another area and is not inside an area cancel it.
    - if <[modified_areas].size> == 1 && <world[<[area]>].exists>:
        - determine cancelled
    #If the area allows pistons, allow it.
    - if <[area].proc[dPrevention_check_flag].context[piston]>:
        - stop
    - determine cancelled
dPrevention_prevent_vehicle_hijacking:
    type: task
    debug: false
    definitions: arguments
    script:
    #If config option 'vehicle-hijacking' is true, the player is allowed to ride it, even if vehicle-ride is active and he's not in the players whitelist.
    - if <server.flag[dPrevention.config.options.vehicle-hijacking]> && <context.entity.owner.exists>:
        - stop
    #If the owner of the entity is the player he's allowed to ride it, even if vehicle-ride is active.
    - if <context.entity.owner.if_null[null]> == <player>:
        - stop
    #If the player is in the owners ride-whitelist, he's allowed to ride it, even if vehicle-ride is active.
    - if <context.entity.owner.flag[dPrevention.ride_whitelist].contains[<player.uuid>].if_null[false]>:
        - stop
    #If vehicle-ride is active:
    - define area <[arguments.location].proc[dPrevention_get_areas]>
    - if <[area].has_flag[dPrevention.flags.vehicle-ride]>:
        #Allow players to bypass the flag, if they have the specific permission. -> Let Admins ride any vehicle.
        - if <player.has_permission[dPrevention.bypass.<[arguments.flag]>]>:
            - stop
        #If the user is whitelisted on the claim and the vehicle does not have an owner allow him.
        - if <[area].proc[dPrevention_check_flag].context[<[arguments.flag]>]> && !<context.entity.owner.exists>:
            - stop
        #Deny it.
        - determine cancelled passively
        - ratelimit <player.uuid>/<[arguments.flag]> 2s
        - narrate <[arguments.reason]> format:dPrevention_format
    #Allow it.
dPrevention_flag_data:
    type: data
    debug: false
    flags:
        iron_pickaxe: block-break
        grass_block: block-place
        lever: use
        campfire: fire-damage
        flint_and_steel: lighter
        fire_charge: block-ignites
        ice: block-fades
        vine: block-growth
        dirt: block-spreads
        tnt: tnt
        tnt_minecart: vehicle-break
        hopper_minecart: vehicle-move
        minecart: vehicle-place
        saddle: vehicle-ride
        iron_sword: pvp
        netherite_sword: entity-damage
        chest: container-access
        sticky_piston: piston
        ender_pearl: teleport-item
        water_bucket: water-spread
        lava_bucket: lava-spread
        cow_spawn_egg: entities
        item_frame: item-frame-rotation
        farmland: block-change
    player_flags:
        - block-break
        - block-place
        - use
        - lighter
        - pvp
        - container-access
        - teleport
        - vehicle-move
        - item-frame-rotation
        - vehicle-ride