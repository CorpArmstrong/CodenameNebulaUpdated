// ============================================================================
// ScreenUIPageAbout
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Content of About tab in Screen user interface.
// ============================================================================


class ScreenUIPageAbout extends AiUWindowPageWindow;


// ============================================================================
// Controls
// ============================================================================

var AiUWindowLabelControl LabelTitle;
var AiUWindowLabelControl LabelPermissions;
var AiUWindowLabelControl LabelSuggestions;
var AiUWindowLabelControl LabelCopyright;
var AiUWindowLabelControl LabelMail;
var AiUWindowSmallButton ButtonWebsite;


// ============================================================================
// Created
// ============================================================================

function Created() {

  LabelTitle = AiUWindowLabelControl(CreateControl(class 'AiUWindowLabelControl', 20, 17, WinWidth - 40, 1));
  LabelTitle.SetText("Screen Component" @ class 'Screen'.default.Version);
  LabelTitle.SetFont(F_Bold);

  LabelPermissions = AiUWindowLabelControl(CreateControl(class 'AiUWindowLabelControl', 20, 44, WinWidth - 40, 1));
  LabelPermissions.SetText("Free for noncommercial use and distribution.");

  LabelSuggestions = AiUWindowLabelControl(CreateControl(class 'AiUWindowLabelControl', 20, 56, WinWidth - 40, 1));
  LabelSuggestions.SetText("Feedback, bug reports and suggestions are welcome.");

  LabelCopyright = AiUWindowLabelControl(CreateControl(class 'AiUWindowLabelControl', 20, 83, WinWidth - 40, 1));
  LabelCopyright.SetText("Copyright 2001 by Mychaeel, mychaeel@planetunreal.com");

  ButtonWebsite = AiUWindowSmallButton(CreateControl(class 'AiUWindowSmallButton', 20, 123, 140, 1));
  ButtonWebsite.SetText("Visit the Screen Website");

  if (class 'Screen'.default.VersionLatest > class 'Screen'.default.Version)
    ButtonWebsite.SetText("Update Screen Component");
  }


// ============================================================================
// WindowShown
// ============================================================================

function WindowShown() {

  Super.WindowShown();

  AiUWindowPageWindow(ParentWindow).OwnerTab.bFlash = false;
  }


// ============================================================================
// Notify
// ============================================================================

function Notify(AiUWindowDialogControl Control, byte ControlEvent) {

  switch (Control) {
    case ButtonWebsite:
      if (ControlEvent == DE_Click)
        if (class 'Screen'.default.VersionLatest > class 'Screen'.default.Version)
          GetPlayerOwner().ConsoleCommand("start http://www.planetunreal.com/screen/download.html");
        else
          GetPlayerOwner().ConsoleCommand("start http://www.planetunreal.com/screen/");

      break;
    }
  }
defaultproperties
{
}
