dPrevention_check_dclaim:
    type: task
    debug: false
    definitions: area
    script:
    - narrate "This area is not a dPrevention claim yet. Do you want to convert it to an admin claim? You wont loose any data applied on it due conversion." format:dPrevention_format
    - clickable dPrevention_convert_dclaim def.area:<[area]> usages:1 for:<player> until:30s save:yes
    - narrate <element[Yes].custom_color[emphasis].on_click[<entry[yes].command>].on_hover[Yes]> format:dPrevention_format
dPrevention_convert_dclaim:
    type: task
    debug: false
    definitions: area
    script:
    #Get the name of the flag path.
    - if <cuboid[<[area]>].exists>:
        - define type cuboids
    - else if <polygon[<[area]>].exists>:
        - define type polygons
    - else:
        - define type ellipsoids
    #If the area is already a dPrevention claim, stop.
    - if <[area].world.flag[dPrevention.areas.admin.<[type]>].contains[<[area]>].if_null[false]>:
        - narrate "<[area].note_name.custom_color[emphasis]> is already an admin claim." format:dPrevention_format
        - stop
    #Convert the area.
    - flag <[area].world> dPrevention.areas.admin.<[type]>:->:<[area]>
    - run dPrevention_area_creation def.area:<[area]>
    - narrate "Area <[area].note_name.custom_color[emphasis]> was sucessfully converted to an admin claim." format:dPrevention_format