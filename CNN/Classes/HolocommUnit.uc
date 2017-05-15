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
    var() bool bInitiallyHidden;
    var() bool bRepeatConversation;
    var() name conversationName;
    var() name hideFlagName;

    var() class<Actor> contactActorType;
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
		SetAndSpawnActor(contacts[0], false);
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

function IterateContacts()
{
    local int i;

    for (i = 0; i < ArrayCount(contacts); i++)
    {
    }
}

function SetAndSpawnActor(ContactInfo info, bool bStartConversation)
{
    info.contactActor = Spawn(info.contactActorType,,
                              info.contactActorTag,
                              _spawnInfo.spawnLocation,
                              _spawnInfo.spawnRotation);

	if (bStartConversation)
	{
		if (info.hideFlagName != '')
		{
			flags.SetBool(info.hideFlagName, false);
			bCheckForConvoEnd = true;
		}

		player.StartConversationByName(info.conversationName, info.contactActor);
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

    SetAndSpawnActor(contacts[contactIndex], true);

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