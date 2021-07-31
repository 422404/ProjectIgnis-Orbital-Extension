-- Orbital Experimental Nuclear Reactor
local s, id = GetID()

function s.initial_effect(c)
  -- Special Summon itself
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetCountLimit(1, id)
  e1:SetRange(LOCATION_HAND)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  -- Special Summon Token
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetCountLimit(1)
  e2:SetRange(LOCATION_MZONE)
  e2:SetTarget(s.sptokentg)
  e2:SetOperation(s.sptokenop)
  c:RegisterEffect(e2)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  local g = Duel.GetFieldGroup(tp, LOCATION_SZONE, 0)
  return #g > 0 and g:FilterCount(Card.IsFacedown, nil) ~= 0
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
  local card = e:GetHandler()

  if chk == 0 then
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
      and card:IsCanBeSpecialSummoned(e, 0, tp, false, false)
  end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, card, 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  if card:IsRelateToEffect(e) then
    Duel.SpecialSummon(card, 0, tp, tp, false, false, POS_FACEUP)
  end
end

local token = { 2316607793, 0xf00, TYPES_TOKEN, 0, 0, 11, RACE_MACHINE, ATTRIBUTE_DARK }

function s.sptokentg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
      and Duel.IsPlayerCanSpecialSummonMonster(tp, table.unpack(token))
  end
  Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, 0, 0)
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, 0)
end

function s.sptokenop(e, tp, eg, ep, ev, re, r, rp)
  if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1
        or not Duel.IsPlayerCanSpecialSummonMonster(tp, table.unpack(token)) then
      return
  end
 
  local token = Duel.CreateToken(tp, table.unpack(token))
  Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP)
end
