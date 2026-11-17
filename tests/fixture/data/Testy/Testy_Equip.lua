-- A GearSwap user file of the plainest kind, with no framework under it, that holds the sets the equip tests put on
-- with gs equip. It has no hooks: nothing here reacts to the game.

function get_sets()
    sets.short_names = {ear2 = 'Loquac. Earring', waist = 'Plat. Mog. Belt'}
    sets.log_names = {ear2 = 'Loquacious Earring', waist = 'Platinum Moogle Belt'}
    sets.short_names_lower_case = {ear2 = 'loquac. earring', waist = 'plat. mog. belt'}
    sets.log_names_upper_case = {ear2 = 'LOQUACIOUS EARRING', waist = 'PLATINUM MOOGLE BELT'}

    sets.cure_cape = {back = {name = "Alaunus's Cape", augments = {'MND+20', '"Cure" potency +10%'}}}
    sets.enmity_cape = {back = {name = "Alaunus's Cape", augments = {'MND+20', 'Enmity+10'}}}
    sets.cape_by_name = {back = "Alaunus's Cape"}
    sets.rare_ring_with_other_augments = {ring1 = {name = 'Kishar Ring', augments = {'MND+20'}}}

    sets.helm_from_wardrobe2 = {head = {name = 'Nyame Helm', bag = 'wardrobe2'}}
    sets.helm_from_wardrobe = {head = {name = 'Nyame Helm', bag = 'wardrobe'}}
    sets.helm_by_name = {head = 'Nyame Helm'}

    sets.no_head = {head = empty}
    sets.neck_only = {neck = 'Loricate Torque +1'}

    sets.ears_numbered = {ear1 = 'Etiolation Earring', ear2 = 'Loquac. Earring'}
    sets.ears_named = {left_ear = 'Etiolation Earring', right_ear = 'Loquac. Earring'}
    sets.rings_numbered = {ring1 = 'Defending Ring', ring2 = 'Kishar Ring'}
    sets.rings_named = {left_ring = 'Defending Ring', right_ring = 'Kishar Ring'}
    sets.range_short = {range = "Judge's Bow"}
    sets.range_long = {ranged = "Judge's Bow"}

    sets.base = {head = 'Nyame Helm', body = 'Nyame Mail', neck = 'Loricate Torque +1'}
    sets.overrides = {head = "Bunzi's Hat", waist = 'Plat. Mog. Belt'}
    sets.last_override = {head = 'Kaykaus Mitra +1'}
    sets.combined = set_combine(sets.base, sets.overrides)
    sets.combined_three = set_combine(sets.base, sets.overrides, sets.last_override)

    sets.stikini_twice = {ring1 = 'Stikini Ring +1', ring2 = 'Stikini Ring +1'}

    sets.mitra = {head = 'Kaykaus Mitra +1'}
    sets.naegling = {main = 'Naegling'}
    sets.helm_from_safe = {head = {name = 'Nyame Helm', bag = 'safe'}}

    sets.wardrobe_and_inventory = {head = 'Nyame Helm', body = 'Nyame Mail'}

    sets.prioritized = {
        head = {name = 'Nyame Helm', priority = 5},
        body = {name = 'Nyame Mail', priority = 10},
        hands = 'Nyame Gauntlets',
        legs = {name = 'Nyame Flanchard', priority = -1},
    }
    sets.prioritized_pair = {
        head = {name = 'Nyame Helm', priority = 1},
        feet = {name = 'Nyame Sollerets', priority = 2},
    }
    sets.unprioritized = {head = 'Nyame Helm', body = 'Nyame Mail', hands = 'Nyame Gauntlets'}
end
