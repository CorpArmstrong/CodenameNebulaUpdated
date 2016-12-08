//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CNNSphereFragment extends CNNActor;

//var texture myTexture;

var int synchParam;

function Tick(float deltaTime)
{
         super.Tick(deltaTime);
}

defaultproperties
{
     synchParam=2
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'DeusExDeco.Moon'
     MultiSkins(0)=FireTexture'Effects.Electricity.Nano_SFX'
}
