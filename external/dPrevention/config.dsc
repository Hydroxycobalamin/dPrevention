dPrevention_config:
    type: data
    debug: false
    claims:
        #Default depth of claims, claimed via dPrevention_tool.
        depth: 0
        flags:
        #Key: value structure of flags that will be applied upon creation by default. True means it prevents it. Read the Documentation for more information about possible flags. https://github.com/Hydroxycobalamin/dPrevention/wiki/Documentation(PARTIAL)
            block-break: true
            block-place: true
            tnt: true
            lighter: true
            pvp: true
            piston: true
            container-access: true
            teleport: true
            item-frame-rotation: true
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