//=============================================================================
// CNNConPlay
//
// Vanilla ConPlay plus one fix: item classes that a conversation names but
// the engine can't resolve. The native con.BindEvents() looks up each
// CheckObject/TransferObject class as "DeusEx.<objectName>" every time a
// conversation starts, so a CNN class or a misspelled name comes back None
// -- and FindInventoryType(None) / a None giveObject make the event
// silently fail. Setting the class on the loaded conversation at level load
// doesn't help: the bind overwrites it (confirmed 2026-09-24 on
// ArmMagdalene, whose assault-gun and napalm branches never worked).
// So resolve it here, at the moment the event runs, and only when the
// engine left it empty.
//=============================================================================
class CNNConPlay extends ConPlay;

function class<Inventory> ResolveItemClass(string objName)
{
    local string key;

    key = Caps(objName);

    // ArmMagdalene: "Take my assault gun" -- Deus Ex's class is WeaponAssaultGun.
    if (key == "WEAPONASSAULTRIFLE")
        return class'WeaponAssaultGun';

    // ArmMagdalene: napalm launcher -- a CNN class, not DeusEx or ApocalypseInside.
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

// Skill-gated choices have the same problem: OpheliaL2.con's SocialBoss
// gates "(Apologize to Wong)" and "(Manipulate Wong)" on skill "Chinese",
// level 3 (Master -- matches the authors' flowchart), but the engine
// resolves no class by that name (CNN's is AiSkillChinese), leaves
// skillNeeded None, and so offered both to every player (found 2026-10-02).
// ConChoice keeps no skill-name string to resolve from, so the gated
// choices are recognised by their jump labels.
function EEventAction SetupEventChoice(ConEventChoice event, out String nextLabel)
{
    local ConChoice choice;

    for (choice = event.ChoiceList; choice != None; choice = choice.nextChoice)
    {
        if ((choice.skillNeeded == None) &&
            ((choice.choiceLabel == "ApologizetoWong") || (choice.choiceLabel == "ManipulateWong")))
        {
            choice.skillNeeded = class'AiSkillChinese';
            choice.skillLevelNeeded = 3;
        }
    }

    return Super.SetupEventChoice(event, nextLabel);
}
