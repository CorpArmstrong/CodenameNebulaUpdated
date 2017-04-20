//=============================================================================
// OsirisDamage.	(c) 2003 JimBowen
//=============================================================================
class OsirisDamage expands Effects;

var (Bowen) int Damage, MaxDamage;
var float CurrentRadius;
var float f;
var bool bDeflating;
var float blastRadius;
var DummyDecoration DecKiller;

function PostBeginPlay()
{
	SetTimer(0.5, True);
	DecKiller = Spawn(Class'DummyDecoration');
	DecKiller.ItemName="Osiris orbital plasma cannon";
	DecKiller.ItemArticle="an";
	DecKiller.bInvincible=True;
	DecKiller.LifeSpan=40;
}

simulated function tick(float deltatime)
{
	if(!bDeflating)
		f += DeltaTime;
	if (bDeflating && f > 0)
		f -= DeltaTime;
	
	if(f >= 5)
		bDeflating = True;
	
	/*log("f = " @ f);
	log("dt = " @ deltatime);
	log("bdf = " @ bDeflating);*/
		
	CurrentRadius = BlastRadius * f * 3.606557;
	if(!bDeflating)
		DrawScale = Default.DrawScale + 0.2 * (Default.DrawScale * sin(3*Level.TimeSeconds));
	else if (drawScale > 0)
		DrawScale -= (deltaTime/5);
}

function timer()
{
	local actor a;
	local int Dam, FinDam;

		if (Role != ROLE_Authority)
			Destroy();

		if (Pawn(Owner) == None)
			return;
	
		if (!(bDeflating && f < 0.5))
		{

			foreach allactors (class'Actor', a)
			{
				if (a == None)
					continue;

				if(VSize(a.Location - Location) < CurrentRadius)
				{
					Dam = int((4 * Damage) / (0.25*VSize(a.Location - Location)));
			
					if(FastTrace (Location, a.Location))
						Dam *= 5;
					if(DeusExPlayer(a) != None)
						DeusExPlayer(a).MyProjKiller = DecKiller;
					FinDam = int(FMax(1,int(FMin(Dam,MaxDamage))));
					a.TakeDamage(FinDam, Pawn(Owner), a.Location, vect(0,0,0), 'Exploded');
				}
				if((VSize(a.Location - Location) < 500) || (FastTrace (Location, a.Location)))
				{
					a.TakeDamage(0, Pawn(Owner), a.Location, vect(0,0,0), 'Radiation');
					a.TakeDamage(10, Pawn(Owner), a.Location, vect(0,0,0), 'EMP');
				}
			}
			
		}

}

//---END-CLASS---

defaultproperties
{
     Damage=350
     MaxDamage=95
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'BowenCust.Effects.cet_a00'
     DrawScale=2.500000
     BlastRadius=384
     bAlwaysRelevant=True
}
