// ============================================================================
// ScreenSlidePage
// Copyright 2001 by Mychaeel <mychaeel@planetunreal.com>
//
// Implements a ScreenSlide that can be used to display arbitary formatted
// text and other items on a Ai
// ============================================================================


class ScreenSlidePage extends ScreenSlide;


// ============================================================================
// Compiler Directives
// ============================================================================

#exec texture import file=Textures\ActorSlidePage.bmp mips=off flags=2

//#exec obj load file=Textures\ScreenFonts.utx package=ScreenFonts

#exec Font Import File=Textures\Tahoma10.pcx Name=FontNormal
#exec Font Import File=Textures\TahomaB10.pcx Name=FontNormalBond


// ============================================================================
// Replication
// ============================================================================

replication {

  reliable if (Role == ROLE_Authority)
    Text, TextCaps;
  }


// ============================================================================
// Types
// ============================================================================

enum EnumTextAlign {
  TextAlign_Left,
  TextAlign_Center,
  TextAlign_Right,
  };

struct StructTextFormat {
  var string Tag;
  var Font FontText;
  var Color ColorText;
  var EnumTextAlign AlignText;
  var bool FlagUnderline;
  };


// ============================================================================
// Properties
// ============================================================================

var() string Text;
var() bool TextCaps;
var() bool TextPlaceholders;

var() Font FontNormal;
var() Font FontNormalBold;
var() Font FontBig;
var() Font FontBigBold;
var() Font FontHeading;

var() Color FontNormalColor;
var() Color FontHeadingColor;


// ============================================================================
// Variables
// ============================================================================

var string TextCached;
var ScreenSlidePageItem ItemFirst;
var PlayerPawn PlayerLocal;
var float TimeUpdate;


// ============================================================================
// Prepare
// ============================================================================

simulated function Prepare(ScriptedTexture TextureCanvas) {

  local string TextResult;

  if (TimeUpdate > 0.0 && Level.TimeSeconds - TimeUpdate < 0.1)
    return;
  TimeUpdate = Level.TimeSeconds;

  if (TextPlaceholders)
    TextResult = Placeholders(Text);
  else
    TextResult = Text;

  if (TextResult != TextCached) {
    ItemFirst = Render(TextureCanvas, TextResult, ClientWidth, ClientHeight);
    TextCached = TextResult;
    }
  }


// ============================================================================
// Placeholders
//
// Replaces all placeholders in the text by their values.
// ============================================================================

simulated function string Placeholders(string TextOriginal) {

  local GameReplicationInfo InfoGame;
  local PlayerReplicationInfo InfoPlayerLeading;
  local PlayerReplicationInfo InfoPlayerLocal;
  local PlayerReplicationInfo ThisInfo;
  local int IndexInfo;

  if (PlayerLocal == None)
    foreach AllActors(class 'PlayerPawn', PlayerLocal)
      if (Viewport(PlayerLocal.Player) != None)
        break;

  InfoGame = PlayerLocal.GameReplicationInfo;

  if (InfoGame == None) {
    PlaceholdersPlayer(TextOriginal, "",  None);
    PlaceholdersPlayer(TextOriginal, "l", None);
    return TextOriginal;
    }

  InfoPlayerLocal = PlayerLocal.PlayerReplicationInfo;

  for (IndexInfo = 0; IndexInfo < ArrayCount(InfoGame.PRIArray); IndexInfo++) {
    ThisInfo = InfoGame.PRIArray[IndexInfo];
    if (ThisInfo == None)
      break;

    if (ThisInfo.bIsSpectator && !ThisInfo.bWaitingPlayer)
      continue;

    if (InfoPlayerLeading == None ||
        ThisInfo.Score >  InfoPlayerLeading.Score ||
       (ThisInfo.Score == InfoPlayerLeading.Score &&
         (ThisInfo.Deaths <  InfoPlayerLeading.Deaths ||
         (ThisInfo.Deaths == InfoPlayerLeading.Deaths &&
           (ThisInfo.PlayerID < InfoPlayerLeading.PlayerID)))))
      InfoPlayerLeading = ThisInfo;
    }

  if (InfoPlayerLocal == None || InfoPlayerLeading == None) {
    PlaceholdersPlayer(TextOriginal, "",  None);
    PlaceholdersPlayer(TextOriginal, "l", None);
    }

  else {
    PlaceholdersPlayer(TextOriginal, "",  InfoPlayerLocal);
    PlaceholdersPlayer(TextOriginal, "l", InfoPlayerLeading);
    }

  return TextOriginal;
  }


// ============================================================================
// PlaceholdersPlayer
//
// Replaces some player-specific placeholders given this player's current info.
// ============================================================================

simulated function PlaceholdersPlayer(out string TextOriginal, string TextPrefix, PlayerReplicationInfo Info) {

  local int TimePlaying;

  if (Info == None) {
    TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "p", "?");
    TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "s", "?");
    TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "t", "?");
    TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "d", "?");
    TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "i", "MyLevel.UnknownPlayerIcon");
    TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "c", PlaceholdersTeam(255));

    return;
    }

  TimePlaying = (Level.TimeSeconds + PlayerLocal.PlayerReplicationInfo.StartTime - Info.StartTime) / 60;

  TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "p", Info.PlayerName);
  TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "s", int(Info.Score));
  TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "t", TimePlaying);
  TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "d", int(Info.Deaths));
  TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "i", Info.TalkTexture);
  TextOriginal = Replace(TextOriginal, "%" $ TextPrefix $ "c", PlaceholdersTeam(Info.Team));
  }



// ============================================================================
// PlaceholdersTeam
//
// Returns a string describing the given team color.
// ============================================================================

simulated function string PlaceholdersTeam(int IndexTeam) {

  switch (IndexTeam) {
    case 0: return "red";
    case 1: return "blue";
    case 2: return "green";
    case 3: return "yellow";
    }

  return "gray";
  }


// ============================================================================
// Draw
// ============================================================================

simulated function Draw(ScriptedTexture TextureCanvas, int Left, int Top, float Fade) {

  local ScreenSlidePageItem ThisItem;

  for (ThisItem = ItemFirst; ThisItem != None; ThisItem = ThisItem.ItemNext) {
    if (Top  + ThisItem.Top  + ThisItem.Height <= 0 ||
        Left + ThisItem.Left + ThisItem.Width  <= 0 ||
        Left + ThisItem.Left > TextureCanvas.USize)
      continue;

    if (Top + ThisItem.Top > TextureCanvas.VSize)
      break;

    ThisItem.Draw(TextureCanvas, Left, Top, Fade);
    }
  }


// ============================================================================
// Render
//
// Simple html renderer that supports the following tags. Produces a linked
// list of ScreenSlidePageItem objects and returns the first of them.
//
//   <body text=>          Default colors for text
//   <h# align=>           Paragraph with large font and alignment
//   <p align=>            New paragraph with alignment
//   <br>                  New line
//   <img src=>            Displays a texture as an image
//   <font color= size=>   Sets font color and size
//   <big> <small>         Sets font size
//   <b>                   Sets boldfaced font
//
// All other tags are skipped and ignored, so this parser should in theory be
// able to take any existing web page. I don't make any claims about how that
// will look, though.
// ============================================================================

simulated function ScreenSlidePageItem Render(ScriptedTexture TextureCanvas, string Text, int Width, out int Height) {

  local ScreenSlidePageItem ItemFirst;
  local ScreenSlidePageItem ItemLast;
  local ScreenSlidePageItem ItemNew;
  local ScreenSlidePageItem ItemCurrent;
  local ScreenSlidePageItem ItemLinestart;

  local EnumTextAlign AlignPrev;
  local StructTextFormat Format[32];
  local Texture ImageNew;
  local int CountItems;
  local int IndexFormat;
  local int IndexFormatCurrent;
  local int IndexChar;
  local int IndexCharStart;
  local int IndexCharSeparator;
  local int IndexParameter;
  local int HeightLine;
  local int HeightPadding;
  local int WidthLine;
  local int WidthIndent;
  local int WidthMax;
  local int LengthText;
  local int PositionLeft;
  local int PositionTop;
  local int ValueParameter;
  local string CharPrev;
  local string CharCurrent;
  local string TagText;
  local string TagName;
  local string TagArguments;
  local string TextArgument;
  local string TextParameters;
  local string TextChunk;
  local string TextNormalized;
  local string TextPackage;
  local bool FlagLinebreakDone;
  local bool FlagLinebreakBefore;
  local bool FlagLinebreakAfter;
  local bool FlagTruncate;
  local bool FlagTrim;
  local bool FlagWhitespace;
  local bool FlagWhitespacePrev;


  // ================================================================
  // Initialization
  // ================================================================

  Format[0].Tag       = "";
  Format[0].FontText  = FontNormal;
  Format[0].ColorText = FontNormalColor;
  Format[0].AlignText = TextAlign_Left;

  TextPackage = Level.GetLocalURL();
  TextPackage = Left(TextPackage, InStr(TextPackage $ "?", "?"));
  TextPackage = Mid (TextPackage, InStr(TextPackage,  "/") + 1);


  // ================================================================
  // Normalize
  // ================================================================

  IndexCharStart = 0;
  FlagWhitespace = true;

  for (IndexChar = 0; IndexChar < Len(Text); IndexChar++) {
    CharCurrent = Mid(Text, IndexChar, 1);

    FlagWhitespacePrev = FlagWhitespace;
    FlagWhitespace = (CharCurrent == Chr(10) || CharCurrent == Chr(13) || CharCurrent == " ");

    if (FlagWhitespace && !FlagWhitespacePrev)
      TextNormalized = TextNormalized $ Mid(Text, IndexCharStart, IndexChar - IndexCharStart) $ " ";
    else if (!FlagWhitespace && FlagWhitespacePrev)
      IndexCharStart = IndexChar;
    }

  if (!FlagWhitespace)
    TextNormalized = TextNormalized $ Mid(Text, IndexCharStart);

  Text = TextNormalized;


  // ================================================================
  // Tokenize and Interpret
  // ================================================================

  CountItems = 0;

  FlagTrim = true;
  FlagLinebreakDone = false;
  FlagLinebreakBefore = false;

  while (Len(Text) > 0 || !FlagLinebreakDone) {

    ItemNew = None;
    FlagLinebreakAfter = false;


    // ====================================================
    // Tag
    // ====================================================

    AlignPrev = Format[IndexFormatCurrent].AlignText;

    if (Left(Text, 1) == "<") {
      IndexChar = InStr(Text, ">");
      if (IndexChar < 0) break;

      TagText = Mid(Text, 1, IndexChar - 1);
      Text = Mid(Text, IndexChar + 1);

      IndexChar = InStr(TagText $ " ", " ");
      TagName = Caps(Left(TagText, IndexChar));
      TagArguments = Mid(TagText, IndexChar + 1);

      if (Left(TagName, 1) == "/") {
        TagName = Mid(TagName, 1);

        switch (TagName) {
          case "BODY":
            FlagTrim = true;
            FlagLinebreakBefore = true;
            break;

          case "H1":
          case "H2":
          case "H3":
          case "H4":
          case "H5":
          case "H6":
          case "P":
            FlagTrim = true;
            FlagLinebreakBefore = true;
            HeightPadding = Max(HeightPadding, TextHeight(TextureCanvas, "X", Format[IndexFormatCurrent].FontText));
            break;

          case "FONT":
          case "BIG":
          case "SMALL":
          case "B":
          case "U":
            FlagTrim = false;
            break;
          }

        for (IndexFormat = IndexFormatCurrent; IndexFormat > 0; IndexFormat--)
          if (Format[IndexFormat].Tag == TagName) {
            IndexFormatCurrent = IndexFormat - 1;
            break;
            }
        }

      else {
        switch (TagName) {
          case "BODY":
            IndexFormatCurrent = 0;
            Format[0].Tag           = TagName;
            Format[0].FontText      = FontNormal;
            Format[0].ColorText     = ArgumentColor(Argument(TagArguments, "text"), FontNormalColor);
            Format[0].AlignText     = TextAlign_Left;
            Format[0].FlagUnderline = false;

            FlagTrim = true;
            FlagLinebreakBefore = true;
            break;

          case "H1":
          case "H2":
          case "H3":
          case "H4":
          case "H5":
          case "H6":
            IndexFormatCurrent++;
            Format[IndexFormatCurrent] = Format[IndexFormatCurrent - 1];
            Format[IndexFormatCurrent].Tag       = TagName;
            Format[IndexFormatCurrent].FontText  = FontHeading;
            Format[IndexFormatCurrent].ColorText = FontHeadingColor;
            Format[IndexFormatCurrent].AlignText = ArgumentAlign(Argument(TagArguments, "align"), TextAlign_Left);

            FlagTrim = true;
            FlagLinebreakBefore = true;
            if (ItemFirst != None)
              HeightPadding = Max(HeightPadding, TextHeight(TextureCanvas, "X", Format[IndexFormatCurrent].FontText));
            break;

          case "P":
            for (IndexFormat = IndexFormatCurrent; IndexFormat > 0; IndexFormat--)
              if (Format[IndexFormat].Tag == "P") {
                IndexFormatCurrent = IndexFormat - 1;
                break;
                }

            FlagTrim = true;
            FlagLinebreakBefore = true;
            if (ItemFirst != None)
              HeightPadding = Max(HeightPadding, TextHeight(TextureCanvas, "X", Format[IndexFormatCurrent].FontText));

            IndexFormatCurrent++;
            Format[IndexFormatCurrent] = Format[0];
            Format[IndexFormatCurrent].Tag       = TagName;
            Format[IndexFormatCurrent].AlignText = ArgumentAlign(Argument(TagArguments, "align"), TextAlign_Left);
            break;

          case "BR":
            if (PositionLeft == 0)
              HeightPadding += TextHeight(TextureCanvas, "X", Format[IndexFormatCurrent].FontText);
            FlagTrim = true;
            FlagLinebreakBefore = true;
            break;

          case "IMG":
            TextArgument = Argument(TagArguments, "src");

            IndexCharSeparator = InStr(TextArgument, "?");
            if (IndexCharSeparator < 0)
              IndexCharSeparator = Len(TextArgument);
            TextParameters = Mid (TextArgument, IndexCharSeparator + 1);
            TextArgument   = Left(TextArgument, IndexCharSeparator);

            if (Caps(Left(TextArgument, 8)) == "MYLEVEL.")
              TextArgument = TextPackage $ "." $ Mid(TextArgument, 8);

            ImageNew = Texture(DynamicLoadObject(TextArgument, class 'Texture'));

            if (ImageNew != None) {
              ItemNew = new class 'ScreenSlidePageItemImage';

              ScreenSlidePageItemImage(ItemNew).Image = ImageNew;
              ScreenSlidePageItemImage(ItemNew).ClipTop    = 0;
              ScreenSlidePageItemImage(ItemNew).ClipLeft   = 0;
              ScreenSlidePageItemImage(ItemNew).ClipWidth  = ImageNew.USize;
              ScreenSlidePageItemImage(ItemNew).ClipHeight = ImageNew.VSize;

              for (IndexParameter = 0; IndexParameter < 4; IndexParameter++) {
                IndexCharSeparator = InStr(TextParameters, ",");
                if (IndexCharSeparator < 0)
                  IndexCharSeparator = Len(TextParameters);
                if (IndexCharSeparator == 0)
                  continue;

                ValueParameter = int(Left(TextParameters, IndexCharSeparator));

                switch (IndexParameter) {
                  case 0: ScreenSlidePageItemImage(ItemNew).ClipWidth  = ValueParameter; break;
                  case 1: ScreenSlidePageItemImage(ItemNew).ClipHeight = ValueParameter; break;
                  case 2: ScreenSlidePageItemImage(ItemNew).ClipLeft   = ValueParameter; break;
                  case 3: ScreenSlidePageItemImage(ItemNew).ClipTop    = ValueParameter; break;
                  }

                TextParameters = Mid(TextParameters, IndexCharSeparator + 1);
                if (Len(TextParameters) == 0)
                  break;
                }

              ItemNew.Width  = ArgumentNumber(Argument(TagArguments, "width"),  ScreenSlidePageItemImage(ItemNew).ClipWidth);
              ItemNew.Height = ArgumentNumber(Argument(TagArguments, "height"), ScreenSlidePageItemImage(ItemNew).ClipHeight);

              if (PositionLeft + ItemNew.Width >= Width)
                FlagLinebreakBefore = true;
              ItemNew.Top = -ItemNew.Height;
              }

            break;

          case "FONT":
            FlagTrim = true;
            IndexFormatCurrent++;
            Format[IndexFormatCurrent] = Format[IndexFormatCurrent - 1];
            Format[IndexFormatCurrent].Tag       = TagName;
            Format[IndexFormatCurrent].FontText  = ArgumentFont (Argument(TagArguments, "size"),  Format[IndexFormatCurrent - 1].FontText);
            Format[IndexFormatCurrent].ColorText = ArgumentColor(Argument(TagArguments, "color"), Format[IndexFormatCurrent - 1].ColorText);
            break;

          case "BIG":
            FlagTrim = true;
            IndexFormatCurrent++;
            Format[IndexFormatCurrent] = Format[IndexFormatCurrent - 1];
            Format[IndexFormatCurrent].Tag      = TagName;
            Format[IndexFormatCurrent].FontText = FontBig;
            break;

          case "SMALL":
            FlagTrim = true;
            IndexFormatCurrent++;
            Format[IndexFormatCurrent] = Format[IndexFormatCurrent - 1];
            Format[IndexFormatCurrent].Tag      = TagName;
            Format[IndexFormatCurrent].FontText = FontNormal;
            break;

          case "B":
            FlagTrim = true;
            IndexFormatCurrent++;
            Format[IndexFormatCurrent] = Format[IndexFormatCurrent - 1];
            Format[IndexFormatCurrent].Tag = TagName;

            switch (Format[IndexFormatCurrent - 1].FontText) {
              case FontNormal: Format[IndexFormatCurrent].FontText = FontNormalBold; break;
              case FontBig:    Format[IndexFormatCurrent].FontText = FontBigBold;    break;
              }

            break;

          case "U":
            FlagTrim = true;
            IndexFormatCurrent++;
            Format[IndexFormatCurrent] = Format[IndexFormatCurrent - 1];
            Format[IndexFormatCurrent].Tag           = TagName;
            Format[IndexFormatCurrent].FlagUnderline = true;
            break;
          }
        }
      }


    // ====================================================
    // Text
    // ====================================================

    else if (Len(Text) > 0) {
      if (FlagTrim)
        while (Left(Text, 1) == " ")
          Text = Mid(Text, 1);
      FlagTrim = false;

      IndexChar = InStr(Text, "<");
      if (IndexChar < 0)
        IndexChar = Len(Text);

      TextChunk = Left(Text, IndexChar);
      if (TextCaps)
        TextChunk = Caps(TextChunk);

      if (Len(TextChunk) > 0) {
        ItemNew = new class 'ScreenSlidePageItemText';

        FlagTruncate = (PositionLeft == 0);
        while (true) {
          if (FlagLinebreakBefore)
            while (Left(TextChunk, 1) == " ")
              TextChunk = Mid(TextChunk, 1);

          ItemNew.Width = Width - PositionLeft;

          ScreenSlidePageItemText(ItemNew).Text =
            Wrap(TextureCanvas, TextChunk, ItemNew.Width, Format[IndexFormatCurrent].FontText, FlagTruncate, WidthMax);
          ScreenSlidePageItemText(ItemNew).FontText      = Format[IndexFormatCurrent].FontText;
          ScreenSlidePageItemText(ItemNew).ColorText     = Format[IndexFormatCurrent].ColorText;
          ScreenSlidePageItemText(ItemNew).FlagUnderline = Format[IndexFormatCurrent].FlagUnderline;

          if (FlagTruncate || ItemNew.Width > 0) break;

          FlagTruncate = true;
          PositionLeft = 0;
          FlagLinebreakBefore = true;
          }

        FlagLinebreakAfter = (WidthMax >= Width - PositionLeft);

        ItemNew.Height = TextHeight(TextureCanvas, "X", Format[IndexFormatCurrent].FontText);
        ItemNew.Top = -ItemNew.Height;

        Text = Mid(Text, IndexChar - Len(TextChunk));
        }
      }


    // ====================================================
    // Place New Item
    // ====================================================

    if (FlagLinebreakBefore && !FlagLinebreakDone) {
      if (ItemLast != None && ItemLast.IsA('ScreenSlidePageItemText')) {
        for (LengthText = Len(ScreenSlidePageItemText(ItemLast).Text); LengthText > 0; LengthText--)
          if (Mid(ScreenSlidePageItemText(ItemLast).Text, LengthText - 1, 1) != " ")
            break;

        WidthLine -= ItemLast.Width - TextWidth(TextureCanvas,
          Left(ScreenSlidePageItemText(ItemLast).Text, LengthText), ScreenSlidePageItemText(ItemLast).FontText);
        }

      switch (AlignPrev) {
        case TextAlign_Left:   WidthIndent = 0; break;
        case TextAlign_Center: WidthIndent = (Width - WidthLine) / 2; break;
        case TextAlign_Right:  WidthIndent = Width - WidthLine; break;
        }

      for (ItemCurrent = ItemLinestart; ItemCurrent != None; ItemCurrent = ItemCurrent.ItemNext) {
        ItemCurrent.Top += PositionTop + HeightLine;
        ItemCurrent.Left += WidthIndent;
        ItemCurrent.Prepare(TextureCanvas);
        }

      PositionLeft = 0;
      PositionTop += HeightLine;
      HeightLine = 0;
      WidthLine = 0;

      FlagLinebreakDone = true;
      }

    if (ItemNew != None) {
      CountItems++;

      if (FlagLinebreakBefore) {
        PositionTop += HeightPadding;
        HeightPadding = 0;
        ItemLinestart = ItemNew;
        }

      ItemNew.Left = PositionLeft;
      ItemNew.ColorBase = BackgroundColor;

      WidthLine += ItemNew.Width;
      PositionLeft += ItemNew.Width;
      HeightLine = Max(HeightLine, -ItemNew.Top);

      if (ItemLast == None)
        ItemFirst = ItemNew;
      else
        ItemLast.ItemNext = ItemNew;

      if (ItemLinestart == None)
        ItemLinestart = ItemNew;
      ItemLast = ItemNew;

      FlagLinebreakDone = false;
      FlagLinebreakBefore = FlagLinebreakAfter;
      }

    if (Len(Text) == 0 && !FlagLinebreakDone) {
      FlagLinebreakBefore = true;
      FlagLinebreakDone = false;
      }
    }

  Log("Rendered slide" @ Name $ "," @ CountItems @ "items");

  Height = PositionTop + HeightLine;
  return ItemFirst;
  }


// ============================================================================
// InStrFrom
//
// Same as the built-in InStr function, except for the addition of a parameter
// that specifies the start position of the search. Should, actually, be
// readily available in any decent scripting language.
// ============================================================================

simulated function int InStrFrom(int Start, string Haystack, string Needle) {

  local int IndexChar;

  IndexChar = InStr(Mid(Haystack, Start), Needle);

  if (IndexChar < 0)
    return IndexChar;

  return IndexChar + Start;
  }


// ============================================================================
// Wrap
//
// Calculates and returns the substring of characters in the given string that
// fits into the given width, wrapping only at whitespace characters. Removes
// the substring and all trailing whitespace from the Text argument and returns
// the wrapped text chunk's actual width in the Width argument.
// ============================================================================

simulated function string Wrap(ScriptedTexture TextureCanvas, out string Text, out int Width, Font FontText,
                               bool Truncate, out int WidthMax) {

  local string CharPrev;
  local string CharCurrent;
  local int LengthWrap;
  local int LengthCurrent;
  local int WidthWrap;
  local int WidthCurrent;
  local string TextCurrent;
  local string TextResult;

  TextCurrent = Text;

  for (LengthCurrent = 1; LengthCurrent <= Len(Text); LengthCurrent++) {
    CharPrev = CharCurrent;
    CharCurrent = Mid(Text, LengthCurrent, 1);

    TextCurrent = Entity(TextCurrent, LengthCurrent - 1);
    WidthCurrent = TextWidth(TextureCanvas, Left(TextCurrent, LengthCurrent), FontText);

    if (WidthCurrent > Width && (!Truncate || LengthWrap > 0))
      break;

    if ((CharCurrent == " " && CharPrev != " ") || LengthCurrent == Len(Text)) {
      LengthWrap = LengthCurrent;
      Text = TextCurrent;
      }
    }

  for (LengthWrap = LengthWrap; LengthWrap < Len(Text); LengthWrap++)
    if (Mid(Text, LengthWrap, 1) != " ")
      break;

  TextResult = Left(Text, LengthWrap);
  Text = Mid(Text, LengthWrap);

  Width = TextWidth(TextureCanvas, TextResult, FontText);
  WidthMax = WidthCurrent;

  return TextResult;
  }


// ============================================================================
// TextWidth
//
// Returns the pixel width of a chunk of text in the given font.
// ============================================================================

simulated function int TextWidth(ScriptedTexture TextureCanvas, string Text, Font FontText) {

  local float WidthText;
  local float HeightText;

  TextureCanvas.TextSize(Text, WidthText, HeightText, FontText);

  return WidthText;
  }


// ============================================================================
// TextHeight
//
// Returns the pixel width of a chunk of text in the given font.
// ============================================================================

simulated function int TextHeight(ScriptedTexture TextureCanvas, string Text, Font FontText) {

  local float WidthText;
  local float HeightText;

  TextureCanvas.TextSize(Text, WidthText, HeightText, FontText);

  return HeightText;
  }


// ============================================================================
// Entity
//
// Returns a string that represents the given string with the entity at the
// given position replaced by its corresponding character.
// ============================================================================

simulated function string Entity(string Text, optional int Index) {

  local string TextEntity;
  local string TextCharacter;
  local int IndexChar;

  if (Mid(Text, Index, 1) != "&")
    return Text;

  for (IndexChar = Index + 1; IndexChar < Index + 8; IndexChar++)
    if (Mid(Text, IndexChar, 1) == ";") {
      TextEntity = Mid(Text, Index, IndexChar - Index + 1);
      break;
      }

  if (Len(TextEntity) == 0)
    return Text;

  switch (TextEntity) {
    case "&nbsp;":  TextCharacter = " ";  break;
    case "&quot;":  TextCharacter = "\""; break;
    case "&lt;":    TextCharacter = "<";  break;
    case "&gt;":    TextCharacter = ">";  break;
    case "&amp;":   TextCharacter = "&";  break;

    case "&auml;":  TextCharacter = "ä";  break;
    case "&ouml;":  TextCharacter = "ö";  break;
    case "&uuml;":  TextCharacter = "ü";  break;
    case "&Auml;":  TextCharacter = "Ä";  break;
    case "&Ouml;":  TextCharacter = "Ö";  break;
    case "&Uuml;":  TextCharacter = "Ü";  break;
    case "&szlig;": TextCharacter = "ß";  break;

    default: TextCharacter = TextEntity;
    }

  return Left(Text, Index) $ TextCharacter $ Mid(Text, Index + Len(TextEntity));
  }


// ============================================================================
// Entities
//
// Replaces some generic entities by their corresponding characters.
// ============================================================================

simulated function string Entities(string Text) {

  local int IndexChar;
  local int LengthMax;
  local int LengthPrev;

  for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
    Text = Entity(Text, IndexChar);

  return Text;
  }


// ============================================================================
// Argument
//
// Extracts an argument from an html tag's argument list and returns that
// argument's string value. Returns an empty string if no matching argument is
// found.
// ============================================================================

simulated function string Argument(string ArgumentList, string ArgumentName) {

  local int IndexChar;
  local string CharPrev;
  local string CharCurrent;
  local string CharQuote;
  local bool FlagQuoted;
  local string ArgumentText;

  FlagQuoted = false;
  ArgumentName = Caps(ArgumentName) $ "=";

  for (IndexChar = 0; IndexChar < Len(ArgumentList); IndexChar++) {
    CharPrev = CharCurrent;
    CharCurrent = Mid(ArgumentList, IndexChar, 1);

    if ((CharCurrent == "\"" || CharCurrent == "'") && (!FlagQuoted || CharQuote == CharCurrent)) {
      FlagQuoted = !FlagQuoted;
      CharQuote = CharCurrent;
      continue;
      }

    if (FlagQuoted)
      continue;

    if ((CharPrev == "" || CharPrev == " ") &&
        Caps(Mid(ArgumentList, IndexChar, Len(ArgumentName))) == ArgumentName) {

      ArgumentText = Mid(ArgumentList, IndexChar + Len(ArgumentName));

      CharQuote = Left(ArgumentText, 1);
      if (CharQuote == "\"" || CharQuote == "'")
        ArgumentText = Mid(ArgumentText, 1, InStr(Mid(ArgumentText, 1) $ CharQuote, CharQuote));
      else
        ArgumentText = Left(ArgumentText, InStr(ArgumentText $ " ", " "));

      break;
      }
    }

  return Entities(ArgumentText);
  }


// ============================================================================
// ArgumentNumber
//
// Converts an argument into a number and returns this value. Returns the
// given default number if the argument is invalid.
// ============================================================================

simulated function int ArgumentNumber(string ArgumentText, int NumberDefault) {

  local int NumberResult;

  NumberResult = int(ArgumentText);

  if (string(NumberResult) == ArgumentText)
    return NumberResult;
  else
    return NumberDefault;
  }


// ============================================================================
// ArgumentAlign
//
// Converts an argument into a text alignment value and returns this value.
// Returns the given default alignment if the argument is invalid.
// ============================================================================

simulated function EnumTextAlign ArgumentAlign(string ArgumentText, EnumTextAlign AlignDefault) {

  switch (Caps(ArgumentText)) {
    case "LEFT":   return TextAlign_Left;
    case "CENTER": return TextAlign_Center;
    case "RIGHT":  return TextAlign_Right;

    default: return AlignDefault;
    }
  }


// ============================================================================
// ArgumentColor
//
// Converts an argument into a Color value and returns that value. Returns the
// given default color if the argument didn't represent a valid color.
// ============================================================================

simulated function Color ArgumentColor(string ArgumentText, Color ColorDefault) {

  local Color ColorResult;

  if (Left(ArgumentText, 1) == "#") {
    ColorResult.R = Hex(Mid(ArgumentText, 1, 2));
    ColorResult.G = Hex(Mid(ArgumentText, 3, 2));
    ColorResult.B = Hex(Mid(ArgumentText, 5, 2));

    if (ColorResult.R < 0 || ColorResult.G < 0 || ColorResult.B < 0)
      ColorResult = ColorDefault;
    }

  else {
    switch (Caps(ArgumentText)) {
      case "BLACK":   ColorResult.R = 0x00; ColorResult.G = 0x00; ColorResult.B = 0x00; break;
      case "MAROON":  ColorResult.R = 0x80; ColorResult.G = 0x00; ColorResult.B = 0x00; break;
      case "GREEN":   ColorResult.R = 0x00; ColorResult.G = 0x80; ColorResult.B = 0x00; break;
      case "OLIVE":   ColorResult.R = 0x80; ColorResult.G = 0x80; ColorResult.B = 0x00; break;
      case "NAVY":    ColorResult.R = 0x00; ColorResult.G = 0x00; ColorResult.B = 0x80; break;
      case "PURPLE":  ColorResult.R = 0x80; ColorResult.G = 0x00; ColorResult.B = 0x80; break;
      case "TEAL":    ColorResult.R = 0x00; ColorResult.G = 0x80; ColorResult.B = 0x80; break;
      case "GRAY":    ColorResult.R = 0x80; ColorResult.G = 0x80; ColorResult.B = 0x80; break;
      case "SILVER":  ColorResult.R = 0xc0; ColorResult.G = 0xc0; ColorResult.B = 0xc0; break;
      case "RED":     ColorResult.R = 0xff; ColorResult.G = 0x00; ColorResult.B = 0x00; break;
      case "LIME":    ColorResult.R = 0x00; ColorResult.G = 0xff; ColorResult.B = 0x00; break;
      case "YELLOW":  ColorResult.R = 0xff; ColorResult.G = 0xff; ColorResult.B = 0x00; break;
      case "BLUE":    ColorResult.R = 0x00; ColorResult.G = 0x00; ColorResult.B = 0xff; break;
      case "FUCHSIA": ColorResult.R = 0xff; ColorResult.G = 0x00; ColorResult.B = 0xff; break;
      case "AQUA":    ColorResult.R = 0x00; ColorResult.G = 0xff; ColorResult.B = 0xff; break;
      case "WHITE":   ColorResult.R = 0xff; ColorResult.G = 0xff; ColorResult.B = 0xff; break;

      default: ColorResult = ColorDefault;
      }
    }

  return ColorResult;
  }


// ============================================================================
// ArgumentFont
//
// Returns a font that matches the given font size as closely as possible.
// Returns the given default font if no valid font size is given.
// ============================================================================

simulated function Font ArgumentFont(string ArgumentText, Font FontDefault) {

  switch (ArgumentText) {
    case "1": case "-2":
    case "2": case "-1":
    case "3": case "-0": case "+0":
    case "4": case "+1":
      return FontNormal;

    case "5": case "+2":
    case "6": case "+3":
    case "7": case "+4":
      return FontBig;

    default:
      return FontDefault;
    }
  }


// ============================================================================
// Hex
//
// Returns the numerical value that corresponds to a hexadecimal number or a
// negative value if no valid hexadecimal value was given.
// ============================================================================

simulated function int Hex(string TextHex) {

  local int IndexChar;
  local string CharCurrent;
  local int Result;

  Result = 0;
  TextHex = Caps(TextHex);

  for (IndexChar = 0; IndexChar < Len(TextHex); IndexChar++) {
    CharCurrent = Mid(TextHex, IndexChar, 1);

    switch (CharCurrent) {
      case "0": Result = Result * 0x10;        break;
      case "1": Result = Result * 0x10 + 0x01; break;
      case "2": Result = Result * 0x10 + 0x02; break;
      case "3": Result = Result * 0x10 + 0x03; break;
      case "4": Result = Result * 0x10 + 0x04; break;
      case "5": Result = Result * 0x10 + 0x05; break;
      case "6": Result = Result * 0x10 + 0x06; break;
      case "7": Result = Result * 0x10 + 0x07; break;
      case "8": Result = Result * 0x10 + 0x08; break;
      case "9": Result = Result * 0x10 + 0x09; break;
      case "A": Result = Result * 0x10 + 0x0A; break;
      case "B": Result = Result * 0x10 + 0x0B; break;
      case "C": Result = Result * 0x10 + 0x0C; break;
      case "D": Result = Result * 0x10 + 0x0D; break;
      case "E": Result = Result * 0x10 + 0x0E; break;
      case "F": Result = Result * 0x10 + 0x0F; break;

      default: return -1;
      }
    }

  return Result;
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
    Text="Enter text here."
    //FontNormal=Font'ScreenFonts.Tahoma10'
    //FontNormalBold=Font'ScreenFonts.TahomaB10'
    //FontBig=Font'ScreenFonts.Tahoma20'
    //FontBigBold=Font'ScreenFonts.TahomaB20'
    //FontHeading=Font'ScreenFonts.Condensed30'
    FontNormalColor=(R=192,G=192,B=192,A=0),
    FontHeadingColor=(R=192,G=192,B=192,A=0),
    bAlwaysRelevant=True
    //Texture=Texture'ActorSlidePage'
    Texture=Texture'Engine.S_Trigger'
}
