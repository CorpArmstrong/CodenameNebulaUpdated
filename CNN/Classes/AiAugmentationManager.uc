//=============================================================================
// AiAugmentationManager
//=============================================================================
class AiAugmentationManager extends AugmentationManager;

var Class<Augmentation> augClasses[25]; //was 25.  Can be increased as needed

// ----------------------------------------------------------------------
// CreateAugmentations()
// ----------------------------------------------------------------------

function CreateAugmentations(DeusExPlayer newPlayer)
{
	local int augIndex;
	local Augmentation anAug;
	local Augmentation lastAug;

	FirstAug = None;
	LastAug  = None;

	player = newPlayer;

	for(augIndex=0; augIndex<arrayCount(augClasses); augIndex++)
	{
		if (augClasses[augIndex] != None)
		{
			anAug = Spawn(augClasses[augIndex], Self);
			anAug.Player = player;

			// Manage our linked list
			if (anAug != None)
			{
				if (FirstAug == None)
				{
					FirstAug = anAug;
				}
				else
				{
					LastAug.next = anAug;
				}

				LastAug  = anAug;
			}
		}
	}
}

defaultproperties
{
    AugLocs(0)=(NumSlots=1,AugCount=0,KeyBase=4),
    AugLocs(1)=(NumSlots=1,AugCount=0,KeyBase=7),
    AugLocs(2)=(NumSlots=3,AugCount=0,KeyBase=8),
    AugLocs(3)=(NumSlots=1,AugCount=0,KeyBase=5),
    AugLocs(4)=(NumSlots=1,AugCount=0,KeyBase=6),
    AugLocs(5)=(NumSlots=2,AugCount=0,KeyBase=2),
    AugLocs(6)=(NumSlots=3,AugCount=0,KeyBase=11),
    augClasses(0)=Class'AugSpeed'
    augClasses(1)=Class'AugTarget'
    augClasses(2)=Class'AugCloak'
    augClasses(3)=Class'AugBallistic'
    augClasses(4)=Class'AugRadarTrans'
    augClasses(5)=Class'AugShield'
    augClasses(6)=Class'AugEnviro'
    augClasses(7)=Class'AugEMP'
    augClasses(8)=Class'AugCombat'
    augClasses(9)=Class'AugHealing'
    augClasses(10)=Class'AugStealth'
    augClasses(11)=Class'AugIFF'
    augClasses(12)=Class'AugLight'
    augClasses(13)=Class'AugMuscle'
    augClasses(14)=Class'AugVision'
    augClasses(15)=Class'AugDrone'
    augClasses(16)=Class'AugDefense'
    augClasses(17)=Class'AugAqualung'
    augClasses(18)=Class'AugDatalink'
    augClasses(19)=Class'AugHeartLung'
    augClasses(20)=Class'AugPower'
     augClasses(21)=Class'ApocalypseInside.AugIcarus'
     defaultAugs(0)=Class'DeusEx.AugHeartLung'
     defaultAugs(1)=Class'DeusEx.AugIFF'
     defaultAugs(2)=Class'DeusEx.AugDatalink'
     AugLocationFull="You can't add any more augmentations to that location!"
     NoAugInSlot="There is no augmentation in that slot"
     //HighPowerDrain="High power drain detected"
     bHidden=True
     bTravel=True
}
