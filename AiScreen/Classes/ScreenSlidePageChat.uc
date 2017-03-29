// ============================================================================
// ScreenSlidePageChat
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlidePage that monitors a chat.
// ============================================================================


class ScreenSlidePageChat extends ScreenSlidePage;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorSlidePageChat.bmp name=ActorSlidePageChat mips=off flags=2


// ============================================================================
// Properties
// ============================================================================

var() string AddressServer;
var() int AddressPort;
var() string AddressChannel;

var() string MessageConnect;
var() string MessageError;
var() string MessageJoin;
var() string MessageLeave;
var() string MessageNickname;
var() string MessageReceiveAction;
var() string MessageReceivePrivate;
var() string MessageReceivePublic;
var() string MessageSendAction;
var() string MessageSendPrivate;
var() string MessageSendPublic;

var() bool SendSay;
var() bool SendSayTeam;
var() bool SendWatching;

var() bool NetworkGameOnly;


// ============================================================================
// Constants
// ============================================================================

const IRC_RPL_ENDOFMOTD         = "376";

const IRC_ERR_NOSUCHSERVER      = "402";
const IRC_ERR_NOSUCHCHANNEL     = "403";
const IRC_ERR_TOOMANYCHANNELS   = "405";
const IRC_ERR_NOORIGIN          = "409";
const IRC_ERR_NOMOTD            = "422";
const IRC_ERR_ERRONEOUSNICKNAME = "432";
const IRC_ERR_NICKNAMEINUSE     = "433";
const IRC_ERR_NICKCOLLISION     = "436";
const IRC_ERR_ALREADYREGISTERED = "462";
const IRC_ERR_CHANNELISFULL     = "471";
const IRC_ERR_INVITEONLYCHAN    = "473";
const IRC_ERR_BANNEDFROMCHAN    = "474";
const IRC_ERR_BADCHANNELKEY     = "475";
const IRC_ERR_BADCHANMASK       = "476";


// ============================================================================
// Variables
// ============================================================================

var PlayerPawn PlayerLocal;

var ScreenTcpLinkChat Link;
var ScreenSlidePageChat PageChannelNext;

var bool FlagDisabled;
var bool FlagDisplayed;
var bool FlagConnected;

var string TextScrollback[64];
var int IndexScrollbackOldest;
var int IndexScrollbackNext;

var string CRLF;


// ============================================================================
// PreBeginPlay
// ============================================================================

simulated event PreBeginPlay() {

  CRLF = Chr(13) $ Chr(10);

  Super.PreBeginPlay();

  if (class 'Screen'.default.Network == ConfigNetwork_Never ||
      (Level.NetMode == NM_Standalone &&
        (NetworkGameOnly || class 'Screen'.default.Network == ConfigNetwork_Network)) ||
      (Level.NetMode == NM_DedicatedServer))
    FlagDisabled = true;
  }


// ============================================================================
// Tick
// ============================================================================

simulated event Tick(float TimeDelta) {

  local LevelInfo LevelEntry;

  FlagDisplayed = false;

  Super.Tick(TimeDelta);

  if (FlagDisabled || Link != None)
    return;

  if (PlayerLocal == None)
    foreach AllActors(class 'PlayerPawn', PlayerLocal)
      if (Viewport(PlayerLocal.Player) != None)
        break;

  if (PlayerLocal == None)
    return;

  LevelEntry = PlayerLocal.GetEntryLevel();

  foreach LevelEntry.AllActors(class 'ScreenTcpLinkChat', Link)
    if (Link.AddressServer == AddressServer &&
        Link.AddressPort   == AddressPort)
      break;

  if (Link == None) {
    Link = LevelEntry.Spawn(class 'ScreenTcpLinkChat');
    Link.AddressServer  = AddressServer;
    Link.AddressPort    = AddressPort;
    Link.AddressChannel = AddressChannel;
    }

  Link.AddChannel(Self);
  }


// ============================================================================
// Draw
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int Left, int Top, float Fade) {

  FlagDisplayed = true;

  Super.Draw(TextureCanvas, Left, Top, Fade);
  }


// ============================================================================
// AddText
//
// Adds text to the slide, potentially purging old text from the buffer.
// ============================================================================

simulated function AddText(string TextAdded) {

  local int IndexScrollback;

  TextScrollback[IndexScrollbackNext] = TextAdded;
  IndexScrollbackNext = (IndexScrollbackNext + 1) % ArrayCount(TextScrollback);

  if (IndexScrollbackNext == IndexScrollbackOldest)
    IndexScrollbackOldest = (IndexScrollbackOldest + 1) % ArrayCount(TextScrollback);

  Text = "";
  for (IndexScrollback = IndexScrollbackOldest;
       IndexScrollback != IndexScrollbackNext;
       IndexScrollback = (IndexScrollback + 1) % ArrayCount(TextScrollback))
    Text = Text $ TextScrollback[IndexScrollback];
  }


// ============================================================================
// ParseResponse
//
// Parses a single line of response from the server.
// ============================================================================

simulated function ParseResponse(string TextNicknameSender, string TextCommand, string TextArguments) {

  local string TextChat;
  local string TextMessage;
  local string TextRecipient;
  local string TextRequest;

  switch (TextCommand) {
    case "JOIN":
      if (Link.ParseToken(TextArguments) ~= AddressChannel) {
        if (TextNicknameSender == Link.TextNickname)
          AddText(Replace(MessageConnect, "%n", Link.TextNickname));
        else
          AddText(Replace(MessageJoin, "%n", TextNicknameSender));
        FlagConnected = true;
        }

      break;
    
    case "PART":
      if (Link.ParseToken(TextArguments) ~= AddressChannel) 
        AddText(Replace(MessageLeave, "%n", TextNicknameSender));
      break;      
    
    case "QUIT":
      AddText(Replace(MessageLeave, "%n", TextNicknameSender));
      break;
    
    case "NICK":
      TextMessage = MessageNickname;
      TextMessage = Replace(TextMessage, "%n", Link.ParseToken(TextArguments));
      TextMessage = Replace(TextMessage, "%o", TextNicknameSender);
      AddText(TextMessage);
      break;
    
    case "PRIVMSG":
      TextRecipient = Link.ParseToken(TextArguments);

      if (FlagConnected && (TextRecipient ~= AddressChannel || TextRecipient ~= Link.TextNickname)) {
        TextChat = Link.ParseToken(TextArguments);
        TextChat = Replace(TextChat, "&", "&amp;");
        TextChat = Replace(TextChat, "<", "&lt;");
        TextChat = Replace(TextChat, ">", "&gt;");

        if (Left(TextChat, 1) == Chr(1)) {
          TextChat = Mid(TextChat, 1);
          if (Right(TextChat, 1) == Chr(1))
            TextChat = Left(TextChat, Len(TextChat) - 1);
          
          TextRequest = Caps(Link.ParseToken(TextChat));
          
          switch (TextRequest) {
            case "ACTION":
              TextMessage = MessageReceiveAction;
              TextMessage = Replace(TextMessage, "%n", TextNicknameSender);
              TextMessage = Replace(TextMessage, "%m", MessageFormat(TextChat));
              AddText(TextMessage);
              break;
            
            case "VERSION":
              if (Link.Page == Self)
                MessageSendCtcpResponse(TextNicknameSender, "VERSION Screen" $ class 'Screen'.default.Version @
                                                            "UT" $ Level.EngineVersion @ "Mychaeel@planetunreal.com");
              break;

            case "PING":
              if (Link.Page == Self)
                MessageSendCtcpResponse(TextNicknameSender, "PING" @ TextChat);
              break;
            
            case "CLIENTINFO":
              if (Link.Page == Self)
                MessageSendCtcpResponse(TextNicknameSender, "CLIENTINFO ACTION VERSION PING CLIENTINFO URL");
              break;
            
            case "URL":
              if (Link.Page == Self)
                MessageSendCtcpResponse(TextNicknameSender, "URL http://www.0x01.net/members/mb/screen/");
              break;
            }
          }
          
        else {
          if (TextRecipient ~= Link.TextNickname)
            TextMessage = MessageReceivePrivate;
          else
            TextMessage = MessageReceivePublic;
  
          TextMessage = Replace(TextMessage, "%n", TextNicknameSender);
          TextMessage = Replace(TextMessage, "%m", MessageFormat(TextChat));
          AddText(TextMessage);
          }
        }
        
      break;

    case IRC_RPL_ENDOFMOTD:
    case IRC_ERR_NOMOTD:
      Link.SendText("JOIN" @ AddressChannel $ CRLF);
      break;

    case IRC_ERR_INVITEONLYCHAN:
    case IRC_ERR_CHANNELISFULL:
    case IRC_ERR_NOSUCHCHANNEL:
    case IRC_ERR_BANNEDFROMCHAN:
    case IRC_ERR_BADCHANNELKEY:
    case IRC_ERR_BADCHANMASK:
    case IRC_ERR_TOOMANYCHANNELS:
      AddText(Replace(MessageError, "%e", TextCommand));
      break;
    }
  }


// ============================================================================
// MessageSend
//
// Sends a message to the chat and parses some client commands.
// ============================================================================

simulated function MessageSend(string TextChat) {

  local string TextCommand;
  local string TextMessage;
  local string TextNicknameRecipient;

  if (!FlagConnected)
    return;

  TextChat = Replace(TextChat, "&", "&amp;");
  TextChat = Replace(TextChat, "<", "&lt;");
  TextChat = Replace(TextChat, ">", "&gt;");

  if (Left(TextChat, 1) == "/") {
    TextCommand = Caps(Link.ParseToken(TextChat));
    
    switch (TextCommand) {
      case "/ME":
        if (Len(TextChat) > 0) {
          MessageSendCtcpQuery(AddressChannel, "ACTION" @ TextChat);
          
          TextMessage = MessageSendAction;
          TextMessage = Replace(TextMessage, "%n", Link.TextNickname);
          TextMessage = Replace(TextMessage, "%m", TextChat);
          AddText(TextMessage);
          }

        break;
      
      case "/MSG":
        TextNicknameRecipient = Link.ParseToken(TextChat);

        if (Len(TextChat) > 0) {
          MessageSendRaw(TextNicknameRecipient, TextChat);
  
          TextMessage = MessageSendPrivate;
          TextMessage = Replace(TextMessage, "%n", TextNicknameRecipient);
          TextMessage = Replace(TextMessage, "%m", TextChat);
          AddText(TextMessage);
          }

        break;
      }
    }
    
  else {
    MessageSendRaw(AddressChannel, TextChat);
    
    TextMessage = MessageSendPublic;
    TextMessage = Replace(TextMessage, "%n", Link.TextNickname);
    TextMessage = Replace(TextMessage, "%m", TextChat);
    AddText(TextMessage);
    }
  }


// ============================================================================
// MessageSendRaw
//
// Sends a message to a given recipient without parsing.
// ============================================================================

simulated function MessageSendRaw(string TextNicknameRecipient, string TextChat) {

  Link.SendText("PRIVMSG" @ TextNicknameRecipient @ ":" $ TextChat $ CRLF);
  }


// ============================================================================
// MessageSendCtcpQuery
//
// Sends a ctcp query to another user.
// ============================================================================

simulated function MessageSendCtcpQuery(string TextNicknameRecipient, string TextQuery) {

  Link.SendText("PRIVMSG" @ TextNicknameRecipient @ ":" $ Chr(1) $ TextQuery $ Chr(1) $ CRLF);
  }


// ============================================================================
// MessageSendCtcpResponse
//
// Sends a ctcp query to another user.
// ============================================================================

simulated function MessageSendCtcpResponse(string TextNicknameRecipient, string TextResponse) {

  Link.SendText("NOTICE" @ TextNicknameRecipient @ ":" $ Chr(1) $ TextResponse $ Chr(1) $ CRLF);
  }


// ============================================================================
// MessageFormat
//
// Converts color and formatting codes to formatting tags and returns the
// result.
// ============================================================================

simulated function string MessageFormat(string TextMessage) {

  local bool FlagFormatBold;
  local bool FlagFormatUnderline;
  local bool FlagTagClose;
  local int CountTagStack;
  local int IndexChar;
  local int IndexTagStack;
  local string CharMessage;
  local string TextColor;
  local string TextFormatted;
  local string TextTag;
  local string TextTagArguments;
  local string TextTagStack[3];
  local string TextTagStackComplete[3];
  
  TextMessage = TextMessage $ Chr(0x0f);
  
  for (IndexChar = 0; IndexChar < Len(TextMessage); IndexChar++) {
    CharMessage = Mid(TextMessage, IndexChar, 1);

    switch (Asc(CharMessage)) {
      case 0x02:
        FlagTagClose = FlagFormatBold;
        FlagFormatBold = !FlagFormatBold;
        TextTag = "b";
        break;
    
      case 0x1f:
        FlagTagClose = FlagFormatUnderline;
        FlagFormatUnderline = !FlagFormatUnderline;
        TextTag = "u";
        break;
 
      case 0x03:
        CharMessage = Mid(TextMessage, IndexChar + 1, 1);
        if (CharMessage >= "0" && CharMessage <= "9") {
          TextColor = CharMessage;

          if (CharMessage == "1") {
            CharMessage = Mid(TextMessage, IndexChar + 2, 1);
            if (CharMessage >= "0" && CharMessage <= "5")
              TextColor = TextColor $ CharMessage;
            }

          IndexChar += Len(TextColor);
          
          switch (TextColor) {
            case  "0": TextColor = "white";   break;
            case  "1": TextColor = "black";   break;
            case  "2": TextColor = "navy";    break;
            case  "3": TextColor = "green";   break;
            case  "4": TextColor = "red";     break;
            case  "5": TextColor = "maroon";  break;
            case  "6": TextColor = "purple";  break;
            case  "7": TextColor = "#ff8000"; break;
            case  "8": TextColor = "yellow";  break;
            case  "9": TextColor = "green";   break;
            case "10": TextColor = "teal";    break;
            case "11": TextColor = "aqua";    break;
            case "12": TextColor = "blue";    break;
            case "13": TextColor = "fuchsia"; break;
            case "14": TextColor = "gray";    break;
            case "15": TextColor = "silver";  break;
            }

          TextTag = "font";
          TextTagArguments = "color=" $ TextColor;
          }

        break;
      
      case 0x0f:
        for (IndexTagStack = CountTagStack - 1; IndexTagStack >= 0; IndexTagStack--)
          TextFormatted = TextFormatted $ "</" $ TextTagStack[IndexTagStack] $ ">";
        CountTagStack = 0;
        
        FlagFormatBold      = false;
        FlagFormatUnderline = false;
        break;
     
      default:
        TextFormatted = TextFormatted $ CharMessage;
        break;
      }

    if (Len(TextTag) > 0) {
      if (FlagTagClose) {
        for (IndexTagStack = CountTagStack - 1;
             IndexTagStack >= 0 && TextTagStack[IndexTagStack] != TextTag;
             IndexTagStack--)
          TextFormatted = TextFormatted $ "</" $ TextTagStack[IndexTagStack] $ ">";

        TextFormatted = TextFormatted $ "</" $ TextTagStack[IndexTagStack] $ ">";

        for (IndexTagStack = IndexTagStack; IndexTagStack < CountTagStack - 1; IndexTagStack++) {
          TextTagStack        [IndexTagStack] = TextTagStack        [IndexTagStack + 1];
          TextTagStackComplete[IndexTagStack] = TextTagStackComplete[IndexTagStack + 1];
          TextFormatted = TextFormatted $ "<" $ TextTagStackComplete[IndexTagStack] $ ">";
          }

        CountTagStack--;
        }
        
      else {
        for (IndexTagStack = CountTagStack - 1;
             IndexTagStack >= 0 && TextTagStack[IndexTagStack] != TextTag;
             IndexTagStack--);
        
        if (IndexTagStack < 0) {
          TextTagStack[CountTagStack] = TextTag;
          if (Len(TextTagArguments) > 0)
            TextTagStackComplete[CountTagStack] = TextTag @ TextTagArguments;
          else
            TextTagStackComplete[CountTagStack] = TextTag;
          TextFormatted = TextFormatted $ "<" $ TextTagStackComplete[CountTagStack] $ ">";
          CountTagStack++;
          }
        
        else {
          for (IndexTagStack = CountTagStack - 1;
               IndexTagStack >= 0 && TextTagStack[IndexTagStack] != TextTag;
               IndexTagStack--)
            TextFormatted = TextFormatted $ "</" $ TextTagStack[IndexTagStack] $ ">";

          TextFormatted = TextFormatted $ "</" $ TextTagStack[IndexTagStack] $ ">";

          TextTagStack[IndexTagStack] = TextTag;
          if (Len(TextTagArguments) > 0)
            TextTagStackComplete[IndexTagStack] = TextTag @ TextTagArguments;
          else
            TextTagStackComplete[IndexTagStack] = TextTag;

          for (IndexTagStack = IndexTagStack; IndexTagStack < CountTagStack; IndexTagStack++)
            TextFormatted = TextFormatted $ "<" $ TextTagStackComplete[IndexTagStack] $ ">";
          }
        }

      FlagTagClose = false;
      TextTag          = "";
      TextTagArguments = "";
      }
    }
  
  return TextFormatted;
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    AddressServer="irc.enterthegame.com"
    AddressPort=6667
    AddressChannel="#screen"
    MessageConnect="<font color=green>*** Your nickname is now %n</font><br>"
    MessageError="<font color=blue>*** Unable to join (error code %e)</font><br>"
    MessageJoin="<font color=green>*** %n has joined</font><br>"
    MessageLeave="<font color=green>*** %n has left</font><br>"
    MessageNickname="<font color=green>*** %o is now known as %n</font><br>"
    MessageReceiveAction="<font color=purple>* %n %m</font><br>"
    MessageReceivePrivate="&lt;&lt; *%n* %m<br>"
    MessageReceivePublic="&lt;%n&gt; %m<br>"
    MessageSendAction="<font color=purple>* %n %m</font><br>"
    MessageSendPrivate="&gt;&gt; *%n* %m<br>"
    MessageSendPublic="&lt;%n&gt; %m<br>"
    SendSay=True
    SendWatching=True
    NetworkGameOnly=True
    Text="<p align=center><font color=gray>[No Server Link Established]</font></p>"
    AlignVert=2
    ScrollVert=0
    bAlwaysTick=True
    RemoteRole=2
    Texture=Texture'ActorSlidePageChat'
}
