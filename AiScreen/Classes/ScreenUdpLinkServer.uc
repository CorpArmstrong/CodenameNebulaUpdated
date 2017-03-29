// ============================================================================
// ScreenUdpLinkServer
// Copyright 2002 by Mychaeel <mychaeel@planetunreal.com>
//
// Queries game server information.
// ============================================================================


class ScreenUdpLinkServer extends UdpLink;


// ============================================================================
// Properties
// ============================================================================

var() ScreenSlidePageServer Page;

var() string AddressServer;
var() int AddressPort;

var() int RetryCount;
var() float RetryDelay;
var() float Timeout;


// ============================================================================
// Variables
// ============================================================================

var bool FlagBound;
var name NameState;
var IpAddr IpAddrServer;


// ============================================================================
// GetInfoServer
//
// Starts a query for server information.
// ============================================================================

function GetInfoServer() {

  NameState = 'InfoServer';
  
  GotoState('Resolving');
  }


// ============================================================================
// GetInfoGame
//
// Starts a query for game and player information.
// ============================================================================

function GetInfoGame() {

  NameState = 'InfoGame';
  
  GotoState('Resolving');
  }


// ============================================================================
// state Resolving
// ============================================================================

state Resolving {

  // ==========================================================================
  // BeginState
  // ==========================================================================
  
  event BeginState() {
  
    if (FlagBound)
      GotoState(NameState);
    else
      Resolve(AddressServer);
    }
  
  
  // ==========================================================================
  // Resolved
  // ==========================================================================
  
  event Resolved(IpAddr IpAddrResolved) {
  
    IpAddrServer.Addr = IpAddrResolved.Addr;
    IpAddrServer.Port = AddressPort;

    if (BindPort(2000, true) == 0) {
      RetryCount--;
      if (RetryCount > 0)
        SetTimer(RetryDelay, false);
      return;
      }
  
    FlagBound = true;

    GotoState(NameState);
    }
  
  
  // ==========================================================================
  // ResolveFailed
  // ==========================================================================
  
  event ResolveFailed() {
  
    Log("Unable to resolve" @ AddressServer, 'ScreenUdpLinkServer');
  
    Destroy();
    }
  
  
  // ==========================================================================
  // Timer
  // ==========================================================================
  
  event Timer() {
  
    Resolved(IpAddrServer);
    }
  
  } // state Resolving


// ============================================================================
// state InfoServer
// ============================================================================

state InfoServer {

  // ==========================================================================
  // BeginState
  // ==========================================================================

  event BeginState() {
  
    SendText(IpAddrServer, "\\info\\");

    SetTimer(Timeout, false);
    }


  // ==========================================================================
  // ReceivedText
  // ==========================================================================
  
  event ReceivedText(IpAddr IpAddrSender, string Text) {
  
    if (IpAddrServer.Addr != IpAddrSender.Addr)
      return;

    Page.ReceiveInfoServer(Text);

    SetTimer(0.0, false);
    }


  // ==========================================================================
  // Timer
  // ==========================================================================

  event Timer() {
  
    Log("Timed out retrieving server information from" @ AddressServer, 'ScreenUdpLinkServer');

    Page.Timeout();
    }

  } // state InfoServer


// ============================================================================
// state InfoGame
// ============================================================================

state InfoGame {

  // ==========================================================================
  // BeginState
  // ==========================================================================

  event BeginState() {
  
    SendText(IpAddrServer, "\\status\\");
  
    SetTimer(Timeout, false);
    }


  // ==========================================================================
  // ReceivedText
  // ==========================================================================

  event ReceivedText(IpAddr IpAddrSender, string Text) {
  
    if (IpAddrServer.Addr != IpAddrSender.Addr)
      return;

    Page.ReceiveInfoGame(Text);

    SetTimer(Timeout, false);
    }


  // ==========================================================================
  // Timer
  // ==========================================================================

  event Timer() {
  
    Log("Timed out retrieving game information from" @ AddressServer, 'ScreenUpdLinkServer');
    
    Page.Timeout();
    }

  } // state InfoGame


// ============================================================================
// Destroyed
// ============================================================================

event Destroyed() {

  if (Page != None)
    Page.FlagReloading = false;
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    AddressPort=7778
    RetryCount=5
    RetryDelay=0.10
    TimeOut=1.00
}
