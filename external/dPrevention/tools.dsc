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
        - define areas <[location].areas.filter[has_flag[dPrevention]]>
        # If the player is not inside an area, set the player in claim mode.
        - if <[areas].is_empty>:
            - flag <player> dPrevention.claim_mode expire:120s
            - narrate "Claim mode activated" format:dPrevention_format
            - stop
        - define owned_areas <[areas].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
        # If the player is an admin, include admin areas.
        - if <player.has_permission[dPrevention.admin]>:
            - define owned_areas:|:<[areas].filter_tag[<[filter_value].has_flag[dPrevention.owners].not>]>
        # If he isn't owner of any area, he's not allowed.
        - if <[owned_areas].is_empty>:
            - narrate "You're not allowed to do that" format:dPrevention_format
            - stop
        # If there are multiple areas which the player owns, select one.
        - if <[owned_areas].size> > 1:
            - foreach <[owned_areas]> as:area:
                - clickable dPrevention_expand_mode def.cuboid:<[area]> def.location:<[location]> for:<player> until:1m save:<[loop_index]>
                - define clickables:->:<[area].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[area].note_name>]>
            - narrate <[clickables].space_separated.custom_color[emphasis]> format:dPrevention_format
            - stop
        # If there's only a single area, set the player in expand mode.
        - run dPrevention_expand_mode def.cuboid:<[areas].first> def.location:<[location]>
        on player clicks block with:dPrevention_tool flagged:dPrevention.claim_mode priority:-1:
        - determine passively cancelled
        # If the player sneaks while he clicks a block, claim mode will be removed.
        - if <player.is_sneaking>:
            - run dPrevention_cancel_mode def:claim
            - narrate "Claim mode cancelled" format:dPrevention_format
            - stop
        - choose <context.click_type>:
            - case LEFT_CLICK_BLOCK:
                - flag <player> dPrevention.selection:<context.location.with_y[<server.flag[dPrevention.config.claims.depth]>]> expire:<player.flag_expiration[dPrevention.claim_mode]>
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
                # If the player can't afford the region, stop. Else define the costs.
                - define costs <[selection].proc[dPrevention_check_affordability].context[claim]>
                - if !<[costs].is_decimal>:
                    - narrate "You can't afford that." format:dPrevention_format
                    - stop
                - run dPrevention_add_blocks def.type:in_use def.amount:<[costs]>
                # Note the selection.
                - flag <player> dPrevention.areas.count:++
                - define name <player.uuid>_cuboid_<player.flag[dPrevention.areas.count]>
                - note <[selection]> as:<[name]>
                # Link the area to the player and the cuboids world.
                - define cuboid <cuboid[<[name]>]>
                - flag <player> dPrevention.areas.cuboids:->:<[cuboid]>
                - flag <[cuboid].world> dPrevention.areas.cuboids:->:<[cuboid]>
                - narrate "Selection claimed" format:dPrevention_format
                # Make the area to a dPrevention area. Add the player as owner.
                - run dPrevention_area_creation def.area:<[cuboid]> def.owner:<player.uuid>
                # Remove claim mode.
                - run dPrevention_cancel_mode def:claim
                - run dPrevention_show_debugblocks def.locations:<[selection].proc[dPrevention_generate_outline]> def.color:<color[0,100,0,255]>
        on player clicks block with:dPrevention_tool flagged:dPrevention.expand_mode priority:-1:
        - determine passively cancelled
        # If the player sneaks while he clicks a block, expand mode will be cancelled.
        - if <player.is_sneaking>:
            - run dPrevention_cancel_mode def:expand
            - narrate "Expand mode cancelled" format:dPrevention_format
            - stop
        - define location <context.location.if_null[null]>
        - choose <context.click_type>:
            - case LEFT_CLICK_BLOCK:
                - if <player.has_flag[dPrevention.selection]>:
                    - stop
                - if !<[location].has_flag[dPrevention.expandable_corner]>:
                    - narrate "You must select a corner first." format:dPrevention_format
                    - stop
                # Prevent the player from expanding a claim that he doesn't own.
                - if <[location].flag[dPrevention.expandable_corner]> != <player.uuid>:
                    - narrate "You're not allowed to do that." format:dPrevention_format
                    - stop
                - if !<player.flag[dPrevention.expand_mode].proc[dPrevention_is_adminclaim]>:
                    - define min <server.flag[dPrevention.config.claims.depth]>
                - else:
                    - define min <player.flag[dPrevention.expand_mode].min.y>
                - flag <player> dPrevention.selection:<[location].flag[dPrevention.location].with_y[<[min]>]> expire:<player.flag_expiration[dPrevention.expand_mode]>
                - narrate "Selection start set on <[location].flag[dPrevention.location].simple.custom_color[emphasis]>" format:dPrevention_format
            - case RIGHT_CLICK_BLOCK:
                - if !<player.has_flag[dPrevention.selection]>:
                    - narrate "You must select a corner first." format:dPrevention_format
                    - stop
                - define selection <player.flag[dPrevention.selection]>
                - if <[selection].world.name> != <[location].world.name>:
                    - narrate "World's doesnt match. Please don't change worlds while expanding your cuboid." format:dPrevention_format
                    - stop
                # Read data from the cuboid linked to the expand mode for later use(read the red comment below).
                - define cuboid <player.flag[dPrevention.expand_mode]>
                ##
                # Saving flags of the current cuboid for later use.
                - foreach <server.flag[dPrevention.config.scripters.flags]> as:flag:
                    - if !<[cuboid].has_flag[<[flag]>]>:
                        - foreach next
                    - define data.<[flag]>:<[cuboid].flag[<[flag]>]>
                ##
                - define name <[cuboid].note_name>
                - if !<[cuboid].proc[dPrevention_is_adminclaim]>:
                    - define selection <[selection].to_cuboid[<[location].with_y[<[location].world.max_height>]>]>
                - else:
                    - define selection <[selection].to_cuboid[<[location]>]>
                - inject dPrevention_check_intersections
                - if !<[cuboid].proc[dPrevention_is_adminclaim]>:
                    # If the player can't afford the region, stop. Else define the costs.
                    - define costs <[selection].proc[dPrevention_check_affordability].context[expand|<[cuboid]>]>
                    - if !<[costs].is_decimal>:
                        - narrate "You can't afford that." format:dPrevention_format
                        - stop
                    - else:
                        # Check if the cuboid is smaller or larger, to take or give him blocks back.
                        - if <[costs]> < 0:
                            - run dPrevention_take_blocks def.type:in_use def.amount:<[costs].mul[-1]>
                        - else:
                            - run dPrevention_add_blocks def.type:in_use def.amount:<[costs]>
                # Note the selection.
                ##- note <[selection]> as:<[name]>
                - adjust <[cuboid]> set_member:<[selection]>
                - define new_cuboid <cuboid[<[name]>]>
                # Pass flags to the new cuboid.
                ##
                - foreach <[data]> key:name as:value:
                    - flag <[new_cuboid]> <[name]>:<[value]>
                ##
                - define glowstones <[new_cuboid].proc[dPrevention_get_corners].context[<player.location.y>].values>
                - chunkload <[glowstones].parse[chunk]> duration:1t
                - showfake glowstone <[glowstones].parse[highest]> duration:120s
                # Remove expand mode.
                - run dPrevention_cancel_mode def:expand
                - run dPrevention_show_debugblocks def.locations:<[new_cuboid].proc[dPrevention_generate_outline]> def.color:<color[0,100,0,255]>
                - narrate "Your claim was expanded." format:dPrevention_format
        after player drops dPrevention_tool:
        - remove <context.entity>
        after player steps on block flagged:dPrevention.selection:
        - ratelimit <player> 1s
        # If the player expands an admin claim, generate the admin claim. Else, use the worlds max height.
        - define cuboid <player.flag[dPrevention.expand_mode].if_null[null]>
        - if <[cuboid]> != null:
            - if <[cuboid].proc[dPrevention_is_adminclaim]>:
                - define max <player.cursor_on.if_null[<context.location>].with_y[<player.location.y>]>
        - define selection <player.flag[dPrevention.selection].to_cuboid[<[max].if_null[<player.cursor_on.if_null[<context.location>].with_y[<context.location.world.max_height>]>]>]>
        - run dPrevention_show_debugblocks def.locations:<[selection].proc[dPrevention_generate_outline]> def.color:<color[0,100,0,255]>
        - inject dPrevention_check_intersections
timer:
    type: world
    debug: false
    events:
        after delta time secondly every:2:
        - if <server.online_players_flagged[dPrevention.claim_mode].any>:
            - actionbar "<gold>Mode: <yellow>Claim" targets:<server.online_players_flagged[dPrevention.claim_mode]>
        - if <server.online_players_flagged[dPrevention.expand_mode].any>:
            - actionbar "<gold>Mode: <yellow>Expand" targets:<server.online_players_flagged[dPrevention.expand_mode]>
dPrevention_expand_mode:
    type: task
    debug: false
    definitions: cuboid|location
    script:
    - narrate "Expand mode activated for <[cuboid].flag[dPrevention.name].if_null[<[cuboid].note_name>].custom_color[emphasis]>!" format:dPrevention_format
    - flag <[cuboid]> dPrevention.in_use.<player.uuid> expire:120s
    - flag <player> dPrevention.expand_mode:<[cuboid]> expire:120s
    - run dPrevention_show_debugblocks def.locations:<[cuboid].proc[dPrevention_generate_outline]> def.color:<color[0,100,0,255]>
    # Define the fake_block locations and mark them.
    - define locations <[cuboid].proc[dPrevention_get_corners].context[<[location].y>]>
    - chunkload <[locations].values.parse[chunk]> duration:1t
    - define locations <[locations].parse_value_tag[<[parse_value].highest>]>
    - flag <player> dPrevention.show_fake_locations:<[locations].values>
    - foreach <[locations]> key:direction as:location:
        - showfake glowstone <[location]> duration:120s
        # Flag the location to prevent other players from expanding the claim.
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
    definitions: cuboid|y
    script:
    - define corners <[cuboid].corners>
    - definemap locations:
        north_west: <[corners].get[1].with_y[<[y]>]>
        south_east: <[corners].get[4].with_y[<[y]>]>
        north_east: <[corners].get[2].with_y[<[y]>]>
        south_west: <[corners].get[3].with_y[<[y]>]>
    - determine <[locations]>
dPrevention_cancel_mode:
    type: task
    debug: false
    definitions: mode
    script:
    - if <[mode]> == claim:
        - flag <player> dPrevention.claim_mode:!
        - flag <player> dPrevention.selection:!
        - debugblock clear
    - else:
        - if <player.flag[dPrevention.show_fake_locations].exists>:
            - showfake cancel <player.flag[dPrevention.show_fake_locations]>
        - flag <player.flag[dPrevention.expand_mode]> dPrevention.in_use.<player.uuid>:!
        - flag <player> dPrevention.expand_mode:!
        - flag <player> dPrevention.selection:!
        - flag <player> dPrevention.show_fake_locations:!
        - debugblock clear
dPrevention_show_debugblocks:
    type: task
    debug: false
    definitions: locations|color
    script:
    # Clears debug blocks before applying new ones.
    - debugblock clear
    - debugblock <[locations]> color:<[color]>
dPrevention_generate_outline:
    type: procedure
    debug: false
    definitions: selection
    script:
    # Get the lowest 4 corners of the selection.
    - define corners <[selection].proc[dPrevention_get_corners].context[<[selection].min.y>]>
    # Generate edges as cuboids from the corners to return the edges of the selection.
    - define edges <[corners].values.parse_tag[<[parse_value].to_cuboid[<[parse_value].with_y[<[selection].max.y>]>].blocks>]>
    # Generate a list of numbers for calculations.
    - define numbers <util.list_numbers[to=<[edges].first.size>;every=6]>
    # Get only specific locations from the edges for client-performance reasons.
    - define outline <[edges].parse_tag[<[parse_value].get[<[numbers]>]>].combine>
    # Create corners on a specific y level.
    - define created_corner <[selection].proc[dPrevention_create_corner].context[<[selection].min>]>
    - foreach <player.location.y>|<[selection].max.y> as:y:
        - define outline:|:<[created_corner].proc[dPrevention_copy_corner].context[<[y]>]>
    # Return the outline.
    - determine <[outline].include[<[created_corner]>]>
dPrevention_copy_corner:
    type: procedure
    debug: false
    definitions: corners|y
    script:
    # Copies corners over to another y level.
    - determine <[corners].parse[with_y[<[y]>]]>
dPrevention_create_corner:
    type: procedure
    debug: false
    definitions: selection|location
    script:
    - define size <[selection].size>
    # If the cuboid is small enough, just use the whole 2d outline.
    - if <[size].x> <= 10 && <[size].z> <= 10:
        - determine <[selection].outline_2d[<[location].y>]>
    # Define x and z, to prevent overlapping if the cuboid is on one side > 10.
    - define x <[size].x.is_less_than[10].if_true[<[size].x.div[2]>].if_false[4]>
    - define z <[size].z.is_less_than[10].if_true[<[size].z.div[2]>].if_false[4]>
    # Get the 4 corners of the cuboid.
    - define corners <[selection].proc[dPrevention_get_corners].context[<[location].y>]>
    # Generate corners.
    - foreach <[corners]> key:direction as:location:
        - choose <[direction]>:
            - case north_west:
                - define corner:|:<[location].add[0,0,<[z]>].points_between[<[location]>].include[<[location].add[<[x]>,0,0].points_between[<[location]>]>]>
            - case south_east:
                - define corner:|:<[location].sub[0,0,<[z]>].points_between[<[location]>].include[<[location].sub[<[x]>,0,0].points_between[<[location]>]>]>
            - case north_east:
                - define corner:|:<[location].add[0,0,<[z]>].points_between[<[location]>].include[<[location].sub[<[x]>,0,0].points_between[<[location]>]>]>
            - case south_west:
                - define corner:|:<[location].sub[0,0,<[z]>].points_between[<[location]>].include[<[location].add[<[x]>,0,0].points_between[<[location]>]>]>
    - determine <[corner]>
dPrevention_is_adminclaim:
    type: procedure
    debug: false
    definitions: area
    script:
    - if <[area].has_flag[dPrevention.owners]>:
        - determine false
    - determine true