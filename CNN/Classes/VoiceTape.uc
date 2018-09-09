//=============================================================================
// VoiceTape.
//=============================================================================
class VoiceTape extends InformationDevices;

var() string conversationName;

function Frob(Actor Frobber, Inventory frobWith)
{
    local DeusExPlayer player;
    
    player = DeusExPlayer(Frobber);

    if (player != none)
    {
        player.StartDataLinkTransmission(conversationName);
    }
}

defaultproperties
{
    conversationName="DL_AlexIntro"
    bInvincible=true
    ItemName="Voice Tape"
    //Texture=Texture'DeusExItems.Skins.DataCubeTex2'
    // Use LodMesh'DeusExDeco.TAD' if not shipping the mod with HDTP. Or write code that checks if HDTP is enabled
    Mesh=LodMesh'DeusExDeco.TAD'
    CollisionRadius=7.000000
    CollisionHeight=1.270000
    Mass=2.000000
    Buoyancy=3.000000
}
