-- Orbital Collector Drone
local s, id = GetID()

function s.initial_effect(c)
  -- Shuffle an "Orbital" card in the GY into the Deck when detached from an Xyz Monster
  local e1 = Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id, 0))
  e1:SetCategory(CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_TO_GRAVE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  -- Normal Summon without Tributing
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id, 1))
  e2:SetCategory(CATEGORY_SUMMON)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
  e2:SetCode(EFFECT_SUMMON_PROC)
  e2:SetCondition(s.ntcon)
  e2:SetOperation(s.ntop)
  c:RegisterEffect(e2)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  return card:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
    and card:IsPreviousLocation(LOCATION_OVERLAY)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then
    return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToDeck()
  end

  local filter = aux.FilterBoolFunction(Card.IsAbleToDeck)
  if chk == 0 then
    return Duel.IsExistingTarget(filter, tp, LOCATION_GRAVE, 0, 1, nil)
  end

  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
  local g = Duel.SelectTarget(tp, filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
  Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local tc = Duel.GetFirstTarget()

  if tc:IsRelateToEffect(e) then
    Duel.SendtoDeck(tc, nil, 2, REASON_EFFECT)
  end
end

function s.ntcon(e, c, minc)
  if c == nil then return true end
  return minc == 0 and c:GetLevel() > 4 and Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0
end

function s.ntop(e, tp, eg, ep, ev, re, r, rp, c)
  -- Change Level
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetReset(RESET_PHASE + PHASE_END)
  e1:SetCode(EFFECT_UPDATE_LEVEL)
  e1:SetValue(4 - c:GetLevel())
  c:RegisterEffect(e1)
end
