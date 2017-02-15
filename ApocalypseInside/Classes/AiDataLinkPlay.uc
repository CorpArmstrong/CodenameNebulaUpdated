//=============================================================================
// AiDataLinkPlay
//=============================================================================
class AiDataLinkPlay expands DataLinkPlay
	transient;

// Array of Bind -> Display names. Yes, horrible hack. Oh well.
var S_InfoLinkNames infoLinkNames[19]; //17

// ----------------------------------------------------------------------
// GetDisplayName()
//this is just for Janus. Hopefully this is temporary
// ----------------------------------------------------------------------
function String GetDisplayName(String bindName)
{
	local int nameIndex;
	local string displayName;

	//displayName = "";

	for(nameIndex=0; nameIndex<arrayCount(infoLinkNames); nameIndex++)
	{
		if (infoLinkNames[nameIndex].BindName == bindName)
		{
			displayName = infoLinkNames[nameIndex].DisplayName;
			DeusExPlayer(GetPlayerPawn()).ClientMessage("Infolink index: " $
				nameIndex $ ", Person: " $ displayName);
			break;
		}
	}
	return displayName;
}

defaultproperties
{
     startSound=Sound'DeusExSounds.UserInterface.DataLinkStart'
     blinkRate=0.500000
     startDelay=1.500000
     endDelay=5.000000
     perCharDelay=0.030000
     infoLinkNames(0)=(BindName="AlexJacobson",displayName="Alex Jacobson")
     infoLinkNames(1)=(BindName="AnnaNavarre",displayName="Anna Navarre")//(BindName="Janus",displayName="Janus")//(BindName="AnnaNavarre",displayName="Anna Navarre")
     infoLinkNames(2)=(BindName="BobPage",displayName="Bob Page")
     infoLinkNames(3)=(BindName="BobPageAug",displayName="Bob Page")
     infoLinkNames(4)=(BindName="Daedalus",displayName="Daedalus")
     infoLinkNames(5)=(BindName="GarySavage",displayName="Gary Savage")
     infoLinkNames(6)=(BindName="GuntherHermann",displayName="Gunther Hermann")
     infoLinkNames(7)=(BindName="Helios",displayName="Helios")
     infoLinkNames(8)=(BindName="Icarus",displayName="Icarus")
     infoLinkNames(9)=(BindName="JaimeReyes",displayName="Jaime Reyes")
     infoLinkNames(10)=(BindName="Jock",displayName="Jock")
     infoLinkNames(11)=(BindName="MorganEverett",displayName="Morgan Everett")
     infoLinkNames(12)=(BindName="PaulDenton",displayName="Paul Denton")
     infoLinkNames(13)=(BindName="SamCarter",displayName="Sam Carter")
     infoLinkNames(14)=(BindName="StantonDowd",displayName="Stanton Dowd")
     infoLinkNames(15)=(BindName="TracerTong",displayName="Tracer Tong")
     infoLinkNames(16)=(BindName="WaltonSimons",displayName="Walton Simons")
	 infoLinkNames(17)=(BindName="Janus",displayName="Janus")
	 infoLinkNames(18)=(BindName="Ada",displayName="Ada")
     EndTransmission="END TRANSMISSION..."
     bHidden=True
}
