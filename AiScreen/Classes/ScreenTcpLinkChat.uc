// ============================================================================
// ScreenTcpLinkChat
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Monitors a chat.
// ============================================================================


class ScreenTcpLinkChat extends TcpLink;


// ============================================================================
// Properties
// ============================================================================

var() ScreenSlidePageChat Page;

var() string AddressServer;
var() int AddressPort;
var() string AddressChannel;


// ============================================================================
// Constants
// ============================================================================

const IRC_RPL_ENDOFMOTD         = "376";

const IRC_ERR_NOMOTD            = "422";
const IRC_ERR_ERRONEOUSNICKNAME = "432";
const IRC_ERR_NICKNAMEINUSE     = "433";
const IRC_ERR_NICKCOLLISION     = "436";


// ============================================================================
// Variables
// ============================================================================

var bool FlagConnected;

var int CountNicknameTries;
var string TextNickname;
var string TextNicknameBase;
var string TextUsername;

var string TextBuffer;

var string CRLF;


// ============================================================================
// PreBeginPlay
// ============================================================================

simulated event PreBeginPlay() {

  CRLF = Chr(13) $ Chr(10);
  
  Super.PreBeginPlay();
  }


// ============================================================================
// Tick
// ============================================================================

simulated event Tick(float TimeDelta) {

  local PlayerPawn ThisPlayer;

  Super.Tick(TimeDelta);

  if (Len(TextNicknameBase) > 0)
    return;

  foreach Page.AllActors(class 'PlayerPawn', ThisPlayer)
    if (Viewport(ThisPlayer.Player) != None)
      TextNicknameBase = ThisPlayer.PlayerReplicationInfo.PlayerName;

  if (Len(TextNicknameBase) == 0)
    return;

  Resolve(AddressServer);
  }


// ============================================================================
// Resolved
// ============================================================================

event Resolved(IpAddr AddressIp) {

  local int AddressLocalPort;

  AddressIp.Port = AddressPort;
  AddressLocalPort = BindPort();
  
  Log("Resolved" @ AddressServer @ "to" @ IpAddrToString(AddressIp), 'ScreenTcpLinkChat');
  Log("Local port is" @ AddressLocalPort, 'ScreenTcpLinkChat');

  Open(AddressIp);
  }


// ============================================================================
// ResolveFailed
// ============================================================================

event ResolveFailed() {

  Log("Unable to resolve" @ AddressServer, 'ScreenTcpLinkChat');
  
  Destroy();
  }


// ============================================================================
// Opened
// ============================================================================

event Opened() {

  local int IndexChar;
  local string CharUsername;

  Log("Opened" @ AddressServer $ ":" $ AddressPort, 'ScreenTcpLinkChat');

  CountNicknameTries = 1;
  TextNickname = Left(TextNicknameBase, 9);

  for (IndexChar = 0; IndexChar < Len(TextNickname); IndexChar++) {
    CharUsername = Chr(Asc(Mid(TextNickname, IndexChar, 1)) & ~0x20);
    if (CharUsername >= "a" && CharUsername <= "z")
      TextUsername = TextUsername $ CharUsername;
    }

  if (Len(TextUsername) == 0)
    TextUsername = "user" $ rand(10000);

  LinkMode = MODE_Text;
  SendText("NICK" @ TextNickname $ CRLF);
  SendText("USER" @ TextUsername @ "127.0.0.1" @ AddressServer @ ":" $ TextNickname $ CRLF);
  }


// ============================================================================
// ReceivedText
// ============================================================================

event ReceivedText(string TextReceived) {

  local ScreenSlidePageChat PageChannel;
  local int IndexCharSeparator;
  local string TextCommand;
  local string TextLine;
  local string TextNicknameSender;
  local string TextNicknameSuffix;

  TextBuffer = TextBuffer $ TextReceived;
  
  while (true) {
    IndexCharSeparator = InStr(TextBuffer, Chr(10));
    if (IndexCharSeparator < 0)
      break;
    
    TextLine   = Left(TextBuffer, IndexCharSeparator);
    TextBuffer = Mid (TextBuffer, IndexCharSeparator + 1);
    
    if (Right(TextLine, 1) == Chr(13))
      TextLine = Left(TextLine, Len(TextLine) - 1);

    TextNicknameSender = ParseNicknameSender(TextLine);
    TextCommand = Caps(ParseToken(TextLine));

    switch (TextCommand) {
      case "PING":
        SendText("PONG" @ ParseToken(TextLine) $ CRLF);
        break;
    
      case IRC_ERR_NICKNAMEINUSE:
      case IRC_ERR_ERRONEOUSNICKNAME:
      case IRC_ERR_NICKCOLLISION:
        if (CountNicknameTries == 1)
          TextNicknameSuffix = "-";
        else
          TextNicknameSuffix = string(Rand(10000));
        
        CountNicknameTries++;
        TextNickname = Left(TextNicknameBase, 9 - Len(TextNicknameSuffix)) $ TextNicknameSuffix;
        SendText("NICK" @ TextNickname $ CRLF);
        break;

      case IRC_RPL_ENDOFMOTD:
      case IRC_ERR_NOMOTD:
        FlagConnected = true;

      default:
        for (PageChannel = Page; PageChannel != None; PageChannel = PageChannel.PageChannelNext)
          PageChannel.ParseResponse(TextNicknameSender, TextCommand, TextLine);
        break;
      }
    }
  }


// ============================================================================
// Closed
// ============================================================================

event Closed() {

  Log("Closed" @ AddressServer $ ":" $ AddressPort, 'ScreenTcpLinkChat');
  }


// ============================================================================
// Destroyed
// ============================================================================

simulated event Destroyed() {

  SendText("QUIT" $ CRLF);
  Close();
  }


// ============================================================================
// AddChannel
//
// Adds a channel on the same server to the list.
// ============================================================================

simulated function AddChannel(ScreenSlidePageChat PageChannel) {

  PageChannel.PageChannelNext = Page;
  Page = PageChannel;
  
  if (FlagConnected)
    PageChannel.ParseResponse("", IRC_ERR_NOMOTD, "");
  }


// ============================================================================
// ParseNicknameSender
//
// Checks whether the given string is lead by a nickname parameter, removes it
// from the string argument and returns it.
// ============================================================================

simulated function string ParseNicknameSender(out string TextResponse) {

  local int IndexCharSeparator;
  local string TextNicknameSender;

  if (Left(TextResponse, 1) != ":")
    return "";
  
  TextResponse = Mid(TextResponse, 1);
  
  IndexCharSeparator = InStr(TextResponse, " ");
  if (IndexCharSeparator < 0)
    IndexCharSeparator = Len(TextResponse);
  
  TextNicknameSender = Left(TextResponse, IndexCharSeparator);

  TextResponse = Mid(TextResponse, IndexCharSeparator + 1);
  while (Left(TextResponse, 1) == " ")
    TextResponse = Mid(TextResponse, 1);

  IndexCharSeparator = InStr(TextNicknameSender, "!");
  if (IndexCharSeparator >= 0)
    TextNicknameSender = Left(TextNicknameSender, IndexCharSeparator);

  return TextNicknameSender;
  }


// ============================================================================
// ParseToken
//
// Returns the next token in the given string and removes it from the string
// argument.
// ============================================================================

simulated function string ParseToken(out string TextResponse) {

  local int IndexCharSeparator;
  local string TextToken;

  if (Left(TextResponse, 1) == ":") {
    TextToken = Mid(TextResponse, 1);
    TextResponse = "";
    return TextToken;
    }
  
  IndexCharSeparator = InStr(TextResponse, " ");
  if (IndexCharSeparator < 0)
    IndexCharSeparator = Len(TextResponse);
  
  TextToken = Left(TextResponse, IndexCharSeparator);
  
  TextResponse = Mid(TextResponse, IndexCharSeparator + 1);
  while (Left(TextResponse, 1) == " ")
    TextResponse = Mid(TextResponse, 1);

  return TextToken;
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    RemoteRole=2
}
