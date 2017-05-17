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
    var() name buttonName;
    var() class<Actor> contactActorType;
    var() name contactActorTag;
    var() bool bInitiallyHidden;
    var() bool bRepeatConversation;
    var() name hideFlagName;
    var Actor contactActor;
};

var(SpawnInfo) SpawnInfo _spawnInfo;
var(ContactInfo) ContactInfo contacts[8];

var DeusExPlayer player;
var FlagBase flags;
var int contactIndex;
var bool bCheckForConvoEnd;

function PostBeginPlay()
{
    // Get player and his flags.
    player = DeusExPlayer(GetPlayerPawn());
    flags = player.flagBase;

    // Setup the spawn point!
    if (!CanSetSpawnPoint())
    {
        _spawnInfo.spawnLocation = self.Location;
        _spawnInfo.spawnRotation = self.Rotation;
    }

    // Check first entry in ContactInfo list,
    // maybe there is already a hologram needs to be shown.

    if (!contacts[0].bInitiallyHidden)
    {
        SetAndSpawnActor(contacts[0]);
    }

    Super.PostBeginPlay();
}

function bool CanSetSpawnPoint()
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

function bool GetContactIndexByName(name buttonName, out int index)
{
    local int i;
    local bool result;

    for (i = 0; i < ArrayCount(contacts); i++)
    {
        if (contacts[i].buttonName == buttonName)
        {
            index = i;
            result = true;
            break;
        }
    }

    return result;
}

function SetAndSpawnActor(ContactInfo info)
{
    info.contactActor = Spawn(info.contactActorType,,
                              info.contactActorTag,
                              _spawnInfo.spawnLocation,
                              _spawnInfo.spawnRotation);

    if (info.hideFlagName != '')
    {
        flags.SetBool(info.hideFlagName, false);
        bCheckForConvoEnd = true;
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
	local Actor actr;

    if (GetContactIndexByName(Other.Tag, contactIndex))
    {
	    //SetAndSpawnActor(contacts[contactIndex]);

		actr = contacts[contactIndex].contactActor;

		if (actr == none)
        {
            SetAndSpawnActor(contacts[contactIndex]);
        }
    }

    Super.Trigger(Other, Instigator);
}

function Timer()
{
    if (bCheckForConvoEnd)
    {
        if (flags.GetBool(contacts[0].hideFlagName))
        {
            contacts[0].contactActor.Destroy();
            bCheckForConvoEnd = false;
        }
    }
}

defaultproperties
{
}