//================================================================================
// AiSkillManager.
//================================================================================
class AiSkillManager extends SkillManager;

defaultproperties
{
    skillClasses(0)=Class'SkillWeaponPistol'
	skillClasses(1)=Class'SkillWeaponLowTech'
	skillClasses(2)=Class'SkillHeavy'
    skillClasses(3)=Class'SkillDemolition'
    skillClasses(4)=Class'SkillWeaponRifle'
    skillClasses(5)=Class'AiSkillChinese'
    skillClasses(6)=class'SkillSwimming'
    skillClasses(7)=Class'SkillEnviro'
    skillClasses(8)=Class'SkillLockpicking'
    skillClasses(9)=Class'SkillTech'
    skillClasses(10)=Class'SkillMedicine'
    skillClasses(11)=class'SkillComputer'
    NoToolMessage="You need the %s"
    NoSkillMessage="%s skill level insufficient to use the %s"
    SuccessMessage="Success!"
    YourSkillLevelAt="Your skill level at %s is now %d"
    bHidden=true
    bTravel=true
}
