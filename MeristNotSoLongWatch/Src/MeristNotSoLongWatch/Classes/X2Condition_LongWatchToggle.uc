class X2Condition_LongWatchToggle extends X2Condition;

var bool bRequireDisabled;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    local XComGameState_Unit UnitState;

    UnitState = XComGameState_Unit(kTarget);
    if (UnitState != none)
    {
        if (class'X2Ability_NotSoLongWatch'.static.IsLongWatchEnabled(UnitState) == bRequireDisabled)
        {
            return 'AA_ValueCheckFailed';
        }
    }

    return 'AA_Success';
}

static function X2Condition_LongWatchToggle LongWatchEnabledCondition()
{
    local X2Condition_LongWatchToggle Condition;

    Condition = new class'X2Condition_LongWatchToggle';

    return Condition;
}

static function X2Condition_LongWatchToggle LongWatchDisabledCondition()
{
    local X2Condition_LongWatchToggle Condition;

    Condition = new class'X2Condition_LongWatchToggle';
    Condition.bRequireDisabled = true;

    return Condition;
}

defaultproperties
{
    bRequireDisabled = false
}