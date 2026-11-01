//=============================================================================
// CNNItemClassRepair.
//
// ArmMagdalene names WeaponAssaultRifle and WeaponSnowblind. The engine looks
// names up in DeusEx only and binds the conversation again and again: an empty
// name counts as a failed lookup too, and hands nothing over. So on the first
// tick of a map each name becomes one the engine finds, or it logs Failed to
// load hundreds of times per conversation start: WeaponAssaultGun is the real
// class, WeaponFlamethrower stands in for our WeaponSnowblind, put back on the
// event every frame of the conversation. (Nothing else in a conversation
// names the flamethrower.) The conversations come from CNNText.u again after
// a load, hence transient.
//
// Its own actor because the player gets PlayerTick, never Tick. It is spawned
// after the player and before any ConPlay, so it runs between the two each
// frame. TantalusDenton.PostPostBeginPlay spawns it on every map.
//=============================================================================
class CNNItemClassRepair extends Info;

const SnowblindStandIn = "WeaponFlamethrower";

var transient bool bRenamed;

function Tick(float deltaTime)
{
    local DeusExPlayer player;

    Super.Tick(deltaTime);

    if (!bRenamed)
    {
        bRenamed = true;
        RenameItems();
    }

    player = DeusExPlayer(Owner);
    if ((player != none) && (player.conPlay != none) && (player.conPlay.con != none))
        RepairItemClasses(player.conPlay.con);
}

function RenameItems()
{
    local Actor a;
    local ConListItem item;
    local ConEvent ev;

    foreach AllActors(class'Actor', a)
        for (item = ConListItem(a.conListItems); item != none; item = item.next)
            if (item.con != none)
                for (ev = item.con.eventList; ev != none; ev = ev.nextEvent)
                {
                    if (ConEventTransferObject(ev) != none)
                        ConEventTransferObject(ev).objectName = FoundName(ConEventTransferObject(ev).objectName);
                    else if (ConEventCheckObject(ev) != none)
                        ConEventCheckObject(ev).objectName = FoundName(ConEventCheckObject(ev).objectName);
                }
}

function string FoundName(string objName)
{
    local string key;

    key = Caps(objName);
    if (key == "WEAPONASSAULTRIFLE")
        return "WeaponAssaultGun";
    if ((key == "WEAPONSNOWBLIND") || (key == "CNN.WEAPONSNOWBLIND"))
        return SnowblindStandIn;
    return objName;
}

function RepairItemClasses(Conversation con)
{
    local ConEvent ev;

    for (ev = con.eventList; ev != none; ev = ev.nextEvent)
    {
        if ((ConEventTransferObject(ev) != none) && (ConEventTransferObject(ev).objectName == SnowblindStandIn))
            ConEventTransferObject(ev).giveObject = class'WeaponSnowblind';
        else if ((ConEventCheckObject(ev) != none) && (ConEventCheckObject(ev).objectName == SnowblindStandIn))
            ConEventCheckObject(ev).checkObject = class'WeaponSnowblind';
    }
}

defaultproperties
{
    bAlwaysRelevant=True
}
