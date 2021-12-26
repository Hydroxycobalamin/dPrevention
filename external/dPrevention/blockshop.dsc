dPrevention_blockshop:
    type: inventory
    debug: false
    inventory: CHEST
    title: BlockShop
    gui: true
    procedural items:
    - define config <script[dPrevention_config].data_key[shop]>
    - foreach <[config.blocks]> as:blocks:
        - define "items:->:<item[dPrevention_item_blocks].with_flag[dPrevention.blocks:<[blocks]>].with_flag[dPrevention.price:<[blocks].mul[<[config.block-price]>]>].with[lore=<&[dptext]>Price: <[blocks].mul[<[config.block-price]>].custom_color[dpkey]>|<&[dptext]>Blocks: <[blocks].custom_color[dpkey]>]>"
    - determine <[items]>
    slots:
        - [] [] [] [] [] [] [] [] []
        - [] [] [] [] [] [] [] [] []
        - [] [] [] [] [] [] [] [] []
dPrevention_item_blocks:
    type: item
    debug: false
    material: grass_block
    display name: <white>Blocks
    mechanisms:
        hides: ENCHANTS
    enchantments:
    - durability:1
dPrevention_blockshop_handler:
    type: world
    debug: false
    events:
        after player left clicks item_flagged:dPrevention in dPrevention_blockshop:
        - define price <context.item.flag[dPrevention.price]>
        - if <player.money.if_null[0]> < <[price]>:
            - narrate "You can't afford this." format:dPrevention_format
            - stop
        - if !<player.inventory.can_fit[dPrevention_item_blocks]>:
            - narrate "You don't have enough space in your inventory." format:dPrevention_format
            - stop
        - money take quantity:<[price]>
        - give "<context.item.with[lore=<&[dptext]>[Rightclick to use]|<element[Blocks: <context.item.flag[dPrevention.blocks]>].color_gradient[from=#009933;to=#00ff55]>]>"
        - narrate "You've got <context.item.flag[dPrevention.blocks].custom_color[dpkey]>" format:dPrevention_format
dPrevention_blockshop_command:
    type: command
    debug: false
    name: blockshop
    usage: /blockshop
    description: Opens the blockshop
    permission: dPrevention.command.blockshop
    script:
    - inventory open destination:dPrevention_blockshop