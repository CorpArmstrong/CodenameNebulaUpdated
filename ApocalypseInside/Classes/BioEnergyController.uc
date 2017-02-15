//-----------------------------------------------------------
// BioEnergyController.uc
//-----------------------------------------------------------
class BioEnergyController expands Actor;

var bool bNoEnergy;
var vector vc;

// Damage rate = (1.66 * 2) units / 2 sec
// Player will survive for 3 minutes. (Agony time) ;)
const DAMAGE_AMOUNT = 3.33;
const DAMAGE_PERIOD = 2;

var bool bTimerOn;

var DeusExPlayer _player;

// ----------------------------------------------------------------------
// PostBeginPlay()
//
// set up the augmentation and skill systems
// ----------------------------------------------------------------------

function PostBeginPlay() {
	vc = vect(0, 0, 0);
}


function Tick(float deltaTime) {

	// First time, assign player.
	if (_player == none) {
		_player = DeusExPlayer(GetPlayerPawn());
		_player.Energy = 2;
		self.AttachTag = _player.Tag;
	}

	// Check if player isn't dead, if so - turn off the timer.
	if (_player != none)
	{
		//_player.ClientMessage("your Chinese skill is");
		if (_player.Energy > 0)
		{
			adjustDamageTimer(false);
		}
		else
		{
	    	adjustDamageTimer(true);
		}
	}
	else
	{
		SetTimer(0.01, false);
		bTimerOn = false;
	}

	super.Tick(deltaTime);
}

function adjustDamageTimer(bool isOn) {
	if(isOn)
	{
		if (!bTimerOn)
		{
			DeusExPlayer(GetPlayerPawn()).ClientMessage("Test method12122.");
			SetTimer(DAMAGE_PERIOD, true);
			bTimerOn = true;
		}
	}
	else
	{
		if (bTimerOn) {
			SetTimer(0.01, false);
			bTimerOn = false;
		}
	}
}

function Timer() {
	DeusExPlayer(GetPlayerPawn()).ClientMessage("Test method.");
	DeusExPlayer(GetPlayerPawn()).TakeDamage(DAMAGE_AMOUNT, none, vc, vc, 'Shocked');
}

DefaultProperties {

}
