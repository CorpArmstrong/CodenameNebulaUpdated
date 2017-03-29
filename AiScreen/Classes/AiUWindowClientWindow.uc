//=============================================================================
// AiUWindowClientWindow - a blanked client-area window.
//=============================================================================
class AiUWindowClientWindow extends AiUWindowWindow;

#exec TEXTURE IMPORT NAME=Background FILE=Textures\Background.bmp GROUP="Icons" MIPS=OFF


function Close(optional bool bByParent)
{
	if(!bByParent)
		ParentWindow.Close(bByParent);

	Super.Close(bByParent);
}

defaultproperties
{
}
