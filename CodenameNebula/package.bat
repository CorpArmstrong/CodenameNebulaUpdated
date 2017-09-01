:: Performing Cleanup
del /q Maps\*.*
del /q Music\Ogg\*.*
del /q Textures\*.*
del /q System\*.*

:: Packing Maps
copy ..\Maps\Entry.dx											Maps\
copy ..\Maps\CNNentry.dx										Maps\
copy ..\Maps\05_MoonIntro.dx									Maps\
copy ..\Maps\06_OpheliaDocks.dx									Maps\
copy ..\Maps\06_OpheliaL1.dx									Maps\
copy ..\Maps\06_OpheliaL2.dx									Maps\

cd Maps\
ren CNNentry.dx DX.dx
echo . > dummy.txt
cd ..

:: Package Music
copy ..\Music\Ogg\f_demo_with_bass.ogg							Music\Ogg\
copy ..\Music\Ogg\Mysterious_SciFi_Music_THE_LAST_FRONTIER.ogg	Music\Ogg\
copy ..\Music\Ogg\win_xp_is_shit.ogg							Music\Ogg\
copy "..\Music\Ogg\Solar_Smoke_Post_Silence _07_The_Spark.ogg"	Music\Ogg\
:: Add songs from ApocalypseInside here.

cd Music\Ogg\
echo . > dummy.txt
cd ..\..

:: Package Textures
copy ..\Textures\AiInfoPortraits.utx							Textures\
copy ..\Textures\X3.utx											Textures\
copy ..\Textures\X3tex.utx										Textures\
copy ..\Textures\GenFX.utx										Textures\
copy ..\Textures\CNNTextures.utx								Textures\

cd Textures\
echo . > dummy.txt
cd ..

:: Package System
copy ..\System\ApocalypseInside.u								System\
copy ..\System\ApocalypseInside.int								System\
copy ..\System\ApocalypseInsideUser.ini							System\
copy ..\System\ApocalypseInside.bat								System\
copy ..\System\ApocalypseInside.ini								System\
copy ..\System\Apocalypse_Inside.u								System\
copy ..\System\AiScreen.u										System\

copy ..\System\CNN.u											System\
copy ..\System\CNNText.u										System\
copy ..\System\CNNAudio*.u										System\
copy ..\System\CNN.ini											System\
copy ..\System\CNNUser.ini										System\
copy ..\System\CNNStart.bat										System\

cd System\
echo . > dummy.txt
cd ..

@echo All files packaged!