//-----------------------------------------------------------
// CNNComputerSecurity
//-----------------------------------------------------------
class CNNComputerSecurity extends ComputerSecurity;

function ResumeDataLinks()
{
    // Don't stop datalinks
}

defaultproperties
{
    terminalType=class'CNN.CNNNetworkTerminalSecurity'
    BindName="CNNComputerSecurity"
    ItemName="CNN Security Computer Terminal"
}
