:: Perform Cleanup
del /q C:\Jenkins\workspace\CNN-Jenkins\CodenameNebula\Maps\*.*
del /q C:\Jenkins\workspace\CNN-Jenkins\CodenameNebula\Music\*.*
del /q C:\Jenkins\workspace\CNN-Jenkins\CodenameNebula\Music\Ogg\*.*
del /q C:\Jenkins\workspace\CNN-Jenkins\CodenameNebula\Textures\*.*
del /q C:\Jenkins\workspace\CNN-Jenkins\CodenameNebula\System\*.*
del /q CNNInstallUtil.exe

:: Package Maps
copy ..\Maps\Entry.dx													Maps\
copy ..\Maps\CNNentry.dx												Maps\
copy ..\Maps\05_MoonIntro.dx											Maps\
copy ..\Maps\06_OpheliaDocks.dx											Maps\
copy ..\Maps\06_OpheliaL1.dx											Maps\
copy ..\Maps\06_OpheliaL2.dx											Maps\

cd Maps\
ren CNNentry.dx DX.dx
copy DX.dx CNNEntry.dx
echo . > dummy.txt
cd ..

:: Package Music
copy ..\Music\Terrified.umx												Music\
copy ..\Music\Ogg\f_demo_with_bass.ogg									Music\Ogg\
copy ..\Music\Ogg\Mysterious_SciFi_Music_THE_LAST_FRONTIER.ogg			Music\Ogg\
copy ..\Music\Ogg\win_xp_is_shit.ogg									Music\Ogg\
copy "..\Music\Ogg\Solar_Smoke_Post_Silence _07_The_Spark.ogg"			Music\Ogg\
copy ..\Music\Ogg\Anthem.ogg											Music\Ogg\
copy ..\Music\Ogg\Area51_Leaving.ogg									Music\Ogg\
copy ..\Music\Ogg\WhoAmI.ogg											Music\Ogg\

cd Music\
echo . > dummy.txt
cd ..

cd Music\Ogg\
echo . > dummy.txt
cd ..\..

:: Package Textures
copy ..\Textures\Ophelia.utx											Textures\
copy ..\Textures\AiInfoPortraits.utx									Textures\
copy ..\Textures\AITex.utx												Textures\
copy ..\Textures\PFADTex.utx											Textures\
copy ..\Textures\ArtPieces.utx											Textures\
copy ..\Textures\X3.utx													Textures\
copy ..\Textures\X3tex.utx												Textures\
copy ..\Textures\GenFX.utx												Textures\
copy ..\Textures\CNNTextures.utx										Textures\
copy ..\Textures\AIStalk.utx											Textures\

cd Textures\
echo . > dummy.txt
cd ..

:: Package System
copy ..\System\ApocalypseInside.u										System\
copy ..\System\ApocalypseInside.int										System\
copy ..\System\ApocalypseInsideUser.ini									System\
copy ..\System\ApocalypseInside.bat										System\
copy ..\System\ApocalypseInside.ini										System\
copy ..\System\Apocalypse_Inside.u										System\
copy ..\System\AiScreen.u												System\

:: Package Ogg dependencies
copy ..\System\DXOgg.u                                                  System\
copy ..\System\DXOgg.dll                                                System\

:: Package Unreal Editor 1 fix files
copy ..\System\deusexedfix.txt                                          System\
copy ..\System\RenderExt.dll                                            System\
copy ..\System\RenderExt.int                                            System\
copy ..\System\UnrealEd.exe                                             System\
copy ..\System\Window.dll                                               System\

copy ..\System\CNN.u													System\
copy ..\System\CNNText.u												System\
copy ..\System\CNNAudio*.u												System\
copy ..\System\CNN.ini													System\
copy ..\System\CNNUser.ini												System\
copy ..\System\CNNStart.bat												System\
copy ..\System\PFAD.u													System\
copy ..\System\GaussGun.u												System\
copy ..\System\DXRVNewVehicles.u										System\
copy ..\CNNInstallUtil\CNNInstallUtil\bin\Release\CNNInstallUtil.exe		.\

cd System\
echo . > dummy.txt
cd ..

@echo All files packaged!