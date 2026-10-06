//=============================================================================
// CNNTimerDisplay
//
// TimerDisplay that shows whole seconds ("03:39" instead of "3:39.00000").
//=============================================================================
class CNNTimerDisplay extends TimerDisplay;

// Like DeusExHUD.CreateTimerWindow: returns None when the HUD's timer slot
// is taken.
static function TimerDisplay CreateIn(DeusExHUD hud)
{
    if ((hud == none) || (hud.timer != none))
        return none;

    hud.timer = TimerDisplay(hud.NewChild(class'CNNTimerDisplay'));
    if (hud.timer != none)
        hud.timer.AskParentForReconfigure();
    return hud.timer;
}

event DrawWindow(GC gc)
{
    local string str;
    local int total, mins, secs;

    gc.SetFont(Font'FontComputer8x20_B');
    gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
    gc.EnableWordWrap(false);

    if (bCritical)
        gc.SetTextColor(colCritical);
    else
        gc.SetTextColor(colNormal);

    // round up, so 00:00 shows exactly when the time runs out
    total = int(time);
    if (float(total) < time)
        total++;
    mins = total / 60;
    secs = total % 60;

    if (mins < 10)
        str = "0";
    str = str $ mins $ ":";
    if (secs < 10)
        str = str $ "0";
    str = str $ secs;

    if (bFlash && (flashTime >= 0.75))
    {
        gc.SetTextColor(colBlack);
        if (flashTime >= 1.0)
            flashTime = 0;
    }

    gc.DrawText(0, 0, width, height, str);

    gc.SetFont(Font'TechSmall');
    gc.SetAlignments(HALIGN_Left, VALIGN_Top);
    gc.DrawText(2, 2, width-2, height-2, message);
}
