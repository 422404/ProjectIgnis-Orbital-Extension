-- Orbital Defense Drone
-- Effect Monster
-- If this card is attached to an Xyz Monster that is sent to the GY: You can Special Summon this card in Defense Position.
local s, id = GetID()
function s.initial_effect(c)
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_TO_GRAVE)
  e1:SetCountLimit(1, id)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.specialSummonTarget)
  e1:SetOperation(s.specialSummon)
  c:RegisterEffect(e1)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  return not card:IsReason(REASON_COST) and card:IsPreviousLocation(LOCATION_OVERLAY)
end

function s.specialSummonTarget(e, tp, eg, ep, ev, re, r, rp, chk)
  local card = e:GetHandler()

  if chk == 0 then
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
      and card:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
  else
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, card, 1, 0, 0)
  end
end

function s.specialSummon(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  if card:IsRelateToEffect(e) then
    Duel.SpecialSummon(card, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
  end
end
