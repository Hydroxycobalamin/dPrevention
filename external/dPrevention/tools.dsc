##userhandling below
dPrevention_tool:
    type: item
    material: blaze_rod
    mechanisms:
        hides: ENCHANTS
    display name: dPrevention Tool
    lore:
    - Right click inside your claim to
    - activate expand mode
    - Right click outside your claim to
    - activate claim mode
    - Expand<&co>
    - Left click a corner of your claim
    - to start expanding your claim
    - Right click a new location
    - to expand your claim
    - Claim<&co>
    - Left click to start a selection
    - Right click to end the selection
    - and claim your area
    - Cancel<&co>
    - Sneak + Rightclick to cancel
dPrevention_tool_handler:
    type: world
    debug: false
    events:
        on player right clicks block with:dPrevention_tool:
        - determine passively cancelled
        - if <player.has_flag[dPrevention.claim_mode]> || <player.has_flag[dPrevention.expand_mode]>:
            - stop
        - define location <player.location>
        - define areas <[location].proc[dPrevention_get_areas]>
        - if <[areas].is_empty>:
            - flag <player> dPrevention.claim_mode expire:120s
            - narrate "Activating claim_mode" format:dPrevention_format
            - stop
        - define ownership <[areas].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
        - if <[ownership].is_empty>:
            - narrate "You're not allowed to do that" format:dPrevention_format
            - stop
        - flag <player> dPrevention.expand_mode:<[areas].first> expire:120s
        - narrate "Activating expand_mode" format:dPrevention_format
        #TODO: Check for MultiCuboids(priority)
        - playeffect effect:BARRIER at:<[location].cuboids.first.outline_2d[<[location].y>].parse[center]> offset:0,0,0 visibility:100
        - define cuboid_2d <[location].cuboids.first.outline_2d[<[location].y>]>
        - definemap l min_x:<[cuboid_2d].lowest[x].x> max_x:<[cuboid_2d].highest[x].x> min_z:<[cuboid_2d].lowest[z].z> max_z:<[cuboid_2d].highest[z].z>
        #TODO: fix definemap up, monkey will answer in discord soon
        ##Clean it up icey, i know you can do
      #  - definemap map 1:<context.location.with_x[<[l.min_x]>].with_z[<[l.min_z]>].highest> 2:<context.location.with_x[<[l.max_x]>].with_z[<[l.max_z]>].highest> 3:<context.location.with_x[<[l.min_x]>].with_z[<[l.max_z]>].highest> 4:<context.location.with_x[<[l.max_x]>].with_z[<[l.min_z]>].highest>
        - define locations:|:<location[<[l.min_x]>,<player.location.y>,<[l.min_z]>,<player.world.name>].highest>|<location[<[l.max_x]>,<player.location.y>,<[l.max_z]>,<player.world.name>].highest>|<location[<[l.min_x]>,<player.location.y>,<[l.max_z]>,<player.world.name>].highest>|<location[<[l.max_x]>,<player.location.y>,<[l.min_z]>,<player.world.name>].highest>
        - flag <player> dPrevention.show_fake_locations:<[locations]>
        - foreach <[locations]>:
            - define map <[map].include[<map[<[loop_index]>=<[value]>]>].if_null[<map.include[<[loop_index]>=<[value]>]>]>
        ##workaround for the mention above
        - foreach <[map]> key:number as:location:
            - showfake glowstone <[location]> duration:60s
            - flag <[location]> dPrevention.expandable_corner:<player.uuid>
            - choose <[number]>:
                - case 1:
                    - flag <[map.2]> dPrevention.location:<[location]>
                - case 2:
                    - flag <[map.1]> dPrevention.location:<[location]>
                - case 3:
                    - flag <[map.4]> dPrevention.location:<[location]>
                - case 4:
                    - flag <[map.3]> dPrevention.location:<[location]>
        on player clicks block with:dPrevention_tool flagged:dPrevention.claim_mode priority:-1:
        - determine passively cancelled
        - if <player.is_sneaking>:
            - flag <player> dPrevention.claim_mode:!
            - flag <player> dPrevention.selection:!
            - narrate "Claim_Mode Cancelled" format:dPrevention_format
            - stop
        - choose <context.click_type>:
            - case LEFT_CLICK_BLOCK:
                - flag <player> dPrevention.selection:<context.location.with_y[<script[dPrevention_config].data_key[claims.depth]>].to_cuboid[<context.location>]>
                - narrate "Selection start set on <context.location.simple>" format:dPrevention_format
            - case RIGHT_CLICK_BLOCK:
                - if !<player.has_flag[dPrevention.selection]>:
                    - narrate "You must start your selection by left clicking first." format:dPrevention_format
                    - stop
                - if <player.flag[dPrevention.selection].world.name> != <context.location.world.name>:
                    - narrate "Worlds doesn't match. Please restart your selection by left clicking." format:dPrevention_format
                    - stop
                - flag <player> dPrevention.selection:<player.flag[dPrevention.selection].include[<context.location.with_y[255]>]>
                - define selection <player.flag[dPrevention.selection]>
                - inject dPrevention_check_intersections
                #Check if the user can afford this region.
                - ~run dPrevention_check_affordability def:<list_single[<[selection]>].include[claim]> save:queue
                - if <entry[queue].created_queue.has_flag[stop]>:
                    - narrate "You can't afford that." format:dPrevention_format
                    - stop
                - else:
                    - define costs <entry[queue].created_queue.determination.first>
                - flag <player> dPrevention.blocks.amount.in_use:+:<[costs]>
                - flag <player> dPrevention.areas.count:++
                - define name <player.uuid>_cuboid_<player.flag[dPrevention.areas.count]>
                - note <player.flag[dPrevention.selection]> as:<[name]>
                #tracking
                #for use in player commands(checking owned claims)
                - flag <player> dPrevention.areas.cuboids:->:<[name]>
                #for use in intersection checking
                - flag <player.world> dPrevention.areas.cuboids:->:<[name]>
                #
                - narrate "Selection claimed" format:dPrevention_format
                - playeffect effect:BARRIER at:<player.flag[dPrevention.selection].outline.parse[center]> offset:0,0,0 visibility:100
                - run dPrevention_area_creation def:<list.include[<cuboid[<[name]>]>].include[<player.uuid>]>
                - flag <player> dPrevention.selection:!
                - flag <player> dPrevention.claim_mode:!
        on player clicks block with:dPrevention_tool flagged:dPrevention.expand_mode priority:-1:
        - determine passively cancelled
        - if <player.is_sneaking>:
            - flag <player> dPrevention.expand_mode:!
            - flag <player> dPrevention.location:!
            - showfake cancel <player.flag[dPrevention.show_fake_locations]>
            - flag <player> dPrevention.show_fake_locations:!
            - narrate "Expand_mode cancelled" format:dPrevention_format
            - stop
        - choose <context.click_type>:
            - case LEFT_CLICK_BLOCK:
                - if !<context.location.has_flag[dPrevention.expandable_corner]>:
                    - narrate "You must select a corner first." format:dPrevention_format
                    - stop
                - if <context.location.flag[dPrevention.expandable_corner]> != <player.uuid>:
                    - narrate "You're not allowed to do that." format:dPrevention_format
                    - stop
                - flag <player> dPrevention.location:<context.location.flag[dPrevention.location].with_y[0]>
                - narrate "Selection start set on <context.location.flag[dPrevention.location].simple>" format:dPrevention_format
                - stop
            - case RIGHT_CLICK_BLOCK:
                - if !<player.has_flag[dPrevention.location]>:
                    - narrate "You must select a corner first." format:dPrevention_format
                    - stop
                - if <player.flag[dPrevention.location].world.name> != <context.location.world.name>:
                    - narrate "World's doesnt match. Please don't change worlds while expanding your cuboid." format:dPrevention_format
                    - stop
                - define cuboid <player.flag[dPrevention.expand_mode]>
                - define name <[cuboid].note_name>
                - define data <[cuboid].flag[dPrevention]>
                - define selection <player.flag[dPrevention.location].to_cuboid[<context.location.with_y[255]>]>
                ##
                - inject dPrevention_check_intersections
                - ~run dPrevention_check_affordability def:<list_single[<[selection]>].include[expand].include_single[<[cuboid]>]> save:queue
                - if <entry[queue].created_queue.has_flag[stop]>:
                    - narrate "You can't afford that." format:dPrevention_format
                    - stop
                - else:
                    - define costs <entry[queue].created_queue.determination.first>
                    - if <[costs]> < 0:
                        - flag <player> dPrevention.blocks.amount.in_use:-:<[costs]>
                    - else:
                        - flag <player> dPrevention.blocks.amount.in_use:+:<[costs]>
                - note <[selection]> as:<[name]>
                - define new_cuboid <cuboid[<[name]>]>
                - flag <[new_cuboid]> dPrevention:<[data]>
                - playeffect effect:LIGHT at:<[new_cuboid].outline.parse[center]> offset:0,0,0 visibility:90
                - showfake cancel <player.flag[dPrevention.show_fake_locations]>
                - flag <player> dPrevention.show_fake_locations:!
                - flag <player> dPrevention.expand_mode:!
                - flag <player> dPrevention.location:!
        after player drops dPrevention_tool:
        - remove <context.entity>
        on delta time secondly every:2:
        - actionbar "<gold>Mode: <yellow>Claim" targets:<server.online_players_flagged[dPrevention.claim_mode]>
        - actionbar "<gold>Mode: <yellow>Expand" targets:<server.online_players_flagged[dPrevention.expand_mode]>