-- Orbital Trajectory Correction
local s, id = GetID()

function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_REMOVE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_ATTACK_ANNOUNCE)
  e1:SetCost(s.cost)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  return Duel.GetTurnPlayer() ~= tp
end

function s.filter(c)
  return c:IsAbleToRemoveAsCost()
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND, 0, 1, nil)
  end

  local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_HAND, 0, 1, 1, nil)
  Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()
  local _, tg = Duel.GetOperationInfo(0, CATEGORY_REMOVE)

  if card:IsRelateToEffect(e) and Duel.Remove(tg, POS_FACEDOWN, REASON_COST) > 0 then
    Duel.NegateAttack()
  end
end
