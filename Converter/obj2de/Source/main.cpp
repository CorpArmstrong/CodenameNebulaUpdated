#include "3ds2de.h"


const char RegistryPath[] = "Software\\DeusEx1MeshConverter\\obj2de";


//===========================================================================
static void    AddOBJFileToModel( const char* FileName, cUnrealModel* Model, bool flipYZ, bool centering );
static void    Add3DSFileToModel( const char* FileName, cUnrealModel* Model );
static string  GetBaseName( int argc, char* argv[], int* CurArg );
static void    GetProjectDirectory();
static void    SetProjectDirectory();
static void    Usage();    // doesn't return!


//===========================================================================
string          gBaseName;
string          gProjectDirectory;
cUnrealModel    gModel;


//===========================================================================
int main( int argc, char* argv[] )
{
    bool ShowCopyright = true;
	bool FlipYZ = false;
	bool Centering = true;
	float scaleTo_value = 0.0f;
	bool SetCollision = true;

    // Parse options
    int CurArg;
    for( CurArg = 1; CurArg < argc; ++CurArg ) {
        if( *argv[ CurArg ] == '-' ) 
		{
            if( !stricmp( argv[ CurArg ], "-setproj" ) ) {
                SetProjectDirectory();
                exit( 0 );

            } else if (!stricmp( argv[ CurArg ], "-c" ) ) {
                ShowCopyright = false;

			} else if (!stricmp( argv[ CurArg ], "-flipYZ" ) ) {
				FlipYZ = true;

			} else if (!stricmp( argv[ CurArg ], "-nocentering" ) ) {
				Centering = false;

			} else if (!stricmp( argv[ CurArg ], "-nocollision" ) ) {
				SetCollision = false;
			
			} else if ( string(argv[CurArg]).find("-scaleTo=") != string::npos ) {
				string argument(argv[CurArg]);
				
				if ( argument[argument.size()-1] == 'u' )
				{
					scaleTo_value = s2f( argument.substr( 9, argument.size()-10 ) );
				}
				else if ( argument[argument.size()-1] == 'm' )
				{
					scaleTo_value = s2f( argument.substr( 9, argument.size()-10 ) );
					scaleTo_value *= 52.7f;
				}
				else
					Usage();

            } else {
                Usage();
            }
		}
		else {
            break;  // done with options
        }
    }

    if( ShowCopyright ) {
		printf("\nOBJ to DeusEx static mesh converter, obj2de V%s\n", Version );
		//printf("\n3DS to Deus Ex mesh converter, 3ds2de V%s\n", Version );
		printf("based on:\n");
        printf("3ds2unr, Copyright (C) 1998 Legend Entertainment Co.\n");
        printf("3ds2de V1.00 25-May-01, DeusEx modifications by Steve Tack\n");
    }

    GetProjectDirectory();
	printf("project directory: \"%s\"", gProjectDirectory.c_str());

    if( argc - CurArg < 1 )
        Usage();

    // Parse BaseName
    gBaseName = GetBaseName( argc, argv, &CurArg );

    if( argc - CurArg < 1 )
        Usage();

    try {
		// Process OBJ files
        for( ; CurArg < argc; ++CurArg ) 
		{
			if( *argv[ CurArg ] != '-' )
			{
				WIN32_FIND_DATA FindData;
				HANDLE FindH = ::FindFirstFile( argv[ CurArg ], &FindData );

				if( FindH != INVALID_HANDLE_VALUE ) 
				{
					//Add3DSFileToModel( FindData.cFileName, &gModel );
					AddOBJFileToModel( FindData.cFileName, &gModel, 
						               FlipYZ, Centering );

					while( ::FindNextFile( FindH, &FindData ) ) 
					{
						//Add3DSFileToModel( FindData.cFileName, &gModel );
						AddOBJFileToModel( FindData.cFileName, &gModel, 
							               FlipYZ, Centering );
					}

					if( ::GetLastError() != ERROR_NO_MORE_FILES )
						throw cxFile3DS( "error accessing file" );

					::FindClose( FindH );

				} else { 
					throw cxFile3DS( "can't find file" );
				}
			}
        }

        // Create Unreal files
        if( gModel.GetNumPolygons() > 0 )
            gModel.Write( gProjectDirectory, gBaseName, scaleTo_value, SetCollision );
    }
	catch( const cxFileOBJ& e )
	{
		printf( "\nError Accured: %s: %s\n", argv[ CurArg ], e.what() );
	}
    catch( const cxFile3DS& e ) {
        printf( "%s: %s\n", argv[ CurArg ], e.what() );
    }
    catch( ... ) {
        printf( "%s: got unknown exception\n", argv[ CurArg ] );
    }

	getchar();

    return 0;
}

//===========================================================================
static void AddOBJFileToModel( const char* FileName, cUnrealModel* Model, bool flipYZ, bool centering  )
{
	cFileOBJ            CurFile( FileName, flipYZ );
	string              SeqName = FileName;

	if (centering) CurFile.centering();

	SeqName.erase( SeqName.find_last_of("."), SeqName.size() );
	Model->NewSequence( SeqName.c_str(), CurFile.GetNumFrames() );
	
	for( int i = 0; i < CurFile.GetNumFrames(); i++ )
	{
		bool FoundBadCoord = false;

		for ( int point_num = 0; point_num < CurFile.frames[i].size(); point_num++ )
		{
			Model->AddVertex( CurFile.frames[i][point_num].X, 
			                  CurFile.frames[i][point_num].Y,
				              CurFile.frames[i][point_num].Z );
		}
	}

	if( Model->GetNumPolygons() == 0 )
	{
		for ( int i = 0; i < CurFile.faces.size(); i++ )
		{
			Model->AddPolygon( cUnrealPolygon( CurFile.faces[i].V1-1, CurFile.faces[i].V2-1, CurFile.faces[i].V3-1, 
			                                   CurFile.faces[i].Type,
			                                   CurFile.textureUVs[ CurFile.faces[i].UV1-1 ].U, 
											   CurFile.textureUVs[ CurFile.faces[i].UV1-1 ].V,
											   CurFile.textureUVs[ CurFile.faces[i].UV2-1 ].U, 
											   CurFile.textureUVs[ CurFile.faces[i].UV2-1 ].V,
											   CurFile.textureUVs[ CurFile.faces[i].UV3-1 ].U, 
											   CurFile.textureUVs[ CurFile.faces[i].UV3-1 ].V,
											   CurFile.faces[i].TextureNum ) );
		}

		Model->AddTexture( 0, "Ship1.pcx" );
		
	}


}


//===========================================================================
static void Add3DSFileToModel( const char* FileName, cUnrealModel* Model )
{
    cFile3DS            CurFile( FileName );
    string              SeqName = FileName;

    SeqName.erase( SeqName.find_last_of("."), SeqName.size() );
    Model->NewSequence( SeqName.c_str(), CurFile.GetNumFrames() );

    for( int i = 0; i < CurFile.GetNumFrames(); ++i ) { 
        bool FoundBadCoord = false;
        
        cFile3DS::cXYZList::const_iterator CurVertex = CurFile.BeginXYZ( i );
        cFile3DS::cXYZList::const_iterator EndVertex = CurFile.EndXYZ( i );
    
        while( CurVertex != EndVertex ) {
            Model->AddVertex( CurVertex->X, CurVertex->Y, CurVertex->Z );

            if( !FoundBadCoord ) {
                if( CurVertex->X <= -127.0 || 127.0 <= CurVertex->X ||
                    CurVertex->Y <= -127.0 || 127.0 <= CurVertex->Y ||
                    CurVertex->Z <= -127.0 || 127.0 <= CurVertex->Z ) {
                    printf( "warning: %s: bad coordinate %f,%f,%f\n",
                            FileName,
                            CurVertex->X, CurVertex->Y, CurVertex->Z );
                    FoundBadCoord = true;
                }
            }

            ++CurVertex;
        }
    }

    // Only add the faces to the model once, for the first anim sequence
    if( Model->GetNumPolygons() == 0 ) {
        cFile3DS::cFaceList::const_iterator CurFace = CurFile.BeginFace();
        cFile3DS::cFaceList::const_iterator EndFace = CurFile.EndFace();

        while( CurFace != EndFace ) {
            cFile3DS::Face F = *CurFace;
            Model->AddPolygon( cUnrealPolygon( F.V0, F.V1, F.V2,
                                               F.Type, 
                                               F.V0U, F.V0V,
                                               F.V1U, F.V1V,
                                               F.V2U, F.V2V,
                                               F.TextureNum ) );
            ++CurFace;
        }

        for( int TexNum = 0; TexNum < 10; ++TexNum ) {
            string TexName = CurFile.GetTextureName( TexNum );
            if( !TexName.empty() )
                Model->AddTexture( TexNum, TexName );
        }
    }
}

//===========================================================================
static string GetBaseName( int argc, char* argv[], int* CurArg )
{
    char    DirStr[_MAX_DIR];
    char    DriveStr[_MAX_DRIVE];
    char    ExtStr[_MAX_EXT];
    char    NameStr[_MAX_FNAME];

    _splitpath( argv[ *CurArg ], DriveStr, DirStr, NameStr, ExtStr );

    int SpanLen = strcspn( argv[ *CurArg ], "?*" );
    bool HasWildcards =  SpanLen != strlen( argv[ *CurArg ] );

    // If the current arg has no funny stuff (drive/dir names, wildcards)
    // then assume it's a class name.
    if( !*DriveStr && !*DirStr && !*ExtStr && !HasWildcards ) {
        ++*CurArg;

    } else { // user didn't provide a class name.  Intentionally?

        // If multiple files or wildcards given, user probably just forgot
        if( argc - *CurArg > 1 || HasWildcards ) {
            if( HasWildcards ) // don't use '*' as default name!
                strcpy( NameStr, "Junk" );

            string NameStrCopy = NameStr;
            printf( "Class name [%s]? ", NameStr );
            fgets( NameStr, _MAX_FNAME, stdin );

            if( NameStr[ strlen( NameStr ) - 1 ] == '\n' )
                NameStr[ strlen( NameStr ) - 1 ] = '\0';

            if( !*NameStr ) // empty string? use default
                strcpy( NameStr, NameStrCopy.c_str() );
        }
        // else only one file name, no wildcards -- use it as base name
    }

    return NameStr;
}

//===========================================================================
static void GetProjectDirectory()
{
    char Buffer[MAX_PATH];

    cRegistry   RootReg( RegistryPath );
    RootReg.GetValue( "ProjDir", Buffer, MAX_PATH );

    // No registry set?
    if( !*Buffer ) {
        SetProjectDirectory();
        RootReg.GetValue( "ProjDir", Buffer, MAX_PATH );
        if( !*Buffer ) {
            printf( "No project directory found -- exiting\n" );
            exit( 0 );
        }
    }

    gProjectDirectory = Buffer;
}

//===========================================================================
static void SetProjectDirectory()
{
    char            Buffer[_MAX_PATH + 1];
    BROWSEINFO      bi;
    ::ZeroMemory( &bi, sizeof bi );
    bi.lpszTitle      = "Choose Project Directory for obj2de";
    bi.pszDisplayName = &Buffer[ 0 ];
    bi.ulFlags        = BIF_RETURNONLYFSDIRS;

    LPITEMIDLIST    pItemIDList;
    if( ( pItemIDList = ::SHBrowseForFolder( &bi ) ) != 0 )
        if( ::SHGetPathFromIDList( pItemIDList, Buffer ) ) {
            cRegistry RootReg( RegistryPath );
            RootReg.SetValue( "ProjDir", Buffer );

            printf( "Project directory is now `%s'\n", Buffer );

            string NewDirPath = Buffer;
            NewDirPath += "\\";
            NewDirPath += "Models";
            ::CreateDirectory( NewDirPath.c_str(), 0 );

            NewDirPath = Buffer;
            NewDirPath += "\\";
            NewDirPath += "Classes";
            ::CreateDirectory( NewDirPath.c_str(), 0 );
        }
}

//===========================================================================
static void Usage()
{
    puts( "usage: obj2de -setproj" );
    puts( "       obj2de [params] ClassName file1.obj file2.obj ..." );
    puts( "       obj2de [params] ClassName.obj" );
	puts( "" );
	puts( "params:   -flipYZ         Exchange Y and Z coordinates in model." );
	puts( "                          Because in old UnrealEngine1, Z coordinate is a height of vertices," );
	puts( "                          but other programs such as Blender and Max use Y as height." );
	puts( "" );
	puts( "          -scaleTo=XXXm   Model will be proportionally scaled to specified dimension" );
	puts( "                          by height. Dimension XXX must be setted in meters." );
	puts( "                          Just write" );
	puts( "                            -scaleTo=0.25m" );
	puts( "                          and your model will be 25cm in game by height." );
	puts( "" );
	puts( "          -scaleTo=XXXu   Model will be proportionally scaled to specified dimension" );
	puts( "                          by height. Dimension XXX must be setted in Unreal Units!" );
	puts( "                          Just write" );
	puts( "                            -scaleTo=15u" );
	puts( "                          and your model will be 15 units in game by height." );
	puts( "" );
	puts( "          -nocentering    Disable automatic centering by first frame." );
	puts( "                          In other ways model will be centered in center of coordinates." );
	puts( "" );
	puts( "          -nocollision    Disable automatic collision setting in *.uc file." );
	puts( "                          Converter calcs collision as cylinder who touches" );
	puts( "                          to most far points of model. With center at coordinates center." );
    exit( 0 );
}
