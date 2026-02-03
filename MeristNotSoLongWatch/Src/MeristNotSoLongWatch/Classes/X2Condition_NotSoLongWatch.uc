class X2Condition_NotSoLongWatch extends X2Condition;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) 
{
    local XComGameState_Unit SourceUnit;
    local GameRulesCache_VisibilityInfo VisInfo;

    if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(kSource.ObjectID, kTarget.ObjectID, VisInfo))
    {
        // If Squadsight
        if (VisInfo.bClearLOS && !VisInfo.bVisibleGameplay)
        {
            SourceUnit = XComGameState_Unit(kSource);
            if (SourceUnit != none)
            {
                if (!class'X2Ability_NotSoLongWatch'.static.IsLongWatchEnabled(SourceUnit))
                {
                    return 'AA_NotVisible';
                }
            }
        }
    }

    return 'AA_Success';
}