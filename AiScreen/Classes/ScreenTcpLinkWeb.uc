// ============================================================================
// ScreenTcpLinkWeb
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Gets data from the web.
// ============================================================================


class ScreenTcpLinkWeb extends TcpLink;


// ============================================================================
// Properties
// ============================================================================

var() ScreenSlidePageWeb Page;

var() string AddressHost;
var() int AddressPort;
var() string AddressPath;


// ============================================================================
// Variables
// ============================================================================

var string Buffer;


// ============================================================================
// Start
//
// Starts the connection.
// ============================================================================

function Start() {

  Buffer = "";
  Resolve(AddressHost);
  }


// ============================================================================
// Resolved
// ============================================================================

event Resolved(IpAddr AddressIp) {

  local int AddressLocalPort;

  AddressIp.Port = AddressPort;
  AddressLocalPort = BindPort();
  
  Log("Resolved" @ AddressHost @ "to" @ IpAddrToString(AddressIp), 'ScreenTcpLinkWeb');
  Log("Local port is" @ AddressLocalPort, 'ScreenTcpLinkWeb');

  Open(AddressIp);
  }


// ============================================================================
// ResolveFailed
// ============================================================================

event ResolveFailed() {

  Log("Unable to resolve" @ AddressHost, 'ScreenTcpLinkWeb');
  
  Destroy();
  }


// ============================================================================
// Opened
// ============================================================================

event Opened() {

  local string Query;

  Log("Opened" @ AddressHost $ ":" $ AddressPort, 'ScreenTcpLinkWeb');

  Query = "GET" @ AddressPath @ "HTTP/1.0" $ Chr(13) $ Chr(10) $
          "Host:" @ AddressHost $ Chr(13) $ Chr(10) $
          Chr(13) $ Chr(10);

  LinkMode = MODE_Text;
  SendText(Query);
  }


// ============================================================================
// ReceivedText
// ============================================================================

event ReceivedText(string Text) {

  if (Len(Buffer) == 0)
    Log("Receiving text from" @ AddressHost $ ":" $ AddressPort, 'ScreenTcpLinkWeb');
  
  Buffer = Buffer $ Text;
  }


// ============================================================================
// Closed
// ============================================================================

event Closed() {

  Log("Closed" @ AddressHost $ ":" $ AddressPort, 'ScreenTcpLinkWeb');
  
  Buffer = Mid(Buffer, InStr(Buffer, Chr(13) $ Chr(10) $ Chr(13) $ Chr(10)) + 4);

  if (Len(Buffer) > 0) {
    Page.Text = Buffer;

    if (Page.Cached)
      Page.CacheSave();
    }

  Destroy();
  }


// ============================================================================
// Destroyed
// ============================================================================

function Destroyed() {

  Page.FlagReloading = false;
  }
defaultproperties
{
}
