//=============================================================================
// CNNTextImport.
//=============================================================================
class CNNTextImport extends Object abstract;

// CNNCredits.txt lives in text\credits\ (moved 2026-09-23, see
// CODE_REVIEW.md H5), not directly in text\ like it used to. Every file
// below imports fine because each sits one level deep in a
// mission05/mission06 subfolder; CNN\Classes\ApocalypseInsideText.uc's
// `#exec ALLDEUSEXTEXT IMPORT` auto-discovers .txt files sitting directly
// at each package's Text\ root, across packages, and does NOT recurse
// into subfolders. CNNCredits.txt used to be the one file directly at the
// Text\ root, so ALLDEUSEXTEXT picked it up too -- both it and this
// explicit directive tried to import the same file to a resource named
// "CNNCredits" at once, and that collision silently dropped the content
// from BOTH CNN.u and CNNText.u. Moving it into a subfolder takes it out
// of ALLDEUSEXTEXT's reach entirely, so only this explicit, proven-stable
// DEUSEXTEXT IMPORT (same mechanism as every file below, none of which
// have ever shown this problem) imports it now.
#exec DEUSEXTEXT IMPORT FILE=text\credits\CNNCredits.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission05\05_BookHelium3.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission05\05_CauseIBurn.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission05\05_CauseIDrown.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission05\05_JaneDoeProfile.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission05\05_MagdaleneDiary.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission05\05_MagdaleneProfile.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission05\05_SongLyrics.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Book01.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin01.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin02.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin03.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin04.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin06.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin07.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin08.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin09.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin10.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin11.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin12.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Bulletin13.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Datacube01.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_Datacube02.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_NigeriaBombing.txt
#exec DEUSEXTEXT IMPORT FILE=text\mission06\06_OpheliaWarehouse.txt
