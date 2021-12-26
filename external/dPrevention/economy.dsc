dPrevention_get_costs:
    type: procedure
    debug: false
    definitions: cuboid
    script:
    - define math <[cuboid].size>
    - define costs <[math].x.mul[<[math].z>]>
    - determine <[costs]>
dPrevention_get_blocks:
    type: procedure
    debug: false
    script:
    - define free_amount <player.flag[dPrevention.blocks.amount.per_time].if_null[0].add[<player.flag[dPrevention.blocks.amount.per_block].if_null[0]>].sub[<player.flag[dPrevention.blocks.amount.in_use].if_null[0]>]>
    - determine <[free_amount]>
dPrevention_check_affordability:
    type: task
    debug: false
    definitions: cuboid|mode|old_cuboid
    script:
    - choose <[mode]>:
        - case claim:
            - define costs <proc[dPrevention_get_costs].context[<[cuboid]>]>
            - if <[costs]> > <proc[dPrevention_get_blocks]>:
                - flag <queue> stop
                - stop
            - determine <[costs]>
        - case expand:
            - define used_blocks <proc[dPrevention_get_costs].context[<[old_cuboid]>]>
            - define current_costs <proc[dPrevention_get_costs].context[<[cuboid]>]>
            - define costs <[current_costs].sub[<[used_blocks]>]>
            - if <[costs]> > <proc[dPrevention_get_blocks]>:
                - flag <queue> stop
                - stop
            - determine <[costs]>
dPrevention_blocks_handler:
    type: world
    debug: false
    reached_max:
    - if <[player].flag[dPrevention.blocks.amount.per_time].add[<[config.blocks-per-5-min]>].if_null[0]> > <[config.max-blocks-per-time]>:
        - flag <[player]> dPrevention.blocks.amount.per_time:<[config.max-blocks-per-time]>
        - flag <[player]> dPrevention.blocks.reached_max
        - stop
    - flag <[player]> dPrevention.blocks.amount.per_time:+:<[config.blocks-per-5-min]>
    events:
        on player right clicks block with:item_flagged:dPrevention.blocks:
        - determine cancelled passively
        - wait 1t
        - take iteminhand
        - narrate "You've received <context.item.flag[dPrevention.blocks].custom_color[emphasis]> blocks." format:dPrevention_format
        - flag <player> dPrevention.blocks.amount.per_block:+:<context.item.flag[dPrevention.blocks]>
        after delta time minutely every:5:
        - define players <server.online_players.filter[has_flag[dPrevention.blocks.reached_max].not]>
        - define config <script[dPrevention_config].data_key[user]>
        - foreach <[players]> as:player:
            #If he's new and doesn't had a checkup yet, give him blocks.
            - if !<[player].has_flag[dPrevention.blocks.last_checkup]>:
                - inject <script> path:reached_max
                - foreach next
            #If his last action is before the last checkup, skip him.
            - if <[player].last_action_time.is_before[<[player].flag[dPrevention.blocks.last_checkup]>]>:
                - foreach next
            #If the last checkup is before current time minus 6 minutes, skip him.
            - if <[player].flag[dPrevention.blocks.last_checkup].is_before[<util.time_now.sub[6m]>]>:
                - foreach next
            - inject <script> path:reached_max
        - flag <[players]> dPrevention.blocks.last_checkup:<util.time_now>
