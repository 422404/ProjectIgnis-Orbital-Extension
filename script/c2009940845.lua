-- Orbital Repair Drone Swarm
local s, id = GetID()
function s.initial_effect(c)
  -- Activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  -- Recycle monsters as Xyz materials
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_LEAVE_GRAVE)
  e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
  e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CARD_TARGET)
  e2:SetCode(EVENT_PHASE + PHASE_END)
  e2:SetRange(LOCATION_FZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(s.condition)
  e2:SetTarget(s.target)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2)
end

local ORBITAL_REPAIR_SYSTEM_ID = 4067697230

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  return Duel.GetTurnPlayer() == tp
end

function s.mfilter(c)
  return c:IsFaceup() and c:IsCode(ORBITAL_REPAIR_SYSTEM_ID)
end

function s.gfilter(c)
  return c:IsRace(RACE_MACHINE)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then
    return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.mfilter(chkc)
  end

  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.mfilter, tp, LOCATION_MZONE, 0, 1, nil)
      and Duel.GetMatchingGroupCount(s.gfilter, tp, LOCATION_GRAVE, 0, nil) > 0
  end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
  Duel.SelectTarget(tp, s.mfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()
  local tc = Duel.GetFirstTarget()

  if card:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
    local g = Duel.GetMatchingGroup(s.gfilter, tp, LOCATION_GRAVE, 0, nil)

    if #g > 0 then
      Duel.Overlay(tc, g)
    end
  end
end
