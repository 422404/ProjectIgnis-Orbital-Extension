-- Orbital Repair System
local s, id = GetID()

function s.initial_effect(c)
  -- Xyz Summon
  Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_MACHINE), 4, 2, nil, nil, 99)
  c:EnableReviveLimit()

  -- Cannot be destroyed by battle
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e1:SetValue(1)
  c:RegisterEffect(e1)
end
