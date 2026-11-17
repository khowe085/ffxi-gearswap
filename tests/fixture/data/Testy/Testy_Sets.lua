-- A GearSwap user file of the plainest kind, with no hooks, whose sets are found under keys of every kind gs equip
-- reads: names, names with spaces and dots, numbers, and true and false.

function get_sets()
    sets.idle = {head = 'Nyame Helm'}
    sets.nested = {deeper = {deepest = {head = "Bunzi's Hat"}}}
    sets['mid cast'] = {head = 'Kaykaus Mitra +1'}
    sets['Cure III'] = {main = "Bunzi's Rod"}
    sets.dotted = {['Dia II.Acc'] = {ring2 = 'Kishar Ring'}}
    sets.numbered = {[1] = {head = "Bunzi's Hat"}, [2] = {head = 'Kaykaus Mitra +1'}}
    sets.flagged = {[true] = {head = "Bunzi's Hat"}, [false] = {head = 'Kaykaus Mitra +1'}}
    sets.not_a_set = 'text'
end
