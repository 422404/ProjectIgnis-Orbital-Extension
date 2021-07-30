-- Orbital Junk Recycler
local s, id = GetID()

function s.initial_effect(c)
  c:EnableReviveLimit()

  -- Cannot Special Summon
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
  e1:SetCode(EFFECT_SPSUMMON_CONDITION)
  c:RegisterEffect(e1)

  -- Special Summon
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_SPSUMMON_PROC)
  e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e2:SetRange(LOCATION_HAND)
  e2:SetCondition(s.spcon)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)

  -- Xyz material recycling
  local e3 = Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EVENT_BE_MATERIAL)
  e3:SetCondition(s.condition)
  e3:SetOperation(s.operation)
  c:RegisterEffect(e3)
end

function s.ableToDeckFilter(c)
  return not c:IsAbleToDeckOrExtraAsCost()
end

function s.spellAndTrapFilter(c)
  return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsSetCard(0xf00)
end

function s.spcon(e, c)
  if c == nil then return true end

  local tp = c:GetControler()
  local g = Duel.GetMatchingGroup(s.spellAndTrapFilter, tp, LOCATION_GRAVE, 0, nil)

  return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and #g > 0
    and not g:IsExists(s.ableToDeckFilter, 1, nil)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
  local g = Duel.GetMatchingGroup(s.spellAndTrapFilter, tp, LOCATION_GRAVE, 0, nil)
  Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  return r == REASON_XYZ
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local thisCard = e:GetHandler()
  local xyzCard = thisCard:GetReasonCard()

  local e1 = Effect.CreateEffect(xyzCard)
  e1:SetDescription(aux.Stringid(id, 0))
  e1:SetCategory(CATEGORY_TOHAND)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1)
  e1:SetCost(s.thcost)
  e1:SetOperation(s.thop)
  xyzCard:RegisterEffect(e1, false, REGISTER_FLAG_DETACH_XMAT)
end

function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
  local xyzCard = e:GetHandler()

  if chk == 0 then
    return xyzCard:CheckRemoveOverlayCard(tp, 1, REASON_COST)
      and Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil)
  end

  local previousMaterials = xyzCard:GetOverlayGroup():Clone()

  xyzCard:RemoveOverlayCard(tp, 1, 1, REASON_COST)

  local currentMaterials = xyzCard:GetOverlayGroup()
  previousMaterials:Sub(currentMaterials)
  local detachedMaterial = previousMaterials:GetFirst()
  previousMaterials:DeleteGroup()

  Duel.SetOperationInfo(0, CATEGORY_TOHAND, detachedMaterial, 1, 0, 0)
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
  local _, card = Duel.GetOperationInfo(0, CATEGORY_TOHAND)

  Duel.SendtoHand(card, tp, REASON_EFFECT)
end
