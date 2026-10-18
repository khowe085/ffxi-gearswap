local harness = require('harness')
local testy = require('testy')

-- Testy as a red mage with the idle set on.
local function boot()
    local gs = harness.boot(testy.rdm())
    gs:console('gs c update')
    gs:traffic()
    return gs
end

describe('Sel\'s precast set for a job ability', function()
    local gs
    before_each(function()
        gs = boot()
    end)

    it('is sets.precast.JA[name], on before the ability goes out', function()
        gs:type('/ja "Composure" <me>')
        assert.same({
            {equip = {body = 'Lethargy Sayon +3'}},
            {action = 'Composure', target = 'Testy'},
        }, gs:traffic())
    end)

    it('is none for an ability the gear file has no set for', function()
        gs:type('/ja "Saboteur" <me>')
        assert.same({{action = 'Saboteur', target = 'Testy'}}, gs:traffic())
    end)

    it('gives way to the idle set once the ability is done', function()
        gs:type('/ja "Composure" <me>')
        gs:finish_action()
        assert.same(testy.worn_by(testy.rdm_idle), gs:worn())
    end)
end)
