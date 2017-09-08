class OpheliaUI extends Secretary;

var () bool bUseBlinking;

function Tick(float deltaTime)
{
    super.Tick(deltaTime);
	BlinkActor();
}

function BlinkActor()
{
	local float blinkValue;
	
	if (bUseBlinking)
	{
		blinkValue = FRand();
		
		if (blinkValue > 0.5)
		{
			DrawType = DT_None;
		}
		else
		{
			DrawType = DT_Mesh;
		}
	}
}

DefaultProperties
{
	Orders=Standing
    Tag=Secretary
    Style=STY_Translucent
	AmbientGlow=140
    Texture=FireTexture'Effects.Electricity.AirTaserFX1'
    ScaleGlow=0.200000
    MultiSkins(0)=Texture'DeusExCharacters.Skins.Female4Tex0'
    MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.Female2Tex0'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.ScientistFemaleTex3'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.Female3Tex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.Female3Tex1'
    MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    BindName="OpheliaUI"
    FamiliarName="User Interface"
    UnfamiliarName="User Interface"
	bUseBlinking=true
}
