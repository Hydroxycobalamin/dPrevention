dPrevention_config:
    type: data
    debug: false
    claims:
        #Default depth of claims, claimed via dPrevention_tool.
        depth: 0
        flags:
        #Key: value structure of flags that will be applied upon creation by default. True means it prevents it. Possible flags are:
        # block-break, block-place, use, fire-damage, lighter, block-ignition, block-fades, block-growth, tnt ,vehicle-break, vehicle-place, pvp, entity-damage, container-access, piston,teleport_item, water-spread, lava-spread, spawn-monster, spawn-living, entities.
            block-break: true
            block-place: true
            tnt: true
            lighter: true
            pvp: true
            piston: true
            container-access: true
            teleport: true
        ##If the flag need additional input, use a map with a list of values instead, format:
            #entities:
              #- COW
              #- ZOMBIE
        #Default priority that will be set on the area upon creation.
        priority: 1
    user:
        #Max blocks obtainable per time
        max-blocks-per-time: 2000
        #Blocks a user gets, every 5 minutes of online time until max-blocks-per-time is reached.
        blocks-per-5-min: 25
    shop:
        #Price per block
        block-price: 1.5
        #Packets in which are blocks buyable (You can set up to 27 different packets). Values must be integers.
        blocks:
            - 1
            - 2
            - 10
            - 25
            - 50
            - 100
            - 250
            - 500
            - 1000