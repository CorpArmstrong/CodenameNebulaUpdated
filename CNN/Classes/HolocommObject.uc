class HolocommObject extends Trigger;

struct SpawnInfo
{
	var() name spawnPointTag;
    var Actor spawnPoint;
    var vector _sp;
};

struct ContactInfo
{
    var() name entityTag;
    var() int entityId;
    var() bool isHidden;
};

var(SpawnInfo) SpawnInfo _spawnInfo;
var(ContactInfo) ContactInfo contacts[8];

function PostBeginPlay()
{
    if (_spawnInfo.spawnPoint == none)
    {
        _spawnInfo._sp = self.Location;
    }
    else
    {
        _spawnInfo._sp = _spawnInfo.spawnPoint.Location;
    }

    IterateContacts();

    Super.PostBeginPlay();
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

defaultproperties
{

}