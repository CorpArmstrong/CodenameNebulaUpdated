// ============================================================================
// ScreenClient
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Client-side bridge head for replication purposes.
// ============================================================================


class ScreenClient extends Info nousercreate;


// ============================================================================
// Replication
// ============================================================================

replication {

  reliable if (Role == ROLE_Authority)
    Say;
  }


// ============================================================================
// Say
//
// Receives player messages from ScreenMutator and passes them to all
// ScreenSlidePageChat actors around.
// ============================================================================

simulated function Say(string TextMessage, name NameType) {

  local ScreenSlidePageChat ThisSlide;

  foreach AllActors(class 'ScreenSlidePageChat', ThisSlide)
    if ((ThisSlide.FlagDisplayed || !ThisSlide.SendWatching) &&
        ((ThisSlide.SendSay     && NameType == 'Say') ||
         (ThisSlide.SendSayTeam && NameType == 'TeamSay')))
      ThisSlide.MessageSend(TextMessage);
  }
defaultproperties
{
}
