//=============================================================================
// IwHUDHitDisplay
//=============================================================================
class IwHUDHitDisplay expands HUDHitDisplay;


#exec TEXTURE IMPORT FILE="Textures\NewHUDHitDisplay_Head.pcx"    NAME="NewHUDHitDisplay_Head" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\NewHUDHitDisplay_Torso.pcx"   NAME="NewHUDHitDisplay_Torso" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\NewHUDHitDisplay_ArmRight.pcx" NAME="NewHUDHitDisplay_ArmRight" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\NewHUDHitDisplay_ArmLeft.pcx"    NAME="NewHUDHitDisplay_ArmLeft" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\NewHUDHitDisplay_LegRight.pcx" NAME="NewHUDHitDisplay_LegRight" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\NewHUDHitDisplay_LegLeft.pcx"    NAME="NewHUDHitDisplay_LegLeft" GROUP="UserInterface" MIPS=Off
#exec TEXTURE IMPORT FILE="Textures\NewHUDHitDisplay_Body.pcx"    NAME="NewHUDHitDisplay_Body" GROUP="UserInterface" MIPS=Off


// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
    local window bodyWin;

    //Super.InitWindow();

    bTickEnabled = True;

    Hide();

    player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);

    SetSize(84, 106);

    CreateBodyPart(head,     Texture'NewHUDHitDisplay_Head',     47, 17,  12,  12);
    CreateBodyPart(torso,    Texture'NewHUDHitDisplay_Torso',    43, 30, 17,  34); //w,h
    CreateBodyPart(armLeft,  Texture'NewHUDHitDisplay_ArmLeft',  60, 31, 13,  34); //w,h
    CreateBodyPart(armRight, Texture'NewHUDHitDisplay_ArmRight', 30, 31, 13,  34); //w,h
    CreateBodyPart(legLeft,  Texture'NewHUDHitDisplay_LegLeft',  53, 64,  14,  36); //w,h
    CreateBodyPart(legRight, Texture'NewHUDHitDisplay_LegRight', 39, 64,  14,  36); //w,h

    bodyWin = NewChild(Class'Window');
    bodyWin.SetBackground(Texture'NewHUDHitDisplay_Body');
    bodyWin.SetBackgroundStyle(DSTY_Translucent);
    //bodyWin.SetConfiguration(24, 15, 34, 68);
    bodyWin.SetConfiguration(12, 4, 64, 128);
    bodyWin.SetTileColor(colArmor);
    bodyWin.Lower();

    winEnergy = CreateProgressBar(15, 20);
    winBreath = CreateProgressBar(61, 20);

    damageFlash = 0.4;  // seconds
    healFlash   = 1.0;  // seconds
}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
//  gc.SetStyle(backgroundDrawStyle);
//  gc.SetTileColor(colBackground);
//  gc.DrawTexture(11, 11, 60, 76, 0, 0, texBackground);
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
//log("DrawBorder");
    if (bDrawBorder)
    {
//      gc.SetStyle(borderDrawStyle);
//      gc.SetTileColor(colBorder);
//      gc.DrawTexture(0, 0, 84, 106, 0, 0, texBorder);
    }

}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     colArmor=(R=74,G=148,B=172)
     O2Text="O2"
     EnergyText="Emc2"
     bDrawBorder=false
}
