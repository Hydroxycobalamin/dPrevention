#TODO: dynmap support
dPrevention_initial_block_check:
    #This task MUST be injected. Provide a map called arguments, with flag:<ElementTag> and location:<LocationTag>
    #It's called by dPrevention_generic_flag_handlers
    type: task
    definitions: arguments
    debug: false
    script:
    - define area <[arguments.location].proc[dPrevention_get_areas]>
    - if <[area].proc[dPrevention_check_flag].context[<[arguments.flag]>]>:
        - stop
    - determine cancelled
dPrevention_initial_check:
    #This task MUST be injected. Provide map called arguments, with flag:<ElementTag> location:<LocationTag> and reason:<ElementTag>
    #It's called by dPrevention_player_flag_handlers
    type: task
    debug: false
    definitions: arguments
    script:
    #Allow players to bypass the flag, if they have the specific permission.
    - if <player.has_permission[dPrevention.bypass.<[arguments.flag]>]>:
        - stop
    - inject dPrevention_check_membership
    - determine cancelled passively
    - ratelimit <player> 2s
    - narrate <[arguments.reason]> format:dPrevention_format
dPrevention_check_membership:
    #This task MUST be injected.
    type: task
    debug: false
    script:
    #TODO: check of possibility of triggering a event twice per tick
    ##Avoid multifiring of this task by flagging the player, if he's allowed
    - if <player.has_flag[dPrevention.allow.<[arguments.flag]>]>:
        - stop
    #Check if player is inside an dPrevention area
    - define area <[arguments.location].proc[dPrevention_get_areas]>
    #Check for flags
    - if <[area].proc[dPrevention_check_flag].context[<[arguments.flag]>]>:
        ##Flag the player to reduce multifiring if he's inside a claim and the world is also flagged, if no dPrevention.allow flag is applied, events with world_flagged matchers would run too
        - flag <player> dPrevention.allow.<[arguments.flag]> expire:1t
        - stop
    #If he is owner of the region on this location, stop the queue
    - if <[area].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>:
        - stop
    #Event cancelled
dPrevention_check_flag:
    type: procedure
    debug: false
    definitions: area|flag
    script:
    #If the user is whitelisted in this area to bypass the flag, allow it.
    - if <[area].flag[dPrevention.permissions.<[flag]>].contains[<player.uuid.if_null[null]>].if_null[false]>:
        - determine true
    #If an area doesn't allow it, stop
    - if <[area].has_flag[dPrevention.flags.<[flag]>]>:
        - determine false
    - else:
        #Allow it
        - determine true
dPrevention_flag_GUI_handler:
    type: world
    debug: false
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
                        - narrate "<[entity].custom_color[emphasis]> is not a valid entity. Try again or Type cancel. 30 Seconds." format:dPrevention_format
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
                - narrate "This claim prevents <[area].flag[dPrevention.flags.<[flag]>].space_separated.to_titlecase.custom_color[emphasis]> from spawning." format:dPrevention_format
        after player left clicks item_flagged:flag in dPrevention_flag_GUI:
        - define flag <context.item.flag[flag]>
        #If the player doesn't have permission to change the flag stop.
        - if !<player.has_permission[dPrevention.flag.<[flag]>]>:
            - narrate "You don't have permission to change the <[flag].custom_color[emphasis]> flag." format:dPrevention_format
            - stop
        #If a flag needs separate input. Listen to the chat event.
        - if <script.data_key[data.chat_input].contains[<[flag]>]>:
            - flag <player> dPrevention.add_flag.area:<player.flag[dPrevention.flaggui]> expire:30s
            - flag <player> dPrevention.add_flag.flag:<[flag]> expire:30s
            - narrate "Type the strings. Seperate multiple by space. 30 Seconds." format:dPrevention_format
            - inventory close
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
            - narrate "The are no players whitelisted for <[flag].custom_color[emphasis]>" format:dPrevention_format
            - inventory close
            - stop
        - narrate <[users].parse[name].space_separated.custom_color[emphasis]> format:dPrevention_format
        - inventory close
        after player shift_left clicks item_flagged:flag in dPrevention_flag_GUI:
        - define flag <context.item.flag[flag]>
        - if !<script[dPrevention_flag_data].data_key[player_flags].contains[<[flag]>]>:
            - narrate "You can't whitelist a player on the flag <[flag].custom_color[emphasis]>!" format:dPrevention_format
            - inventory close
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
            - narrate "<player.name.custom_color[emphasis]> isn't whitelisted to bypass <[flag].custom_color[emphasis]> anymore." format:dPrevention_format
            - flag <player> dPrevention.add_bypass_user:!
            - stop
        - flag <player.flag[dPrevention.add_bypass_user.area]> dPrevention.permissions.<[flag]>:->:<[player].uuid>
        - narrate "<player.name.custom_color[emphasis]> is whitelisted to bypass <[flag].custom_color[emphasis]>" format:dPrevention_format
        - flag <player> dPrevention.add_bypass_user:!
dPrevention_flag_GUI:
    type: inventory
    debug: false
    inventory: CHEST
    title: Flags
    gui: true
    size: 27
dPrevention_fill_flag_GUI:
    type: task
    debug: false
    definitions: area
    script:
    - if !<[area].has_flag[dPrevention]> && !<world[<[area]>].exists>:
        - inject dPrevention_check_dclaim
        - stop
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
    debug: false
    definitions: areas
    script:
    - foreach <[areas]> as:area:
        - clickable dPrevention_fill_flag_GUI def:<[area]> for:<player> until:1m save:<[loop_index]>
        - define clickables:->:<[area].note_name.on_click[<entry[<[loop_index]>].command>].on_hover[<[area].note_name>]>
    - narrate <[clickables].space_separated.custom_color[emphasis]> format:dPrevention_format
dPrevention_area_creation:
    type: task
    debug: false
    definitions: area|owner
    script:
    - define config <script[dPrevention_config].data_key[claims]>
    - foreach <[config.flags]> key:flag as:value:
        - flag <[area]> dPrevention.flags.<[flag]>:<[value]>
    - flag <[area]> dPrevention.priority:<[config.priority]>
    - if <[owner].exists>:
        - flag <[area]> dPrevention.owners:->:<[owner]>
dPrevention_area_removal:
    type: task
    debug: false
    definitions: cuboid|player
    script:
    - flag <[cuboid].world> dPrevention.areas.cuboids:<-:<[cuboid].note_name>
    - flag <[player]> dPrevention.areas.cuboids:<-:<[cuboid].note_name>
    - note remove as:<[cuboid].note_name>
    - flag <[player]> dPrevention.blocks.amount.in_use:-:<[cuboid].proc[dPrevention_get_costs]>
dPrevention_area_admin_removal:
    type: task
    debug: false
    definitions: data
    script:
    - flag <[data.claim].world> dPrevention.areas.admin.<[data.type]>:<-:<[data.claim].note_name>
    - note remove as:<[data.claim].note_name>
dPrevention_check_intersections:
    type: task
    debug: false
    #This task script is usually injected via inject command.
    definitions: cuboid|selection
    script:
    - define world <player.world>
    - define cuboids <[world].flag[dPrevention.areas.cuboids].if_null[<list>].parse[as_cuboid].exclude[<[cuboid].if_null[<empty>]>]>
    - define ellipsoids <[world].flag[dPrevention.areas.ellipsoids].if_null[<list>].parse[as_ellipsoid.bounding_box]>
    - define polygons <[world].flag[dPrevention.areas.polygons].if_null[<list>].parse[as_polygon.bounding_box]>
    - define intersections <[cuboids].include[<[ellipsoids]>].include[<[polygons]>].filter_tag[<[filter_value].intersects[<[selection]>]>]>
    - define owned_areas <[intersections].filter_tag[<[filter_value].flag[dPrevention.owners].contains[<player.uuid>].if_null[false]>]>
    - define intersections <[intersections].exclude[<[owned_areas]>]>
    #If the selection intersects another claim which he the player doesn't own, he's not allowed to claim.
    - if !<[intersections].is_empty>:
        - narrate "Your selection intersects <[intersections].size.custom_color[emphasis]> other claims." format:dPrevention_format
        - playeffect effect:BARRIER at:<[intersections].parse[bounding_box.outline].combine> offset:0,0,0 targets:<player>
        - stop
dPrevention_get_areas:
    type: procedure
    debug: false
    definitions: location
    script:
    - determine <[location].cuboids.include[<[location].ellipsoids>].include[<[location].polygons>].filter[has_flag[dPrevention]].sort_by_number[flag[dPrevention.priority]].first.if_null[<[location].world>]>
dPrevention_format:
    type: format
    debug: false
    format: <element[[dPrevention]].color_gradient[from=#00ccff;to=#0066ff]> <&[base]><[text]>
#dPrevention claim conversion below.
dPrevention_check_dclaim:
    type: task
    debug: false
    definitions: area
    script:
    - narrate "This area is not a dPrevention claim yet. Do you want to convert it to an admin claim? You wont loose any data applied on it due conversion." format:dPrevention_format
    - clickable dPrevention_convert_dclaim def:<list_single[<[area]>]> usages:1 for:<player> until:30s save:yes
    - narrate <element[Yes].custom_color[emphasis].on_click[<entry[yes].command>].on_hover[Yes]> format:dPrevention_format
dPrevention_convert_dclaim:
    type: task
    debug: false
    definitions: area
    script:
    - if <cuboid[<[area]>].exists>:
        - define type cuboids
    - else if <polygon[<[area]>].exists>:
        - define type polygons
    - else <ellipsoid[<[area]>].exists>:
        - define type ellipsoids
    - if <[area].world.flag[dPrevention.areas.admin.<[type]>].contains[<[area].note_name>]>:
        - narrate "<[area].note_name.custom_color[emphasis]> is already an admin claim." format:dPrevention_format
        - stop
    - flag <[area].world> dPrevention.areas.admin.<[type]>:->:<[area].note_name>
    - run dPrevention_area_creation def:<list_single[<[area]>]>
    - narrate "Area <[area].note_name.custom_color[emphasis]> was sucessfully converted to an admin claim." format:dPrevention_format