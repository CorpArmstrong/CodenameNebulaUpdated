//=============================================================================
// CNNTimerDisplay
//
// Vanilla TimerDisplay draws the seconds from a float local, so a countdown
// reads "3:39.00000" (seen on L2's MJ12 and upload timers, 2026-09-24).
// Same window, same background, fonts and colours, but whole seconds:
// "03:39". Create it with CreateIn() in place of DeusExHUD.CreateTimerWindow.
//=============================================================================
class CNNTimerDisplay extends TimerDisplay;

// Mirrors DeusExHUD.CreateTimerWindow: the HUD has one timer slot, and it
// hands back None when that slot is taken.
static function TimerDisplay CreateIn(DeusExHUD hud)
{
    if ((hud == None) || (hud.timer != None))
        return None;

    hud.timer = TimerDisplay(hud.NewChild(class'CNNTimerDisplay'));
    if (hud.timer != None)
        hud.timer.AskParentForReconfigure();
    return hud.timer;
}

event DrawWindow(GC gc)
{
    local string str;
    local int total, mins, secs;

    // Window.DrawWindow draws nothing; the background is set in InitWindow.

    gc.SetFont(Font'FontComputer8x20_B');
    gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
    gc.EnableWordWrap(False);

    if (bCritical)
        gc.SetTextColor(colCritical);
    else
        gc.SetTextColor(colNormal);

    // Round up, so the display reaches 00:00 exactly as the time runs out.
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
