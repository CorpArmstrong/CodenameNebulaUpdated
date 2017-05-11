class HolocommUnit extends CNNTrigger;

struct SpawnInfo
{
    var() name spawnPointTag;
    var Actor spawnPoint;
    var vector spawnLocation;
    var rotator spawnRotation;
};

struct ContactInfo
{
    var() name contactActorTag;
    var() int entityId;
    var() bool bHidden;
    var() bool bTranslucent;
    var() bool bRepeatConversation;

    var() class<Actor> contactActorType;
    var Actor contactActor;
};

var(SpawnInfo) SpawnInfo _spawnInfo;
var(ContactInfo) ContactInfo contacts[8];

var int contactIndex;

function PostBeginPlay()
{
    if (!bSetSpawnPoint())
    {
        _spawnInfo.spawnLocation = self.Location;
        _spawnInfo.spawnRotation = self.Rotation;
    }

    //IterateContacts();

    Super.PostBeginPlay();
}

function bool bSetSpawnPoint()
{
    local bool result;
    local Actor spawnPoint;

    if (_spawnInfo.spawnPointTag != '')
    {
        foreach AllActors(class'Actor', spawnPoint, _spawnInfo.spawnPointTag)
        {
            _spawnInfo.spawnPoint = spawnPoint;
            break;
        }

        if (spawnPoint != none)
        {
            _spawnInfo.spawnLocation = spawnPoint.Location;
            _spawnInfo.spawnRotation = spawnPoint.Rotation;
            result = true;
        }
    }

    return result;
}

function IterateContacts()
{
    local int i;

    for (i = 0; i < ArrayCount(contacts); i++)
    {
        if (contacts[i].entityId == 5)
        {
            log("...");
        }
    }
}

function SetAndSpawnActor(ContactInfo info)
{
    info.contactActor = Spawn(info.contactActorType,,
                              info.contactActorTag,
                              _spawnInfo.spawnLocation,
                              _spawnInfo.spawnRotation);

    if (info.bTranslucent)
    {
        info.contactActor.Style = ERenderStyle.STY_Translucent;
    /*
        info.contactActor.SetDisplayProperties(ERenderStyle.STY_Translucent,
                                               info.contactActor.Texture,
                                               false,
                                               false);
                                               */
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    /*
    if (Instigator.Tag == 'LightSwitch')
    {
        SetAndSpawnActor();
    }
    */

    SetAndSpawnActor(contacts[contactIndex]);

    Super.Trigger(Other, Instigator);
}

defaultproperties
{

}