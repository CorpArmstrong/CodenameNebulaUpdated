//-----------------------------------------------------------------------
// Class:    HolocommUnit
// Author:   CorpArmstrong
//-----------------------------------------------------------------------
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

var TantalusDenton player;
var FlagBase flags;
var int contactIndex;
var bool bCheckForConvoEnd;

// ----------------------------------------------------------------------
// ResolvePlayer()
//
// PostBeginPlay() can run before the player pawn exists, so caching the
// player once there leaves `player` permanently None -- and Tick() then
// dereferenced it every single frame. A 5-minute L2 session logged 16,489
// "Accessed None" warnings from Tick alone, 97% of the whole log, on top of
// the per-frame script error. Re-resolve lazily instead of trusting a
// single early attempt.
// ----------------------------------------------------------------------

function bool ResolvePlayer()
{
    if (player == None)
    {
        player = TantalusDenton(GetPlayerPawn());
        if (player == None)
            return false;
    }

    if (flags == None)
        flags = player.flagBase;

    return (flags != None);
}

function PostBeginPlay()
{
    // May legitimately fail this early; Tick() and the frobbing path both
    // retry through ResolvePlayer().
    ResolvePlayer();

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

function SetAndSpawnActor(out ContactInfo info)
{
    info.contactActor = Spawn(info.contactActorType,,
                              info.contactActorTag,
                              _spawnInfo.spawnLocation,
                              _spawnInfo.spawnRotation);

    // Called from PostBeginPlay(), where the player may not exist yet, so
    // resolve rather than assume `flags` was cached successfully.
    if ((info.hideFlagName != '') && ResolvePlayer())
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
        actr = contacts[contactIndex].contactActor;

        if (actr == none)
        {
            SetAndSpawnActor(contacts[contactIndex]);
        }
        else
        {
            if (contacts[contactIndex].bRepeatConversation && actr.bHidden)
            {
                contacts[contactIndex].contactActor.bHidden = false;
            }
        }
    }

    super.Trigger(Other, Instigator);
}

// ============================================================================
// Tick
// ============================================================================
simulated function Tick(float TimeDelta)
{
    super.Tick(TimeDelta);

    // Cheapest test first: this is per-frame code and the flag is false for
    // almost the whole level.
    if (!bCheckForConvoEnd)
        return;

    if (!ResolvePlayer())
        return;

    if (player.IsInState('Conversation'))
        return;

    // contactActor is spawned by SetAndSpawnActor, but a Spawn() can fail
    // (no room at the spawn point), which would make this the next per-frame
    // Accessed None. Stop watching rather than retry forever.
    if (contacts[contactIndex].contactActor == None)
    {
        bCheckForConvoEnd = false;
        return;
    }

    if (flags.GetBool(contacts[contactIndex].hideFlagName))
    {
        contacts[contactIndex].contactActor.bHidden = true;
        bCheckForConvoEnd = false;
    }
}
