-- Orbital Holographic Decoy
-- Effect Monster
-- If this card is destroyed by battle or effect: Special Summon any number of "Orbital Holographic Decoy" from your Deck or your Hand.
local s, id = GetID()

function s.initial_effect(c)
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_DESTROYED)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
end

function s.filter(c, e, tp)
  return c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  return card:IsLocation(LOCATION_GRAVE)
    and (card:GetReason() & (REASON_BATTLE | REASON_EFFECT)) ~= 0
    and Duel.GetMatchingGroupCount(s.filter, tp, LOCATION_DECK + LOCATION_HAND, 0, nil, e, tp) ~= 0
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 0, tp, LOCATION_DECK + LOCATION_HAND)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local monsterZoneCount = Duel.GetLocationCount(tp, LOCATION_MZONE)
  if monsterZoneCount < 1 then return end
  if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then monsterZoneCount = 1 end

  local g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_DECK + LOCATION_HAND, 0, nil, e, tp)
  if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local selectedCards = g:Select(tp, 1, monsterZoneCount, nil)
    Duel.SpecialSummon(selectedCards, 0, tp, tp, false, false, POS_FACEUP)
  end
end
