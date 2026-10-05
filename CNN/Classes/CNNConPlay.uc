//=============================================================================
// CNNConPlay
//
// Not in use: conversations play on DeusEx.ConPlay, since the
// StartConversation override in TantalusDenton is commented out. The item
// class repair below is done by Chapter06L2.RepairItemClasses() instead.
//=============================================================================
class CNNConPlay extends ConPlay;

function class<Inventory> ResolveItemClass(string objName)
{
    local string key;

    key = Caps(objName);

    if (key == "WEAPONASSAULTRIFLE")
        return class'WeaponAssaultGun';

    if ((key == "WEAPONSNOWBLIND") || (key == "APOCALYPSEINSIDE.WEAPONSNOWBLIND"))
        return class'WeaponSnowblind';

    return None;
}

function EEventAction SetupEventCheckObject(ConEventCheckObject event, out String nextLabel)
{
    if (event.checkObject == None)
        event.checkObject = ResolveItemClass(event.objectName);

    return Super.SetupEventCheckObject(event, nextLabel);
}

function EEventAction SetupEventTransferObject(ConEventTransferObject event, out String nextLabel)
{
    if (event.giveObject == None)
        event.giveObject = ResolveItemClass(event.objectName);

    return Super.SetupEventTransferObject(event, nextLabel);
}
