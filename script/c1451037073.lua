-- Orbital Spy Satellite
local s, id = GetID()

function s.initial_effect(c)
  -- Special Summon itself
  -- On Special Summon
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetRange(LOCATION_HAND)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetCountLimit(1, id)
  e1:SetCondition(s.spcon)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  -- On Normal Summon
  local e2 = e1:Clone()
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2)

  -- Send Field Spell to GY then activate one from Deck
  local e3 = Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_MZONE)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e3:SetCountLimit(1)
  e3:SetTarget(s.target)
  e3:SetOperation(s.operation)
  c:RegisterEffect(e3)
end

function s.spfilter(c, tp)
  return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_MACHINE) and c:IsSetCard(0xf00)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
  return eg:IsExists(s.spfilter, 1, nil, tp)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
  local card = e:GetHandler()

  if chk == 0 then
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
       and card:IsCanBeSpecialSummoned(e, 0, tp, false, false)
  end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, card, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  if card:IsRelateToEffect(e) then
    Duel.SpecialSummon(card, 0, tp, tp, false, false, POS_FACEUP)
  end
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  return Duel.GetLocationCount(tp, LOCATION_FZONE) ~= 0
end

function s.filter(c, tp)
  return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp, true, true)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  local tc = Duel.GetFieldCard(tp, LOCATION_FZONE, 0)

  if chkc then return false end
  if chk == 0 then
    return tc and tc:IsFaceup() and tc:IsAbleToGrave() and tc:IsCanBeEffectTarget(e)
      and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil, tp)
  end
  Duel.SetTargetCard(tc)
  Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, tc, 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local tc = Duel.GetFirstTarget()

  if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc, REASON_EFFECT) ~= 0 and tc:IsLocation(LOCATION_GRAVE) then
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local fc = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil, tp):GetFirst()
    aux.PlayFieldSpell(fc, e, tp, eg, ep, ev, re, r, rp)
  end
end
