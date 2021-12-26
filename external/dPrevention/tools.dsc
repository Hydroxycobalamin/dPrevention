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
    - <&[dptext]>Right click inside your claim to
    - <&[dptext]>activate expand mode
    - <&[dptext]>Right click outside your claim to
    - <&[dptext]>activate claim mode
    - <gold>Expand<&co>
    - <&[dptext]>Left click a corner of your claim
    - <&[dptext]>to start expanding your claim
    - <&[dptext]>Right click a new location
    - <&[dptext]>to expand your claim
    - <gold>Claim<&co>
    - <&[dptext]>Left click to start a selection
    - <&[dptext]>Right click to end the selection
    - <&[dptext]>and claim your area
    - <gold>Cancel<&co>
    - <&[dptext]>Sneak + Rightclick to cancel
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
            - narrate <[clickables].space_separated.custom_color[dpkey]> format:dPrevention_format
            - stop
        #If there's only a single area, set the player in expand mode.
        - run dPrevention_expand_mode def:<list_single[<[owned_areas].first>].include[<[location]>]>
        on player clicks block with:dPrevention_tool flagged:dPrevention.claim_mode priority:-1:
        - determine passively cancelled
        #If the player sneaks while he clicks a block, claim mode will be removed.
        - if <player.is_sneaking>:
            - flag <player> dPrevention.claim_mode:!
            - flag <player> dPrevention.selection:!
            - narrate "Claim mode cancelled" format:dPrevention_format
            - stop
        - choose <context.click_type>:
            - case LEFT_CLICK_BLOCK:
                - flag <player> dPrevention.selection:<context.location.with_y[<script[dPrevention_config].data_key[claims.depth]>].to_cuboid[<context.location>]>
                - narrate "Selection start set on <context.location.simple.custom_color[dpkey]>" format:dPrevention_format
            - case RIGHT_CLICK_BLOCK:
                - if !<player.has_flag[dPrevention.selection]>:
                    - narrate "You must start your selection by left clicking first." format:dPrevention_format
                    - stop
                - if <player.flag[dPrevention.selection].world.name> != <context.location.world.name>:
                    - narrate "Worlds doesn't match. Please restart your selection by left clicking." format:dPrevention_format
                    - stop
                - flag <player> dPrevention.selection:<player.flag[dPrevention.selection].include[<context.location.with_y[<context.location.world.max_height>]>]>
                - define selection <player.flag[dPrevention.selection]>
                - inject dPrevention_check_intersections
                #If the player can't afford the region, stop. Else define the costs.
                - ~run dPrevention_check_affordability def:<list_single[<[selection]>].include[claim]> save:queue
                - if <entry[queue].created_queue.has_flag[stop]>:
                    - narrate "You can't afford that." format:dPrevention_format
                    - stop
                - else:
                    - define costs <entry[queue].created_queue.determination.first>
                - flag <player> dPrevention.blocks.amount.in_use:+:<[costs]>
                - flag <player> dPrevention.areas.count:++
                #Note the selection.
                - define name <player.uuid>_cuboid_<player.flag[dPrevention.areas.count]>
                - note <player.flag[dPrevention.selection]> as:<[name]>
                #Link the area to the player and the cuboids world.
                - flag <player> dPrevention.areas.cuboids:->:<[name]>
                - flag <cuboid[<[name]>].world> dPrevention.areas.cuboids:->:<[name]>
                - narrate "Selection claimed" format:dPrevention_format
                - playeffect effect:BARRIER at:<player.flag[dPrevention.selection].outline.parse[center]> offset:0,0,0 visibility:100
                #Make the area to a dPrevention area. Add the player as owner.
                - run dPrevention_area_creation def:<list.include[<cuboid[<[name]>]>].include[<player.uuid>]>
                #Remove claim mode.
                - flag <player> dPrevention.selection:!
                - flag <player> dPrevention.claim_mode:!
        on player clicks block with:dPrevention_tool flagged:dPrevention.expand_mode priority:-1:
        - determine passively cancelled
        #If the player sneaks while he clicks a block, expand mode will be removed.
        - if <player.is_sneaking>:
            - flag <player> dPrevention.expand_mode:!
            - flag <player> dPrevention.location:!
            - showfake cancel <player.flag[dPrevention.show_fake_locations]>
            - flag <player> dPrevention.show_fake_locations:!
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
                - flag <player> dPrevention.location:<context.location.flag[dPrevention.location].with_y[0]>
                - narrate "Selection start set on <context.location.flag[dPrevention.location].simple.custom_color[dpkey]>" format:dPrevention_format
                - stop
            - case RIGHT_CLICK_BLOCK:
                - if !<player.has_flag[dPrevention.location]>:
                    - narrate "You must select a corner first." format:dPrevention_format
                    - stop
                - if <player.flag[dPrevention.location].world.name> != <context.location.world.name>:
                    - narrate "World's doesnt match. Please don't change worlds while expanding your cuboid." format:dPrevention_format
                    - stop
                #Read data from the cuboid linked to the expand mode for later use(read the read comment below).
                - define cuboid <player.flag[dPrevention.expand_mode]>
                - definemap data dPrevention:<[cuboid].flag[dPrevention]>
                - define name <[cuboid].note_name>
                - define selection <player.flag[dPrevention.location].to_cuboid[<context.location.with_y[<context.location.world.max_height>]>]>
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
                        - flag <player> dPrevention.blocks.amount.in_use:-:<[costs]>
                    - else:
                        - flag <player> dPrevention.blocks.amount.in_use:+:<[costs]>
                #Note the selection.
                - note <[selection]> as:<[name]>
                - define new_cuboid <cuboid[<[name]>]>
                #Pass data to the new cuboid.
                ##If you use your own area flags, make sure to pass them aswell. You can add them to the data map defined above.
                - foreach <[data]> key:type as:flags:
                    - flag <[new_cuboid]> <[type]>:<[flags]>
                - playeffect effect:LIGHT at:<[new_cuboid].outline.parse[center]> offset:0,0,0 visibility:90
                #Remove expand mode.
                - showfake cancel <player.flag[dPrevention.show_fake_locations]>
                - flag <player> dPrevention.show_fake_locations:!
                - flag <player> dPrevention.expand_mode:!
                - flag <player> dPrevention.location:!
        after player drops dPrevention_tool:
        - remove <context.entity>
        on delta time secondly every:2:
        - actionbar "<gold>Mode: <yellow>Claim" targets:<server.online_players_flagged[dPrevention.claim_mode]>
        - actionbar "<gold>Mode: <yellow>Expand" targets:<server.online_players_flagged[dPrevention.expand_mode]>
dPrevention_expand_mode:
    type: task
    debug: false
    definitions: cuboid|location
    script:
    - narrate "Expand mode activated" format:dPrevention_format
    - flag <player> dPrevention.expand_mode:<[cuboid]> expire:120s
    - playeffect effect:BARRIER at:<[cuboid].outline_2d[<[location].y>].parse[center]> offset:0,0,0 visibility:100
    #Define the fake_block locations and mark them.
    - define cuboid_2d <[cuboid].outline_2d[<[location].y>]>
    - definemap l min_x:<[cuboid_2d].lowest[x].x> max_x:<[cuboid_2d].highest[x].x> min_z:<[cuboid_2d].lowest[z].z> max_z:<[cuboid_2d].highest[z].z>
    - definemap locations north_west:<[location].with_x[<[l.min_x]>].with_z[<[l.min_z]>].highest> south_east:<[location].with_x[<[l.max_x]>].with_z[<[l.max_z]>].highest> south_west:<[location].with_x[<[l.min_x]>].with_z[<[l.max_z]>].highest> north_east:<[location].with_x[<[l.max_x]>].with_z[<[l.min_z]>].highest>
    - flag <player> dPrevention.show_fake_locations:<[locations].values>
    - foreach <[locations]> key:direction as:location:
        - showfake glowstone <[location]> duration:120s
        #Flag the location other players to expand the claim.
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