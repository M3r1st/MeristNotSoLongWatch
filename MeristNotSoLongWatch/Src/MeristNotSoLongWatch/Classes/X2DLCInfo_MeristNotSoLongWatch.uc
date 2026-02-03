class X2DLCInfo_MeristNotSoLongWatch extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
    local X2AbilityTemplateManager AbilityManager;
    local X2AbilityTemplate Template;
    local name AbilityName;

    AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

    if (IsModActive('LongWarOfTheChosen') && class'X2Ability_NotSoLongWatch'.default.bUndoLWOTCChanges)
    {
        UndoLWOTCChanges();
    }

    if (class'X2Ability_NotSoLongWatch'.default.bPatchLongWatch)
    {
        Template = AbilityManager.FindAbilityTemplate('LongWatch');

        if (Template != none)
        {
            Template.AdditionalAbilities.AddItem(class'X2Ability_NotSoLongWatch'.default.PassiveAbilityName);
            Template.AdditionalAbilities.AddItem(class'X2Ability_NotSoLongWatch'.default.ToggleOnAbilityName);
            Template.AdditionalAbilities.AddItem(class'X2Ability_NotSoLongWatch'.default.ToggleOffAbilityName);
        }

        Template = AbilityManager.FindAbilityTemplate('LongWatchShot');

        if (Template != none)
        {
            Template.AbilityTargetConditions.AddItem(new class'X2Condition_NotSoLongWatch');
        }
    }

    foreach class'X2Ability_NotSoLongWatch'.default.OtherAbilitiesToPatch(AbilityName)
    {
        if (AbilityName != 'LongWatch' && AbilityName != 'LongWatchShot')
        {
            Template = AbilityManager.FindAbilityTemplate(AbilityName);
            if (Template != none)
            {
                if (X2AbilityTarget_Self(Template.AbilityTargetStyle) != none)
                {
                    `LOG("ERROR: " $ AbilityName $ ".AbilityTargetStyle is X2AbilityTarget_Self", true, 'NotSoLongWatch');
                    continue;
                }
                if (IsAbilityInputTriggered(Template, true))
                {
                    `LOG("WARNING: " $ AbilityName $ " is only input-activated", true, 'NotSoLongWatch');
                }
                Template.AdditionalAbilities.AddItem(class'X2Ability_NotSoLongWatch'.default.PassiveAbilityName);
                Template.AdditionalAbilities.AddItem(class'X2Ability_NotSoLongWatch'.default.ToggleOnAbilityName);
                Template.AdditionalAbilities.AddItem(class'X2Ability_NotSoLongWatch'.default.ToggleOffAbilityName);
                Template.AbilityTargetConditions.AddItem(new class'X2Condition_NotSoLongWatch');
            }
        }
    }
}

static function UndoLWOTCChanges()
{
    local X2AbilityTemplateManager  AbilityManager;
    local X2AbilityTemplate         Template;
    local int                       Index;

    local X2Effect_SetUnitValue     UnitValueEffect;
    local X2Effect_CoveringFire     CoveringFireEffect;
    local bool                      bFoundCoveringFire;

    local X2Condition_UnitValue     ValueCondition;

    AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

    // Make Long Watch override Sniper Rifle Overwatch
    // Remove additional Covering Fire effect and unit value efffect
    Template = AbilityManager.FindAbilityTemplate('LongWatch');
    if (Template != none)
    {
        Template.OverrideAbilities.AddItem('SniperRifleOverwatch');

        // LWOTC adds a second Covering Fire effect instead of replacing the old one
        bFoundCoveringFire = false;
        for (Index = Template.AbilityTargetEffects.Length - 1; Index >= 0; Index--)
        {
            UnitValueEffect = X2Effect_SetUnitValue(Template.AbilityTargetEffects[Index]);
            CoveringFireEffect = X2Effect_CoveringFire(Template.AbilityTargetEffects[Index]);
            if (!bFoundCoveringFire && CoveringFireEffect != none)
            {
                if (CoveringFireEffect.AbilityToActivate == 'LongWatchShot')
                {
                    bFoundCoveringFire = true;
                    Template.AbilityTargetEffects.Remove(Index, 1);
                }
            }
            if (UnitValueEffect != none)
            {
                if (UnitValueEffect.UnitName == 'LWLongWatchActivated')
                {
                    Template.AbilityTargetEffects.Remove(Index, 1);
                }
            }
        }
    }

    // Make Long Watch shot override standard Overwatch shot
    // Remove unit value condition
    Template = AbilityManager.FindAbilityTemplate('LongWatchShot');
    if (Template != none)
    {
        Template.OverrideAbilities.AddItem('OverwatchShot');

        for (Index = Template.AbilityShooterConditions.Length - 1; Index >= 0; Index--)
        {
            ValueCondition = X2Condition_UnitValue(Template.AbilityShooterConditions[Index]);
            if (ValueCondition != none)
            {
                if (ValueCondition.m_aCheckValues.Find('UnitValue', 'LWLongWatchActivated') != INDEX_NONE)
                {
                    Template.AbilityShooterConditions.Remove(Index, 1);
                    break;
                }
            }
        }
    }

    // Remove unit value condition
    Template = AbilityManager.FindAbilityTemplate('OverwatchShot');

    if (Template != none)
    {
        for (Index = Template.AbilityShooterConditions.Length - 1; Index >= 0; Index--)
        {
            ValueCondition = X2Condition_UnitValue(Template.AbilityShooterConditions[Index]);
            if (ValueCondition != none)
            {
                if (ValueCondition.m_aCheckValues.Find('UnitValue', 'LWLongWatchActivated') != INDEX_NONE)
                {
                    Template.AbilityShooterConditions.Remove(Index, 1);
                    break;
                }
            }
        }
    }
}

static private function bool IsAbilityInputTriggered(X2AbilityTemplate Template, optional bool bOnlyInputTriggered)
{
    local int Index;
    local bool bInputTriggered;

    bInputTriggered = false;
    if (Template != none)
    {
        for (Index = 0; Index < Template.AbilityTriggers.Length; Index++)
        {
            if (Template.AbilityTriggers[Index].IsA('X2AbilityTrigger_PlayerInput'))
            {
                bInputTriggered = true;
                if (!bOnlyInputTriggered)
                {
                    break;
                }
            }
            else if (bOnlyInputTriggered)
            {
                bInputTriggered = false;
                break;
            }
        }
    }

    return bInputTriggered;
}

static final function bool IsModActive(name ModName)
{
    local XComOnlineEventMgr    EventManager;
    local int                   Index;

    EventManager = `ONLINEEVENTMGR;

    for (Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--) 
    {
        if (EventManager.GetDLCNames(Index) == ModName) 
        {
            return true;
        }
    }
    return false;
}