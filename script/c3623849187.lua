-- Orbital Repair Drone
-- Continuous Spell
-- Each time an Xyz Material is detached, you gain 100 LP
local s, id = GetID()
function s.initial_effect(c)
  Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)

	-- Activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  -- Detach Xyz Material
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_DETACH_MATERIAL)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(s.addLP)
  c:RegisterEffect(e2)
end

function s.addLP(e, tp, eg, ep, ev, re, r, rp)
  -- If an Xyz monster with materials is sent to GY:
  --  -> the 'eg' group contains only the monster the material was detached from.
  -- Else: it is empty
  if not eg:GetFirst():IsLocation(LOCATION_MZONE) then return end
  Duel.Recover(tp, 100, REASON_EFFECT)
end
