-- Orbital Solar Power Station
local s, id = GetID()

function s.initial_effect(c)
  -- Xyz ATK/DEF boost
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
  e1:SetCode(EVENT_BE_MATERIAL)
  e1:SetCondition(s.condition)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  --Special Summon
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_HAND)
  e2:SetCountLimit(1, id)
  e2:SetCondition(s.spcon)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)

  -- Destroy 1 target
  local e3 = Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id, 1))
  e3:SetCategory(CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
  e3:SetCondition(s.descon)
  e3:SetTarget(s.destg)
  e3:SetOperation(s.desop)
  c:RegisterEffect(e3)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  return r == REASON_XYZ
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local thisCard = e:GetHandler()
  local xyzCard = thisCard:GetReasonCard()

  local e1 = Effect.CreateEffect(xyzCard)
  e1:SetDescription(aux.Stringid(id, 0))
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetReset(RESET_EVENT + RESETS_STANDARD)
  e1:SetCondition(s.atkcon)
  e1:SetOperation(s.atkop)
  xyzCard:RegisterEffect(e1, true)
end

function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
  return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
  local xyzCard = e:GetHandler()

  if xyzCard:IsRelateToEffect(e) and xyzCard:IsFaceup() then
    local e1 = Effect.CreateEffect(xyzCard)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    xyzCard:RegisterEffect(e1)

    local e2 = e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    xyzCard:RegisterEffect(e2)
  end
end

function s.machine_filter(c)
  return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
  local g = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
  return #g > 0 and g:FilterCount(s.machine_filter, nil) == #g
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

function s.descon(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  return card:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
    and card:IsPreviousLocation(LOCATION_OVERLAY)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then
    return chkc:IsControler(1 - tp) and chkc:IsOnField()
  end
  if chk == 0 then
    return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
  local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
  Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
  local tc = Duel.GetFirstTarget()

  if tc and tc:IsRelateToEffect(e) then
    Duel.Destroy(tc, REASON_EFFECT)
  end
end
