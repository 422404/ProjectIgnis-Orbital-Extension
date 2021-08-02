-- Orbital Kinetic Bombardment
local s, id = GetID()

function s.initial_effect(c)
  -- Activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_REMOVE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCost(s.cost)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
end

function s.xyzFilter(c, tp)
  return c:IsType(TYPE_XYZ) and c:IsSetCard(0xf00) and c:CheckRemoveOverlayCard(tp, 3, REASON_COST)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.xyzFilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
  end

  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DEATTACHFROM)
  local g = Duel.SelectTarget(tp, s.xyzFilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)

  local xyzCard = g:GetFirst()
  xyzCard:RemoveOverlayCard(tp, 3, 3, REASON_COST)
end

function s.removeFilter(c)
  return c:IsAbleToRemove() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.GetMatchingGroupCount(s.removeFilter, tp, 0, LOCATION_MZONE, nil)
  end

  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
  local g = Duel.SelectTarget(tp, s.removeFilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
  Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()
  local _, tg = Duel.GetOperationInfo(0, CATEGORY_REMOVE)
  local tc = tg:GetFirst()

  if card:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
    Duel.Remove(tc, POS_FACEDOWN, REASON_EFFECT)
  end
end
