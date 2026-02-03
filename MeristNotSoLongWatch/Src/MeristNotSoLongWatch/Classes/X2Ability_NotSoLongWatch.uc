class X2Ability_NotSoLongWatch extends X2Ability config(Game);

var privatewrite name LongWatchValueName;
var privatewrite name PassiveAbilityName;
var privatewrite name ToggleOnAbilityName;
var privatewrite name ToggleOffAbilityName;

var config bool bUndoLWOTCChanges;
var config bool bPatchLongWatch;
var config array<name> OtherAbilitiesToPatch;

var config int ShotHUDPriority;
var config EWidgetColor ToggleOnFlyOverColor;
var config EWidgetColor ToggleOffFlyOverColor;

var localized string strEnabledName;
var localized string strDisabledName;
var localized string strEnabledHelpText;
var localized string strDisabledHelpText;
var config string strEnabledIcon;
var config string strDisabledIcon;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(LongWatchPassive());
    Templates.AddItem(LongWatchToggleOn());
    Templates.AddItem(LongWatchToggleOff());

    return Templates;
}

static function X2AbilityTemplate LongWatchPassive()
{
    local X2AbilityTemplate         Template;
    local X2Effect_ShowLongWatch    PersistentEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, default.PassiveAbilityName);

    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_long_watch";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.bIsPassive = true;
    Template.bUniqueSource = true;

    Template.bCrossClassEligible = false;

    Template.bHideOnClassUnlock = true;
    Template.bDisplayInUITooltip = false;
    Template.bDisplayInUITacticalText = false;
    Template.bDontDisplayInAbilitySummary = true;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    PersistentEffect = new class'X2Effect_ShowLongWatch';
    PersistentEffect.EffectName = name(default.PassiveAbilityName $ "_Enabled");
    PersistentEffect.bRequireDisabled = false;
    PersistentEffect.BuildPersistentEffect(1, true, false);
    PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, default.strEnabledName, default.strEnabledHelpText, default.strEnabledIcon,,, Template.AbilitySourceName);
    Template.AddTargetEffect(PersistentEffect);

    PersistentEffect = new class'X2Effect_ShowLongWatch';
    PersistentEffect.EffectName = name(default.PassiveAbilityName $ "_Disabled");
    PersistentEffect.bRequireDisabled = true;
    PersistentEffect.BuildPersistentEffect(1, true, false);
    PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, default.strDisabledName, default.strDisabledHelpText, default.strDisabledIcon,,, Template.AbilitySourceName);
    Template.AddTargetEffect(PersistentEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate LongWatchToggleOn()
{
    local X2AbilityTemplate     Template;

    `CREATE_X2ABILITY_TEMPLATE(Template, default.ToggleOnAbilityName);

    Template.IconImage = default.strEnabledIcon;
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
    Template.Hostility = eHostility_Neutral;
    Template.DisplayTargetHitChance = false;
    Template.bUniqueSource = true;

    Template.bCrossClassEligible = false;

    Template.bHideOnClassUnlock = true;
    Template.bDisplayInUITooltip = false;
    Template.bDisplayInUITacticalText = false;
    Template.bDontDisplayInAbilitySummary = true;

    Template.ShotHUDPriority = default.ShotHUDPriority;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    Template.AbilityCosts.AddItem(default.FreeActionCost);

    Template.AbilityShooterConditions.AddItem(class'X2Condition_LongWatchToggle'.static.LongWatchDisabledCondition());

    Template.AddTargetEffect(new class'X2Effect_ToggleLongWatch');

    Template.AbilityConfirmSound = "Unreal2DSounds_TargetLock";

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    Template.bSkipFireAction = true;
    Template.bShowActivation = false;

    return Template;
}

static function X2AbilityTemplate LongWatchToggleOff()
{
    local X2AbilityTemplate     Template;

    `CREATE_X2ABILITY_TEMPLATE(Template, default.ToggleOffAbilityName);

    Template.IconImage = default.strDisabledIcon;
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
    Template.Hostility = eHostility_Neutral;
    Template.DisplayTargetHitChance = false;
    Template.bUniqueSource = true;

    Template.bCrossClassEligible = false;

    Template.bHideOnClassUnlock = true;
    Template.bDisplayInUITooltip = false;
    Template.bDisplayInUITacticalText = false;
    Template.bDontDisplayInAbilitySummary = true;

    Template.ShotHUDPriority = default.ShotHUDPriority + 1;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    Template.AbilityCosts.AddItem(default.FreeActionCost);

    Template.AbilityShooterConditions.AddItem(class'X2Condition_LongWatchToggle'.static.LongWatchEnabledCondition());

    Template.AddTargetEffect(new class'X2Effect_ToggleLongWatch');

    Template.AbilityConfirmSound = "Unreal2DSounds_TargetLock";

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    Template.bSkipFireAction = true;
    Template.bShowActivation = false;

    return Template;
}

static function bool IsLongWatchEnabled(XComGameState_Unit TargetUnit)
{
    local UnitValue UnitValue;

    TargetUnit.GetUnitValue(default.LongWatchValueName, UnitValue);

    return int(UnitValue.fValue) == 0;
}

defaultproperties
{
    LongWatchValueName = M31_LongWatch_DisableSquadsight
    PassiveAbilityName = M31_LongWatch_Passive
    ToggleOnAbilityName = M31_LongWatch_ToggleOn
    ToggleOffAbilityName = M31_LongWatch_ToggleOff
}