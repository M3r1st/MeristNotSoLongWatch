class X2Effect_ToggleLongWatch extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Unit TargetUnit;

    TargetUnit = XComGameState_Unit(kNewTargetState);
    if (TargetUnit != none)
    {
        if (class'X2Ability_NotSoLongWatch'.static.IsLongWatchEnabled(TargetUnit))
        {
            TargetUnit.SetUnitFloatValue(class'X2Ability_NotSoLongWatch'.default.LongWatchValueName, 1, eCleanup_BeginTactical);
        }
        else
        {
            TargetUnit.SetUnitFloatValue(class'X2Ability_NotSoLongWatch'.default.LongWatchValueName, 0, eCleanup_BeginTactical);
        }
    }
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
    local XComGameState_Unit            NewTargetState;
    local XComGameStateContext_Ability  Context;
    local X2AbilityTemplate             AbilityTemplate;
    local string                        FlyoverText;
    local EWidgetColor                  FlyoverColor;
    local X2Action_PlaySoundAndFlyOver  SoundAndFlyOver;

    NewTargetState = XComGameState_Unit(ActionMetadata.StateObject_NewState);

    if (NewTargetState != none)
    {
        Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
        AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

        FlyoverText = AbilityTemplate.LocFlyOverText;
        if (class'X2Ability_NotSoLongWatch'.static.IsLongWatchEnabled(NewTargetState))
        {
            FlyoverColor = class'X2Ability_NotSoLongWatch'.default.ToggleOnFlyOverColor;
        }
        else
        {
            FlyoverColor = class'X2Ability_NotSoLongWatch'.default.ToggleOffFlyOverColor;
        }
        SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
        SoundAndFlyOver.SetSoundAndFlyOverParameters(None, FlyoverText, '', FlyoverColor, AbilityTemplate.IconImage);
    }
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
    AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}