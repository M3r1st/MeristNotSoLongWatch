class X2Effect_ShowLongWatch extends X2Effect_Persistent;

var bool bRequireDisabled;

function bool IsEffectCurrentlyRelevant(XComGameState_Effect EffectGameState, XComGameState_Unit TargetUnit)
{
    if (class'X2Ability_NotSoLongWatch'.static.IsLongWatchEnabled(TargetUnit) == bRequireDisabled)
    {
        return false;
    }

    return true;
}