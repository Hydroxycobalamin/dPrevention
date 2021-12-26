dPrevention_config:
    type: data
    debug: false
    claims:
        #Default depth of claims, claimed via dPrevention_tool.
        depth: 0
    user:
        #Max blocks obtainable per time
        max-blocks-per-time: 2000
        #Blocks a user gets, every 5 minutes of online time until max-blocks-per-time is reached.
        blocks-per-5-min: 25
    shop:
        #Price per block
        block-price: 1.5