//=============================================================================
// AngelCarcass.
//=============================================================================
class AngelCarcass extends DeusExCarcass;
/*
simulated function Tick(float deltaTime)
{
   if ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority))
      return;
  
	// fade out the object smoothly 2 seconds before it dies completely
	if (LifeSpan <= 2)
	{
		if (Style != STY_Translucent)
			Style = STY_Translucent;

		ScaleGlow = LifeSpan / 2.0;
	}
}*/

defaultproperties
{
    Mesh2=LodMesh'DeusExCharacters.PigeonCarcass'
    Mesh3=LodMesh'DeusExCharacters.PigeonCarcass'
    bAnimalCarcass=True
    Mesh=LodMesh'DeusExCharacters.PigeonCarcass'
    CollisionRadius=13.00
    CollisionHeight=2.60
	LifeSpan=10.00
}
