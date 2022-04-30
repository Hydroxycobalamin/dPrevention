##userhandling below
dPrevention_tool:
    type: item
    debug: false
    material: blaze_rod
    mechanisms:
        hides: ENCHANTS
    display name: <white>dPrevention tool
    lore:
    - <gold>Modes<&co>
    - <&[base]>Right click inside your claim to
    - <&[base]>activate expand mode
    - <&[base]>Right click outside your claim to
    - <&[base]>activate claim mode
    - <gold>Expand<&co>
    - <&[base]>Left click a corner of your claim
    - <&[base]>to start expanding your claim
    - <&[base]>Right click a new location
    - <&[base]>to expand your claim
    - <gold>Claim<&co>
    - <&[base]>Left click to start a selection
    - <&[base]>Right click to end the selection
    - <&[base]>and claim your area
    - <gold>Cancel<&co>
    - <&[base]>Sneak + Rightclick to cancel
dPrevention_tool_handler:
    type: world
    debug: false
    events:
        on player right clicks block with:dPrevention_tool:
        - determine passively cancelled
        - if <player.has_flag[dPrevention.claim_mode]> || <player.has_flag[dPrevention.expand_mode]>:
            - stop
        - define location <player.location>
        - define cuboids <[location].cuboids>
        #If the player is not inside an area, set the player in claim mode.
        - if <[cuboids].is_empty>:
            - flag <player> dPrevention.claim_mode expire:120s
            - narrate "Claim mode activated" format:dPrevention_format
            - stop
        #If he isn't owner of any area, he's not allowed.
        - define owned_areas <[cuboids].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
        - if <[owned_areas].is_empty>:
            - narrate "You're not allowed to do that" format:dPrevention_format
            - stop
        #If there are multiple areas which the player owns, select one.
        - if <[owned_areas].size> > 1:
            - foreach <[owned_areas]> as:cuboid:
                - clickable dPrevention_expand_mode def:<list_single[<[cuboid]>].include[<[location]>]> for:<player> until:1m save:<[loop_index]>
                - define clickables:->:<[cuboid].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[cuboid].note_name>]>
            - narrate <[clickables].space_separated.custom_color[emphasis]> format:dPrevention_format
            - stop
        #If there's only a single area, set the player in expand mode.
        - run dPrevention_expand_mode def:<list_single[<[owned_areas].first>].include[<[location]>]>
        on player clicks block with:dPrevention_tool flagged:dPrevention.claim_mode priority:-1:
        - determine passively cancelled
        #If the player sneaks while he clicks a block, claim mode will be removed.
        - if <player.is_sneaking>:
            - run dPrevention_cancel_mode def:claim
            - narrate "Claim mode cancelled" format:dPrevention_format
            - stop
        - choose <context.click_type>:
            - case LEFT_CLICK_BLOCK:
                - flag <player> dPrevention.selection:<context.location.with_y[<server.flag[dPrevention.config.claims.depth]>]>
                - narrate "Selection start set on <context.location.simple.custom_color[emphasis]>" format:dPrevention_format
            - case RIGHT_CLICK_BLOCK:
                - if !<player.has_flag[dPrevention.selection]>:
                    - narrate "You must start your selection by left clicking first." format:dPrevention_format
                    - stop
                - if <player.flag[dPrevention.selection].world.name> != <context.location.world.name>:
                    - narrate "Worlds doesn't match. Please restart your selection by left clicking." format:dPrevention_format
                    - stop
                - define selection <player.flag[dPrevention.selection].to_cuboid[<context.location.with_y[<context.location.world.max_height>]>]>
                - if !<server.flag[dPrevention.config.claims.worlds].contains[<[selection].world.name>]>:
                    - narrate "You can't create a claim in this world." format:dPrevention_format
                    - run dPrevention_cancel_mode def:claim
                    - stop
                - inject dPrevention_check_intersections
                #If the player can't afford the region, stop. Else define the costs.
                - ~run dPrevention_check_affordability def:<list_single[<[selection]>].include[claim]> save:queue
                - if <entry[queue].created_queue.has_flag[stop]>:
                    - narrate "You can't afford that." format:dPrevention_format
                    - stop
                - else:
                    - define costs <entry[queue].created_queue.determination.first>
                - run dPrevention_add_blocks def.type:in_use def.amount:<[costs]>
                - flag <player> dPrevention.areas.count:++
                #Note the selection.
                - define name <player.uuid>_cuboid_<player.flag[dPrevention.areas.count]>
                - note <[selection]> as:<[name]>
                #Link the area to the player and the cuboids world.
                - flag <player> dPrevention.areas.cuboids:->:<[name]>
                - flag <cuboid[<[name]>].world> dPrevention.areas.cuboids:->:<[name]>
                - narrate "Selection claimed" format:dPrevention_format
                - playeffect effect:BARRIER at:<[selection].outline.parse[center]> offset:0,0,0 visibility:100 targets:<player>
                #Make the area to a dPrevention area. Add the player as owner.
                - run dPrevention_area_creation def.area:<cuboid[<[name]>]> def.owner:<player.uuid>
                #Remove claim mode.
                - run dPrevention_cancel_mode def:claim
        on player clicks block with:dPrevention_tool flagged:dPrevention.expand_mode priority:-1:
        - determine passively cancelled
        #If the player sneaks while he clicks a block, expand mode will be removed.
        - if <player.is_sneaking>:
            - run dPrevention_cancel_mode def:expand
            - narrate "Expand mode cancelled" format:dPrevention_format
            - stop
        - choose <context.click_type>:
            - case LEFT_CLICK_BLOCK:
                - if !<context.location.has_flag[dPrevention.expandable_corner]>:
                    - narrate "You must select a corner first." format:dPrevention_format
                    - stop
                #Prevent the player from expanding a claim that he doesn't own.
                - if <context.location.flag[dPrevention.expandable_corner]> != <player.uuid>:
                    - narrate "You're not allowed to do that." format:dPrevention_format
                    - stop
                - flag <player> dPrevention.selection:<context.location.flag[dPrevention.location].with_y[<server.flag[dPrevention.config.claims.depth]>]>
                - narrate "Selection start set on <context.location.flag[dPrevention.location].simple.custom_color[emphasis]>" format:dPrevention_format
                - stop
            - case RIGHT_CLICK_BLOCK:
                - if !<player.has_flag[dPrevention.selection]>:
                    - narrate "You must select a corner first." format:dPrevention_format
                    - stop
                - if <player.flag[dPrevention.selection].world.name> != <context.location.world.name>:
                    - narrate "World's doesnt match. Please don't change worlds while expanding your cuboid." format:dPrevention_format
                    - stop
                #Read data from the cuboid linked to the expand mode for later use(read the red comment below).
                - define cuboid <player.flag[dPrevention.expand_mode]>
                ##
                #Saving flags of the current cuboid for later use.
                - foreach <server.flag[dPrevention.config.scripters.flags]> as:flag:
                    - if !<[cuboid].has_flag[<[flag]>]>:
                        - foreach next
                    - define data.<[flag]>:<[cuboid].flag[<[flag]>]>
                ##
                - define name <[cuboid].note_name>
                - define selection <player.flag[dPrevention.selection].to_cuboid[<context.location.with_y[<context.location.world.max_height>]>]>
                - inject dPrevention_check_intersections
                #If the player can't afford the region, stop. Else define the costs.
                - ~run dPrevention_check_affordability def:<list_single[<[selection]>].include[expand].include_single[<[cuboid]>]> save:queue
                - if <entry[queue].created_queue.has_flag[stop]>:
                    - narrate "You can't afford that." format:dPrevention_format
                    - stop
                - else:
                    - define costs <entry[queue].created_queue.determination.first>
                    #Check if the cuboid is smaller or larger, to take or give him blocks back.
                    - if <[costs]> < 0:
                        - run dPrevention_take_blocks def.type:in_use def.amount:<[costs].mul[-1]>
                    - else:
                        - run dPrevention_add_blocks def.type:in_use def.amount:<[costs]>
                #Note the selection.
                - note <[selection]> as:<[name]>
                - define new_cuboid <cuboid[<[name]>]>
                #Pass flags to the new cuboid.
                ##
                - foreach <[data]> key:name as:value:
                    - flag <[new_cuboid]> <[name]>:<[value]>
                ##
                - playeffect effect:BARRIER at:<[new_cuboid].outline.parse[center]> offset:0,0,0 visibility:100 targets:<player>
                - showfake glowstone <[new_cuboid].proc[dPrevention_get_corners].context[<player.location>].values> duration:120s
                #Remove expand mode.
                - run dPrevention_cancel_mode def:expand
                - narrate "Your claim was expanded." format:dPrevention_format
        after player drops dPrevention_tool:
        - remove <context.entity>
        after delta time secondly every:2:
        - if <server.online_players_flagged[dPrevention.claim_mode].any>:
            - actionbar "<gold>Mode: <yellow>Claim" targets:<server.online_players_flagged[dPrevention.claim_mode]>
        - if <server.online_players_flagged[dPrevention.expand_mode].any>:
            - actionbar "<gold>Mode: <yellow>Expand" targets:<server.online_players_flagged[dPrevention.expand_mode]>
        after player steps on block flagged:dPrevention.selection:
        - ratelimit <player> 5s
        - define selection <player.flag[dprevention.selection].to_cuboid[<context.location.with_y[<context.location.world.max_height>]>]>
        - run dPrevention_check_intersections def.selection:<[selection]>
        - playeffect effect:BARRIER at:<[selection].outline.parse[center]> offset:0,0,0 visibility:100 targets:<player>
dPrevention_expand_mode:
    type: task
    debug: false
    definitions: cuboid|location
    script:
    - narrate "Expand mode activated" format:dPrevention_format
    - flag <player> dPrevention.expand_mode:<[cuboid]> expire:120s
    - playeffect effect:BARRIER at:<[cuboid].outline_2d[<[location].y>].parse[center]> offset:0,0,0 visibility:100 targets:<player>
    #Define the fake_block locations and mark them.
    - define locations <[cuboid].proc[dPrevention_get_corners].context[<[location]>]>
    - flag <player> dPrevention.show_fake_locations:<[locations].values>
    - foreach <[locations]> key:direction as:location:
        - showfake glowstone <[location]> duration:120s
        #Flag the location to prevent other players from expanding the claim.
        - flag <[location]> dPrevention.expandable_corner:<player.uuid> duration:120s
        - choose <[direction]>:
            - case north_west:
                - flag <[locations.south_east]> dPrevention.location:<[location]>
            - case south_east:
                - flag <[locations.north_west]> dPrevention.location:<[location]>
            - case south_west:
                - flag <[locations.north_east]> dPrevention.location:<[location]>
            - case north_east:
                - flag <[locations.south_west]> dPrevention.location:<[location]>
dPrevention_get_corners:
    type: procedure
    debug: false
    definitions: cuboid|location
    script:
    - define cuboid_2d <[cuboid].outline_2d[<[location].y>]>
    - definemap l min_x:<[cuboid_2d].lowest[x].x> max_x:<[cuboid_2d].highest[x].x> min_z:<[cuboid_2d].lowest[z].z> max_z:<[cuboid_2d].highest[z].z>
    - definemap locations north_west:<[location].with_x[<[l.min_x]>].with_z[<[l.min_z]>].highest> south_east:<[location].with_x[<[l.max_x]>].with_z[<[l.max_z]>].highest> south_west:<[location].with_x[<[l.min_x]>].with_z[<[l.max_z]>].highest> north_east:<[location].with_x[<[l.max_x]>].with_z[<[l.min_z]>].highest>
    - determine <[locations]>
dPrevention_cancel_mode:
    type: task
    debug: false
    definitions: mode
    script:
    - if <[mode]> == claim:
        - flag <player> dPrevention.claim_mode:!
        - flag <player> dPrevention.selection:!
    - else:
        - if <player.flag[dPrevention.show_fake_locations].exists>:
            - showfake cancel <player.flag[dPrevention.show_fake_locations]>
        - flag <player> dPrevention.expand_mode:!
        - flag <player> dPrevention.selection:!
        - flag <player> dPrevention.show_fake_locations:!