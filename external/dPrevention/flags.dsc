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
        ##use
        on player right clicks *door|lever|*_button|*_pressure_plate|anvil|*campfire in:world_flagged:dPrevention.flags.use priority:100:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks *door|lever|*_button|*_pressure_plate|anvil|*campfire in:area_flagged:dPrevention.flags.use priority:50:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        ##lighter
        on player right clicks block with:flint_and_steel|fire_charge in:world_flagged:dPrevention.flags.lighter priority:100:
        - definemap arguments flag:lighter "reason:You can't use this item here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks block with:flint_and_steel|fire_charge in:area_flagged:dPrevention.flags.lighter priority:50:
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
        on player right clicks minecart_chest|chest|trapped_chest|*_shulker_box|*furnace|smoker|barrel|brewing_stand in:world_flagged:dPrevention.flags.container-access priority:100:
        - definemap arguments flag:container-access "reason:You can't open that here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks chest|trapped_chest|*_shulker_box|*furnace|smoker|barrel|brewing_stand in:area_flagged:dPrevention.flags.container-access priority:50:
        - definemap arguments flag:container-access "reason:You can't open that here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks minecart_chest in:world_flagged:dPrevention.flags.container-access priority:100:
        - definemap arguments flag:container-access "reason:You can't open that here." location:<context.entity.location>
        - inject dPrevention_initial_check
        on player right clicks minecart_chest in:area_flagged:dPrevention.flags.container-access priority:50:
        - definemap arguments flag:container-access "reason:You can't open that here." location:<context.entity.location>
        - inject dPrevention_initial_check
        ##teleport-item
        on player teleports cause:CHORUS_FRUIT|ENDER_PEARL:
        - definemap arguments flag:teleport-item "reason:You can't teleport in this area." location:<context.destination>
        - inject dPrevention_initial_check
        ##item-frame-rotation
        on player right clicks item_frame in:world_flagged:dPrevention.flags.item-frame-rotation priority:100:
        - definemap arguments flag:item-frame-rotation "reason:You can't turn this here" location:<context.entity.location>
        - inject dPrevention_initial_check
        on player right clicks item_frame in:world_flagged:dPrevention.flags.item-frame-rotation priority:50:
        - definemap arguments flag:item-frame-rotation "reason:You can't turn this here" location:<context.entity.location>
        - inject dPrevention_initial_check
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
        ##block-grows
        on block grows in:world_flagged:dPrevention.flags.block-growth priority:100:
        - definemap arguments flag:block-grows location:<context.location>
        - inject dPrevention_initial_block_check
        on block grows in:area_flagged:dPrevention.flags.block-growth priority:50:
        - definemap arguments flag:block-grows location:<context.location>
        - inject dPrevention_initial_block_check
        on block spreads in:world_flagged:dPrevention.flags.block-growth priority:100:
        - definemap arguments flag:block-grows location:<context.source_location>
        - inject dPrevention_initial_block_check
        on block spreads in:area_flagged:dPrevention.flags.block-growth priority:50:
        - definemap arguments flag:block-grows location:<context.source_location>
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
        ##vehicle-placed
        on vehicle created in:world_flagged:dPrevention.flags.vehicle-place priority:100:
        - definemap arguments flag:vehicle-place location:<context.vehicle.location>
        - inject dPrevention_initial_block_check
        on vehicle created in:area_flagged:dPrevention.flags.vehicle-place priority:50:
        - definemap arguments flag:vehicle-place location:<context.vehicle.location>
        - inject dPrevention_initial_block_check
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
        tnt: tnt
        tnt_minecart: vehicle-break
        minecart: vehicle-place
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
        - item-frame-rotation