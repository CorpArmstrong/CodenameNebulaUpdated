//=============================================================================
// AugSkullGun. -- Idea graciously stolen from AllSystemsGo on the GameFAQs
//  Deus Ex message board. -- Y|yukichigai
//=============================================================================
class AugSkullGunLethal extends Augmentation;

var float mpAugValue;
var float mpEnergyDrain;

function Activate() //Doesn't need to be overridden, but it makes things easier to do it here.
{
	local Vector Start;
	local Rotator AdjustedAim;
	local float ProjSpeed;
	local class<projectile> ProjClass;
	local DeusExProjectile proj;
	local float perc, temp;

	if(!bHasIt)
		return;

	//== Set some variables
	ProjClass = Class'DeusEx.GraySpit';
	ProjSpeed = ProjClass.Default.speed;
	Start = Player.Location + Player.BaseEyeHeight * vect(0,0,1); //Start point
	AdjustedAim = Player.AdjustAim(ProjSpeed,Start,0.000000,True,False); //Vector path

	//== Spawn the projectile
	proj = DeusExProjectile(Spawn(ProjClass,Player,,Start,AdjustedAim));

	//== Get the amount of available BioE Energy the player has and turn it into a percent
	perc = (Player.Energy / Player.EnergyMax) / LevelValues[CurrentLevel];
	if(perc > 1.000000) perc = 1.000000; //Only drain 100% of the required for the current level

	proj.blastRadius = 50.000000; //Smaller blast radius for accuracy
	proj.Damage = (100.000000 + (25.00000/LevelValues[CurrentLevel])) * perc; //Set the damage based on the percentage

	temp = Player.EnergyMax * perc * LevelValues[CurrentLevel]; //Calculate the amount to be drained

	Player.Energy -= temp; //Drain that amount

	Player.PlaySound(sound'DeusExSounds.Animal.GrayShoot',,perc,, 1280 * perc);
}

state Active
{
Begin:
}

function Deactivate()
{
	Super.Deactivate();
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		EnergyRate = mpEnergyDrain;
	}
}

defaultproperties
{
     mpAugValue=0.500000
     mpEnergyDrain=10.000000
     EnergyRate=10.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconDatalink'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconDatalink_Small'
     AugmentationName="Gray Skull Gun"
     Description="Nano factories programmed to emit radiation.|n|nTECH ONE: Energy consumption is high.|n|nTECH TWO: Energy consumption is lowered.|n|nTECH THREE: Energy consumption is lowered further.|n|nTECH FOUR: Energy consumption is minimal."
     MPInfo="Fires a burst of radiation from the cranial area.  Energy Drain: High"
     LevelValues(0)=0.333333
     LevelValues(1)=0.250000
     LevelValues(2)=0.125000
     LevelValues(3)=0.062500
     LevelValues(4)=0.031250
     MPConflictSlot=3
}
