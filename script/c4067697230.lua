-- Orbital Repair System
local s, id = GetID()

function s.initial_effect(c)
  -- Xyz Summon
  Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_MACHINE), 4, 2, nil, nil, 99)
  c:EnableReviveLimit()

  -- Cannot be destroyed by battle
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e1:SetValue(1)
  c:RegisterEffect(e1)

  -- Pass materials around
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(3)
  e2:SetCost(s.cost)
  e2:SetTarget(s.target)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2, false, REGISTER_FLAG_DETACH_XMAT)

  -- Special Summon from GY
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id, 0))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_LEAVE_GRAVE + CATEGORY_RELEASE)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCost(s.spcost)
  e2:SetCondition(s.spcond)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
  local xyzCard = e:GetHandler()

  if chk == 0 then
    return xyzCard:CheckRemoveOverlayCard(tp, 1, REASON_COST)
  end

  local previousMaterials = xyzCard:GetOverlayGroup():Clone()

  xyzCard:RemoveOverlayCard(tp, 1, 1, REASON_COST)

  local currentMaterials = xyzCard:GetOverlayGroup()
  previousMaterials:Sub(currentMaterials)
  local detachedMaterial = previousMaterials:GetFirst()
  previousMaterials:DeleteGroup()

  Duel.SetOperationInfo(0, id, detachedMaterial, 1, 0, 0)
end

function s.filter(c)
  return c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then
    return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsType(TYPE_XYZ) and chkc:IsRace(RACE_MACHINE)
  end

  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil)
  end

  Duel.SelectTarget(tp, s.filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()
  local tc = Duel.GetFirstTarget()

  if card:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
    local _, detachedCard = Duel.GetOperationInfo(0, id)

    Duel.Overlay(tc, detachedCard)
  end
end

function s.spfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE)
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
  local card = e:GetHandler()
	local allMachines = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil)

	if chk == 0 then
    return Duel.CheckReleaseGroupCost(tp, nil, 1, false, nil, nil, allMachines)
      and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
      and card:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP)
  end

	local g = Duel.SelectReleaseGroupCost(tp, nil, 1, 1, false, nil, nil, allMachines)
	Duel.Release(g, REASON_COST)
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, card, 1, 0, 0)
end

function s.spcond(e, tp, eg, ep, ev, re, r, rp)
  return Duel.GetTurnPlayer() == tp
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
  local card = e:GetHandler()

  if card:IsRelateToEffect(e) then
    Duel.SpecialSummon(card, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
  end
end
