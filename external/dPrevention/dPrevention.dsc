#TODO: clean useroutput (narrate / announce / actionbar)
#TODO: dynmap support
dPrevention_config:
    type: data
    claims:
        #Default depth of claims, claimed via dPrevention_tool.
        depth: 0
    user:
        #Max blocks obtainable per time
        max-blocks-per-time: 2000
        #Blocks a user gets, every 5 minutes of online time until max-blocks-per-time is reached.
        blocks-per-5-min: 25
dPrevention_player_flag_handlers:
    type: world
    debug: false
    events:
        #breaks block
        on player breaks block in:world_flagged:dPrevention.flags.block-break priority:100:
        - definemap arguments flag:block-break "reason:You can't break this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player breaks block in:area_flagged:dPrevention.flags.block-break priority:50:
        - definemap arguments flag:block-break "reason:You can't break this block here." location:<context.location>
        - inject dPrevention_initial_check
        #places block
        on player places block in:world_flagged:dPrevention.flags.block-place priority:100:
        - definemap arguments flag:block-place "reason:You can't place this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player places block in:area_flagged:dPrevention.flags.block-place priority:50:
        - definemap arguments flag:block-place "reason:You can't place this block here." location:<context.location>
        - inject dPrevention_initial_check
        #use block
        on player right clicks *_door|lever|*_button|*_pressure_plate in:world_flagged:dPrevention.flags.use priority:100:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks *_door|lever|*_button|*_pressure_plate in:area_flagged:dPrevention.flags.use priority:50:
        - definemap arguments flag:use "reason:You can't use this block here." location:<context.location>
        - inject dPrevention_initial_check
        #use lighter
        on player right clicks block with:flint_and_steel|fire_charge in:world_flagged:dPrevention.flags.lighter priority:100:
        - definemap arguments flag:lighter "reason:You can't use this item here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks block with:flint_and_steel|fire_charge in:area_flagged:dPrevention.flags.lighter priority:50:
        - definemap arguments flag:lighter "reason:You can't use this item here." location:<context.location>
        - inject dPrevention_initial_check
        #pvp
        on player damaged by player in:world_flagged:dPrevention.flags.pvp priority:100:
        - definemap arguments flag:pvp "reason:PvP is disabled in this region." location:<context.entity.location>
        - inject dPrevention_initial_check
        on player damaged by player in:area_flagged:dPrevention.flags.pvp priority:50:
        - definemap arguments flag:pvp "reason:PvP is disabled in this region." location:<context.entity.location>
        - inject dPrevention_initial_check
        #container-access
        on player right clicks *chest|*_shulker_box|*furnace|smoker|barrel|brewing_stand in:world_flagged:dPrevention.flags.container-access priority:100:
        - definemap arguments flag:container-access "reason:You can't open that here." location:<context.location>
        - inject dPrevention_initial_check
        on player right clicks *chest|*_shulker_box|*furnace|smoker|barrel|brewing_stand in:area_flagged:dPrevention.flags.container-access priority:50:
        - definemap arguments flag:container-access "reason:You can't open that here." location:<context.location>
        - inject dPrevention_initial_check
        #teleport_item
        on player teleports cause:CHORUS_FRUIT|ENDER_PEARL:
        - definemap arguments flag:use "reason:You can't teleport in this area." location:<context.destination>
        - inject dPrevention_initial_check
dPrevention_generic_flag_handlers:
    type: world
    debug: false
    events:
        #block burns
        on block burns in:world_flagged:dPrevention.flags.fire-damage priority:100:
        - determine cancelled
        on block burns in:area_flagged:dPrevention.flags.fire-damage priority:50:
        - determine cancelled
        #block fades
        on block fades in:world_flagged:dPrevention.flags.block-fades priority:100:
        - determine cancelled
        on block fades in:area_flagged:dPrevention.flags.block-fades priority:50:
        - determine cancelled
        #block grows
        on block grows in:world_flagged:dPrevention.flags.block-grows priority:100:
        - determine cancelled
        on block grows in:area_flagged:dPrevention.flags.block-grows priority:50:
        - determine cancelled
        #block ignites
        on block ignites in:world_flagged:dPrevention.flags.block-ignition priority:100:
        - determine cancelled
        on block ignites in:area_flagged:dPrevention.flags.block-ignition priority:50:
        - determine cancelled
        #tnt
        on block destroyed by explosion in:world_flagged:dPrevention.flags.tnt priority:100:
        - determine cancelled
        on block destroyed by explosion in:area_flagged:dPrevention.flags.tnt priority:50:
        - determine cancelled
        on primed_tnt explodes in:world_flagged:dPrevention.flags.tnt priority:100:
        - determine cancelled
        on primed_tnt explodes in:area_flagged:dPrevention.flags.tnt priority:50:
        - determine cancelled
        #vehicle destroyed
        on vehicle destroyed in:world_flagged:dPrevention.flags.vehicle-break priority:100:
        - determine cancelled
        on vehicle destroyed in:area_flagged:dPrevention.flags.vehicle-break priority:50:
        - determine cancelled
        #vehicle placed
        on vehicle created in:world_flagged:dPrevention.flags.vehicle-place priority:100:
        - determine cancelled
        on vehicle created in:area_flagged:dPrevention.flags.vehicle-place priority:50:
        - determine cancelled
        #entity changes block
        on entity changes block in:world_flagged:dPrevention.flags.block-change priority:100:
        - determine cancelled
        on entity changes block in:area_flagged:dPrevention.flags.block-change priority:50:
        - determine cancelled
        #entity damage
        on entity damaged in:world_flagged:dPrevention.flags.entity-damage priority:100:
        - determine cancelled
        on entity damaged in:area_flagged:dPrevention.flags.entity-damage priority:50:
        - determine cancelled
        #piston extends
        on piston extends priority:100:
        - define location <context.location>
        - define blocks <context.blocks.include[<[location].add[<context.direction>]>].include[<[location]>]>
        - inject dPrevention_prevent_piston_grief
        on piston retracts priority:100:
        - define location <context.location>
        - define blocks <context.blocks.include[<context.location>]>
        - inject dPrevention_prevent_piston_grief
        #lava spread
        on liquid spreads type:lava in:world_flagged:dPrevention.flags.lava-spread priority:100:
        - determine cancelled
        #water spread
        on liquid spreads type:water in:area_flagged:dPrevention.flags.water-spread priority:100:
        - determine cancelled
        #monster ban
        on monster prespawns in:world_flagged:dPrevention.flags.spawn-monster priority:100:
        - determine cancelled
        on monster prespawns in:area_flagged:dPrevention.flags.spawn-monster priority:50:
        - determine cancelled
        #living ban
        on living prespawns in:world_flagged:dPrevention.flags.spawn-living priority:100:
        - determine cancelled
        on living prespawns in:area_flagged:dPrevention.flags.spawn-living priority:50:
        - determine cancelled
        on entity prespawns in:world_flagged:dPrevention.flags.entities priority:100:
        - if <context.location.world.flag[dPrevention.flags.entities].contains[<context.entity.entity_type>]>:
            - determine cancelled
        on entity prespawns in:area_flagged:dPrevention.flags.entities priority:50:
        - if <context.location.cuboids.first.flag[dPrevention.flags.entities].contains[<context.entity.entity_type>]>:
            - determine cancelled
dPrevention_prevent_piston_grief:
    type: task
    script:
    - define location_areas <[location].proc[dPrevention_get_areas]>
    - define modified_areas <[blocks].parse_tag[<[parse_value].proc[dPrevention_get_areas]>].combine.deduplicate>
    #If the piston makes changes in another area, cancel it.
    - if <[modified_areas].size> > 1:
        - determine cancelled
    #If the piston makes changes in another area and is not inside an area cancel it.
    - if <[modified_areas].size> == 1 && <[location_areas].is_empty>:
        - determine cancelled
    #If the cuboid allows pistons, allow it.
    - ~run dPrevention_check_flag def:<list_single[<[location_areas]>].include[piston].include[<queue>]>
    - if <queue.has_flag[allow]>:
        - stop
dPrevention_flag_data:
    type: data
    flags:
        iron_pickaxe: block-break
        grass_block: block-place
        campfire: fire-damage
        flint_and_steel: lighter
        fire_charge: block-ignition
        ice: block-fades
        vine: block-growth
        tnt: tnt
        tnt_minecart: vehicle-break
        minecart: vehicle-place
        iron_sword: pvp
        netherite_sword: entity-damage
        chest: container-access
        sticky_piston: piston
        ender_pearl: teleport_item
        water_bucket: water-spread
        lava_bucket: lava-spread
        zombie_head: spawn-monster
        leather_horse_armor: spawn-living
        cow_spawn_egg: entities
dPrevention_initial_check:
    type: task
    script:
    #Allow players to bypass the flag, if they have the specific permission.
    - if <player.has_permission[dPrevention.bypass.<[arguments.flag]>]>:
        - stop
    - ~run dPrevention_check_membership def:<[arguments.location]>|<[arguments.flag]> save:queue
    - if <entry[queue].created_queue.has_flag[allow]>:
        - stop
    - determine cancelled passively
    - ratelimit <player> 2s
    - narrate <[arguments.reason]> format:dPrevention_format
dPrevention_check_membership:
    type: task
    debug: false
    definitions: location|flag
    script:
    ##Avoid multifiring of this task by flagging the player, if he's allowed
    #TODO: check of possibility of triggering a event twice per tick
    - if <player.has_flag[dPrevention.allow.<[flag]>]>:
        - flag <queue> allow
        - stop
    #Check if player is inside an Area
    - define areas <[location].proc[dPrevention_get_areas]>
    #If he is not inside an area, check the worlds flags.
    - if <[areas].is_empty>:
        - define areas:->:<player.location.world>
        - inject dPrevention_check_flag
    #If he is inside an area, check for flags first.
    - define flagged_areas <[areas].filter_tag[<[filter_value].has_flag[dPrevention.flags.<[flag]>]>]>
    - ~run dPrevention_check_flag def:<list_single[<[flagged_areas]>].include[<[flag]>|<queue>]>
    - if <queue.has_flag[allow]>:
        - stop
    #If he isn't owner of any region, stop the queue
    - define owned_areas <[areas].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
    - if <[owned_areas].is_empty>:
        - stop
    # else, allow him
    - flag <queue> allow
    ##Flag the player to reduce multifiring if he's inside a claim and the world is also flagged, if no dPrevention.allow flag is applied, events with world_flagged matchers would run too
    - flag <player> dPrevention.allow.<[flag]> expire:1t
dPrevention_check_flag:
    type: task
    debug: true
    definitions: areas|flag|queue
    script:
    - define priority <[areas].sort_by_number[flag[dPrevention.priority]]>
    - foreach <[priority]> as:area:
        #If the user is whitelisted in this area to bypass the flag, allow it.
        - if <[area].flag[dPrevention.permissions.<[flag]>].contains[<player.uuid.if_null[null]>].if_null[false]>:
            - flag <[queue].if_null[<queue>]> allow
            - stop
        #If an area doesn't allow it, stop
        - if <[area].has_flag[dPrevention.flags.<[flag]>]>:
            - stop
    #Allow it.
    - flag <[queue].if_null[<queue>]> allow
dPrevention_flag_GUI_handler:
    type: world
    debug: true
    data:
        chat_input:
        - entities
    events:
        on player chats flagged:dPrevention.add_flag:
        - determine cancelled passively
        - if <context.message.split.first> == cancel:
            - narrate "Adding or removing flags cancelled." format:dPrevention_format
            - flag <player> dPrevention.add_flag:!
            - stop
        - define flag <player.flag[dPrevention.add_flag.flag]>
        - define area <player.flag[dPrevention.flaggui]>
        - choose <[flag]>:
            - case entities:
                - foreach <context.message.split> as:entity:
                    #If an provided entity is not a valid entity, stop.
                    - if <entity[<[entity]>].if_null[null]> == null:
                        - narrate "<[entity].custom_color[dpkey]> is not a valid entity. Try again or Type cancel. 30 Seconds." format:dPrevention_format
                        - flag <player> dPrevention.add_flag.flag:<[flag]> expire:30s
                        - flag <player> dPrevention.add_flag.area:<[area]> expire:30s
                        - stop
                    #If the entity is already in the list, remove it.
                    - if <[area].flag[dPrevention.flags.<[flag]>].if_null[<list>].contains[<[entity]>]>:
                        - flag <[area]> dPrevention.flags.<[flag]>:<-:<[entity]>
                        - foreach next
                    #If the entity is not in the list, add it.
                    - flag <[area]> dPrevention.flags.<[flag]>:->:<[entity]>
                #If the list of entities is empty, remove the flag.
                - if <[area].flag[dPrevention.flags.<[flag]>].is_empty>:
                    - flag <[area]> dPrevention.flags.<[flag]>:!
                    - flag <player> dPrevention.add_flag:!
                    - narrate "This claims doesn't prevent any entity anymore." format:dPrevention_format
                    - stop
                - flag <player> dPrevention.add_flag:!
                - narrate "This claim prevents <[area].flag[dPrevention.flags.<[flag]>].space_separated.to_titlecase.custom_color[dpkey]> from spawning." format:dPrevention_format
        after player left clicks item_flagged:flag in dPrevention_flag_GUI:
        #If a flag needs separate input, stop here.
        - define flag <context.item.flag[flag]>
        - if <script.data_key[data.chat_input].contains[<[flag]>]>:
            - stop
        - define area <player.flag[dPrevention.flaggui]>
        - define value <context.item.flag[value]>
        #If the flag is set to false, display true.
        - if !<[value]>:
            - flag <[area]> dPrevention.flags.<[flag]>:!
            - inventory adjust slot:<context.slot> "lore:<dark_gray>Status<&co> <green>true" destination:<player.open_inventory>
            - inventory flag slot:<context.slot> value:true destination:<player.open_inventory>
        #Else display false.
        - else:
            - flag <[area]> dPrevention.flags.<[flag]>
            - inventory adjust slot:<context.slot> "lore:<dark_gray>Status<&co> <red>false" destination:<player.open_inventory>
            - inventory flag slot:<context.slot> value:false destination:<player.open_inventory>
        after player shift_right clicks item_flagged:flag in dPrevention_flag_GUI:
        #Checks for all users which are whitelisted on this claim to bypass the flag.
        - define flag <context.item.flag[flag]>
        - define users <player.flag[dPrevention.flaggui].flag[dPrevention.permissions.<[flag]>].if_null[<list>].parse[as_player]>
        - if <[users].is_empty>:
            - narrate "The are no players whitelisted for <[flag].custom_color[dpkey]>" format:dPrevention_format
            - inventory close
            - stop
        - narrate <[users].parse[name].space_separated.custom_color[dpkey]> format:dPrevention_format
        - inventory close
        after player shift_left clicks item_flagged:flag in dPrevention_flag_GUI:
        - define flag <context.item.flag[flag]>
        #If a flag needs separate input. Listen to the chat event.
        - if <script.data_key[data.chat_input].contains[<[flag]>]>:
            - flag <player> dPrevention.add_flag.area:<player.flag[dPrevention.flaggui]> expire:30s
            - flag <player> dPrevention.add_flag.flag:<[flag]> expire:30s
            - narrate "Type the strings. Seperate multiple by space. 30 Seconds."
            - stop
        #Listen to the Chat event, to allow specific players to bypass the player related flag.
        - flag <player> dPrevention.add_bypass_user.area:<player.flag[dPrevention.flaggui]> expire:30s
        - flag <player> dPrevention.add_bypass_user.flag:<context.item.flag[flag]> expire:30s
        - narrate "Type the name of the player into the chat, to add or remove him. Write cancel, to cancel it." format:dPrevention_format
        - inventory close
        on player chats flagged:dPrevention.add_bypass_user:
        - determine cancelled passively
        - define message <context.message.split.first>
        - define flag <player.flag[dPrevention.add_bypass_user.flag]>
        - if <[message]> == cancel:
            - flag <player> dPrevention.add_bypass_user:!
            - narrate "Add users to bypass <[flag]> cancelled." format:dPrevention_format
            - stop
        - define player <server.match_offline_player[<[message]>].if_null[null]>
        - if <[player]> == null:
            - narrate "This user doesn't exist." format:dPrevention_format
            - flag <player> dPrevention.add_bypass_user:!
            - stop
        - if <[player].is_in[dPrevention.permissions.<[flag]>]>:
            - flag <player.flag[dPrevention.add_bypass_user.area]> dPrevention.permissions.<[flag]>:<-:<[player].uuid>
            - narrate "<player.name.custom_color[dpkey]> isn't whitelisted to bypass <[flag].custom_color[dpkey]> anymore." format:dPrevention_format
            - flag <player> dPrevention.add_bypass_user:!
            - stop
        - flag <player.flag[dPrevention.add_bypass_user.area]> dPrevention.permissions.<[flag]>:->:<[player].uuid>
        - narrate "<player.name.custom_color[dpkey]> is whitelisted to bypass <[flag].custom_color[dpkey]>" format:dPrevention_format
        - flag <player> dPrevention.add_bypass_user:!
dPrevention_flag_GUI:
    type: inventory
    inventory: CHEST
    title: Flags
    gui: true
    size: 27
dPrevention_fill_flag_GUI:
    type: task
    debug: true
    definitions: area
    script:
    - foreach <script[dPrevention_flag_data].data_key[flags]> key:item as:flag:
        #- announce dPrevention.flags.<[flag]>
        #true is false and false is truely true is the truth
        - if <[area].has_flag[dPrevention.flags.<[flag]>]>:
            - define bool false
            #If the flag has a value, add it to the item.
            - if <[flag].is_in[<script[dPrevention_flag_GUI_handler].data_key[data.chat_input]>]>:
                - define bool <n><[area].flag[dPrevention.flags.<[flag]>].parse_tag[<red><[parse_value]>].separated_by[<n>]>
        - define "items:->:<item[<[item]>].with[display=<[flag].color[gray]>;lore=<dark_gray>Status: <[bool].color[red].if_null[<green>true]>;hides=ALL].with_flag[flag:<[flag]>].with_flag[value:<[bool].if_null[true]>]>"
        - define bool:!
    - flag <player> dPrevention.flaggui:<[area]>
    - inventory open destination:dPrevention_flag_GUI
    - wait 1t
    - inventory set origin:<[items]> destination:<player.open_inventory>
dPrevention_generate_clickables:
    type: task
    definitions: areas
    script:
    - foreach <[areas]> as:area:
        - clickable dPrevention_fill_flag_GUI def:<[area]> for:<player> until:1m save:<[loop_index]>
        - define clickables:->:<[area].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[area].note_name>]>
    - narrate <[clickables].space_separated.custom_color[dpkey]> format:dPrevention_format
dPrevention_area_creation:
    type: task
    data:
        #Map of flags that will be added to the area upon creation.
        flags:
            block-break: true
            block-place: true
        ##If the flag has separate input, use a map with a list of values instead, format:
            #entities:
              #- COW
        #Default priority that will be set on the area upon creation.
        priority: 1
    definitions: area|owner
    script:
    - foreach <script.data_key[data.flags]> key:flag as:value:
        - flag <[area]> dPrevention.flags.<[flag]>:<[value]>
    - flag <[area]> dPrevention.priority:<script.data_key[data.priority]>
    - if <[owner].exists>:
        - flag <[area]> dPrevention.owners:->:<[owner]>
dPrevention_check_intersections:
    type: task
    #This task script is usually injected via inject command.
    definitions: cuboid|selection
    script:
    - define world <player.world>
    - define cuboids <[world].flag[dPrevention.areas.cuboids].if_null[<list>].parse[as_cuboid].exclude[<[cuboid]>]>
    - define ellipsoids <[world].flag[dPrevention.areas.ellipsoids].if_null[<list>].parse[as_ellipsoid.bounding_box]>
    - define polygons <[world].flag[dPrevention.areas.polygons].if_null[<list>].parse[as_polygon.bounding_box]>
    - define intersections <[cuboids].include[<[ellipsoids]>].include[<[polygons]>].filter_tag[<[filter_value].intersects[<[selection]>]>]>
    - define owned_areas <[intersections].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
    - define intersections <[intersections].exclude[<[owned_areas]>]>
    #If the selection intersects another claim which he the player doesn't own, he's not allowed to claim.
    - if !<[intersections].is_empty>:
        - narrate "Your selection intersects <[intersections].size.custom_color[dpkey]> other claims." format:dPrevention_format
        - playeffect effect:BARRIER at:<[intersections].parse[bounding_box.outline].combine> offset:0,0,0 targets:<player>
        - stop
dPrevention_get_areas:
    type: procedure
    definitions: location
    script:
    - determine <[location].cuboids.include[<[location].ellipsoids>].include[<[location].polygons>]>
dPrevention_format:
    type: format
    format: <element[[dPrevention]].color_gradient[from=#00ccff;to=#0066ff]> <&[dptext]><[text]>