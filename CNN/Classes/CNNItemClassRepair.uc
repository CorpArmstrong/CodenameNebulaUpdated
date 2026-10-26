//=============================================================================
// CNNItemClassRepair.
//
// ArmMagdalene names WeaponAssaultRifle and WeaponSnowblind, which the
// engine looks up in DeusEx and does not find, so the check fails and
// nothing is handed over. Each frame the conversation is bound again and the
// classes come back None, so they are put back every frame.
//
// Its own actor because the player gets PlayerTick, never Tick. Like the
// mission script that did this on L2 alone, it is spawned after the player
// and before any ConPlay, so it runs between the two each frame.
// TantalusDenton.PostPostBeginPlay spawns it on every map.
//=============================================================================
class CNNItemClassRepair extends Info;

function Tick(float deltaTime)
{
    local DeusExPlayer player;

    Super.Tick(deltaTime);

    player = DeusExPlayer(Owner);
    if ((player != none) && (player.conPlay != none) && (player.conPlay.con != none))
        RepairItemClasses(player.conPlay.con);
}

function RepairItemClasses(Conversation con)
{
    local ConEvent ev;

    for (ev = con.eventList; ev != none; ev = ev.nextEvent)
    {
        if ((ConEventTransferObject(ev) != none) && (ConEventTransferObject(ev).giveObject == none))
            ConEventTransferObject(ev).giveObject = ResolveItemClass(ConEventTransferObject(ev).objectName);
        else if ((ConEventCheckObject(ev) != none) && (ConEventCheckObject(ev).checkObject == none))
            ConEventCheckObject(ev).checkObject = ResolveItemClass(ConEventCheckObject(ev).objectName);
    }
}

function class<Inventory> ResolveItemClass(string objName)
{
    local string key;

    key = Caps(objName);
    if (key == "WEAPONASSAULTRIFLE")
        return class'WeaponAssaultGun';
    if ((key == "WEAPONSNOWBLIND") || (key == "APOCALYPSEINSIDE.WEAPONSNOWBLIND"))
        return class'WeaponSnowblind';
    return none;
}

defaultproperties
{
    bAlwaysRelevant=True
}
