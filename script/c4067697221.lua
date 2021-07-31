-- Orbital Deployment
local s, id = GetID()

function s.initial_effect(c)
  -- Activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  -- Gain 500 LP on each Special Summon
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_RECOVER)
  e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
  e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetRange(LOCATION_FZONE)
  e2:SetCondition(s.condition)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2)

  -- Discard 1 card then search an "Orbital" monster
  local e3 = Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_FZONE)
  e3:SetCountLimit(1)
  e3:SetCost(s.thcost)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)

  -- Add 500 ATK/DEF to all Machine Monsters
  local e4 = Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
  e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetCode(EVENT_TO_GRAVE)
  e4:SetCountLimit(1, id)
  e4:SetOperation(s.atkop)
  c:RegisterEffect(e4)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
  local specialSummoned = eg:GetFirst()
  return specialSummoned:IsControler(tp)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  if card:IsRelateToEffect(e) then
    Duel.Recover(tp, 500, REASON_EFFECT)
  end
end

function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost, tp, LOCATION_HAND, 0, 1, nil)
  end
  Duel.DiscardHand(tp, Card.IsAbleToGraveAsCost, 1, 1, REASON_COST)
end

function s.thfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf00) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
  end
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  if card:IsRelateToEffect(e) then
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)

    if #g > 0 then
      Duel.SendtoHand(g, nil, REASON_EFFECT)
      Duel.ConfirmCards(1 - tp, g)
    end
  end
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  if card:IsRelateToEffect(e) then
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0xf00))
    e1:SetValue(500)
    Duel.RegisterEffect(e1, tp)

    local e2 = e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    Duel.RegisterEffect(e2, tp)
  end
end
