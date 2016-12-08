// UnrealModel.cpp
// $Author:   Dave Townsend  $
// $Date:   1 Jan 1997 12:00:00  $
// $Revision:   1.0  $

// May 25, 2001: Modified for the Deus Ex format -- Steve Tack

#include "3ds2de.h"

using namespace std;


float VectorLength( const float& x, const float& y )
{
	float len = sqrt( x*x + y*y );

	return len;
}


//===========================================================================
cUnrealPolygon::cUnrealPolygon( int V0, int V1, int V2 ) 
{
    ::memset( this, '\0', sizeof *this );
    mVertex[0] = V0;
    mVertex[1] = V1;
    mVertex[2] = V2;
}

//===========================================================================
cUnrealPolygon::cUnrealPolygon( int V0, int V1, int V2, int Type,
                                unsigned char V0u, unsigned char V0v,
                                unsigned char V1u, unsigned char V1v,
                                unsigned char V2u, unsigned char V2v,
                                int TextureNum ) 
: mType( Type ),
  mColor( 0 ),
  mTextureNum( TextureNum ),
  mFlags( 0 )
{
    mVertex[0] = V0;
    mVertex[1] = V1;
    mVertex[2] = V2;

    mTex[0][0] = V0u;
    mTex[0][1] = V0v;
    mTex[1][0] = V1u;
    mTex[1][1] = V1v;
    mTex[2][0] = V2u;
    mTex[2][1] = V2v;
}

//===========================================================================
cUnrealModel::cUnrealModel() 
{
    for( int i = 0; i < 10; ++i )
        mTextures.push_back( "" );
}

//===========================================================================
cUnrealModel::~cUnrealModel() 
{
}

//===========================================================================
void cUnrealModel::AddPolygon( const cUnrealPolygon& NewPoly )
{
    mPolygons.push_back( NewPoly );
}

//===========================================================================
void cUnrealModel::AddTexture( int TextureNum, const string& TextureName ) 
{
    if( TextureNum < 0 || 10 <= TextureNum )
        throw std::exception( "UnrealModel::AddTexture: bad TextureNum" );

    mTextures[ TextureNum ] = TextureName;
}

//===========================================================================
void cUnrealModel::AddVertex( float X, float Y, float Z ) 
{

	// Modified to use Deus Ex formatted vertices.  -- Steve Tack

	DeusExVertex	NewVertex;
	NewVertex.x = (int(X * 256.0)) & 0xffff;
	NewVertex.y = (int(Y * 256.0)) & 0xffff;
	NewVertex.z = (int(Z * 256.0)) & 0xffff;
	NewVertex.dummy = 0;

    mVertices.push_back( NewVertex );

}

//===========================================================================
int cUnrealModel::GetNumPolygons() const
{
    return mPolygons.size();
}

//===========================================================================
int cUnrealModel::GetNumFrames() const // how many frames we have
{
	int NumberOfFrames = 0;

	for(int i = 0; i < mSequences.size(); i ++)
		NumberOfFrames += mSequences[i].Length;
	
	return NumberOfFrames;
}

//===========================================================================
void cUnrealModel::NewSequence( const string& Name, int Len ) 
{
    Seq   NewSeq;
    NewSeq.Name = Name;
    NewSeq.Length = Len;
    mSequences.push_back( NewSeq );
}

//===========================================================================
void cUnrealModel::Write( const string& ProjDir, const string& BaseName, float scaleTo, bool setCollision ) 
{
	// CALCULATING CYLINDER of collision

	// collision of body looks like a cylinder 
	// who touches to most far points of model.
	// centering all models is very recommended.
	float MinHeight = 0, MaxHeight = 0; // real top & bottom of cylinder
	float MaxCenterDistance = 0; // radius of cylinder

	// automatic collision calc's by first frame only.
	int pointsOnFrame = mVertices.size() / GetNumFrames();
	for(int i = 0; i < pointsOnFrame; i ++ )
	{
		if ( mVertices[i].y < MinHeight ) MinHeight = mVertices[i].y;
		if ( mVertices[i].y > MaxHeight ) MaxHeight = mVertices[i].y;

		if ( VectorLength(mVertices[i].x, mVertices[i].y) > MaxCenterDistance ) 
			MaxCenterDistance = VectorLength(mVertices[i].x, mVertices[i].y);
	}

	float RealHeight = (MaxHeight - MinHeight) * 0.00390625;
	float CollisionHeight = max(abs(MaxHeight),abs(MinHeight)) * 0.00390625;
	float CollisionRadius = MaxCenterDistance * 0.00390625;

	// CALCULATING SCALE by height of first frame

	float drawScale = 1.0f;
	float meshmapScale = 0.00390625f;

	if (scaleTo != 0.0f)
	{
		drawScale = scaleTo / RealHeight;

		CollisionHeight *= drawScale;
		CollisionRadius *= drawScale;
		meshmapScale *= drawScale;
	}
		








    // Pre-compute some useful values
    int MaxSeqNameLen = 0;
    int NumFrames = 0;
    for( int Seq = 0; Seq < mSequences.size(); ++Seq ) {
        if( MaxSeqNameLen < mSequences[ Seq ].Name.length() )
            MaxSeqNameLen = mSequences[ Seq ].Name.length();
        NumFrames += mSequences[ Seq ].Length;
    }

    // ---- Write _d.3d file ------------------------------------------------
    string DFileName = ProjDir;
    DFileName += "\\Models\\";
    DFileName += BaseName;
    DFileName += "_d.3d";
    FILE* fp = fopen( DFileName.c_str(), "wb" );
    if( fp == 0 )
        throw std::exception( "can't open _d.3d file" );

    struct DHeader {
        unsigned short  NumPolygons;
        unsigned short  NumVertices;
        unsigned short  BogusRot;
        unsigned short  BogusFrame;
        unsigned long   BogusNormX;
        unsigned long   BogusNormY;
        unsigned long   BogusNormZ;
        unsigned long   FixScale;
        unsigned long   Unused[3];
        unsigned char   Unknown[12];
    } dh;

    memset( &dh, '\0', sizeof(dh) );
    dh.NumPolygons = mPolygons.size();
    dh.NumVertices = mVertices.size() / NumFrames;

    if( fwrite( &dh, sizeof(dh), 1, fp ) != 1 )
        throw std::exception( "_d.3d: couldn't write header" );

    //cPolygonList::iterator i = mPolygons.begin();

    for(int i = 0; i < mPolygons.size(); i++ )
        if( fwrite( (void*)GetPolygonByIndex(i), sizeof(cUnrealPolygon), 1, fp ) != 1 )
            throw exception( "_d.3d: couldn't write polygon" );

    fclose( fp );

    // ---- Write _a.3d file ------------------------------------------------
    string AFileName = ProjDir;
    AFileName += "\\Models\\";
    AFileName += BaseName;
    AFileName += "_a.3d";
    fp = fopen( AFileName.c_str(), "wb" );
    if( fp == 0 )
        throw exception( "can't open _a.3d file" );

    short   Data;
    Data = NumFrames;
    if( fwrite( &Data, sizeof(Data), 1, fp ) != 1 )
        throw exception( "can't write _a.3d #frames" );

    Data = mVertices.size() * sizeof(DeusExVertex) / NumFrames;
    if( fwrite( &Data, sizeof(Data), 1, fp ) != 1 )
        throw exception( "can't write _a.3d framesize" );

    cVertexList::iterator v = mVertices.begin();
    for( int v = 0 ; v < mVertices.size(); ++v ) 
        if( fwrite( GetVertexByIndex(v), sizeof(DeusExVertex), 1, fp ) != 1 )
            throw exception( "_a.3d: couldn't write vertex" );

    fclose( fp );

    //---- Write .uc file ----------------------------------------------------
    string UCFileName = ProjDir;
    UCFileName += "\\Classes\\";
    UCFileName += BaseName;
    UCFileName += ".uc";
    fp = fopen( UCFileName.c_str(), "w" );
    if( fp == 0 )
        throw exception( "can't open .uc file" );
    
    string CommentLine = "//";
    CommentLine += string(77, '=' );
    CommentLine += "\n";

    fputs( CommentLine.c_str(), fp );
    fprintf( fp, "// %s.\n", BaseName.c_str() );
    fputs( CommentLine.c_str(), fp );
    
    fprintf( fp, "class %s extends Actor;\n\n", BaseName.c_str() );
    
    fprintf( fp, "#exec MESH IMPORT MESH=%s "
                 "ANIVFILE=MODELS\\%s_a.3d "
                 "DATAFILE=MODELS\\%s_d.3d X=0 Y=0 Z=0\n",
                 BaseName.c_str(), BaseName.c_str(), BaseName.c_str() );
    fprintf( fp, "#exec MESH ORIGIN MESH=%s X=0 Y=0 Z=0\n\n",
                 BaseName.c_str() );

    string ExecMeshSeq = "#exec MESH SEQUENCE MESH=";
    ExecMeshSeq += BaseName.c_str();
    ExecMeshSeq += " SEQ=";

    fprintf( fp, "%s%*s STARTFRAME=0 NUMFRAMES=%d\n",
                 ExecMeshSeq.c_str(), -MaxSeqNameLen, "All", NumFrames );

    int StartFrame = 0;
    for( int Seq = 0; Seq < mSequences.size(); ++Seq ) {
        fprintf( fp, "%s%*s STARTFRAME=%d NUMFRAMES=%d\n",
                 ExecMeshSeq.c_str(),
                 -MaxSeqNameLen, mSequences[ Seq ].Name.c_str(),
                 StartFrame, mSequences[ Seq ].Length );
        StartFrame += mSequences[ Seq ].Length;
    }

    fprintf( fp, "\n" );

    bool AnyTextures = false;
    for( int TexNum = 0; TexNum < mTextures.size(); ++TexNum ) {
        if( !mTextures[ TexNum ].empty() ) {
            fprintf( fp, "#exec TEXTURE IMPORT NAME=J%s%d "
                         "FILE=MODELS\\%s%d.PCX GROUP=Skins ",
                         BaseName.c_str(), TexNum, BaseName.c_str(), TexNum );
            fprintf( fp, "// %s\n", mTextures[ TexNum ].c_str() );
            AnyTextures = true;
        }
    }
    if( AnyTextures )
        fprintf( fp, "\n" );

    fprintf( fp, "#exec MESHMAP NEW   MESHMAP=%s MESH=%s\n",
                 BaseName.c_str(), BaseName.c_str() );
    fprintf( fp, "#exec MESHMAP SCALE MESHMAP=%s X=%f Y=%f Z=%f\n\n",
                 BaseName.c_str(), meshmapScale, meshmapScale, meshmapScale);

    if( AnyTextures ) {
        for( int i = 0; i < mTextures.size(); ++i ) {
            if( !mTextures[ i ].empty() ) {
                fprintf( fp, "#exec MESHMAP SETTEXTURE MESHMAP=%s "
                             "NUM=%d TEXTURE=J%s%d\n",
                              BaseName.c_str(), i, BaseName.c_str(), i );
            }
        }
    }




	// WRITE DEFAULT PROPERTIES
	fprintf( fp, "\ndefaultproperties\n{\n" );
	fprintf( fp, "    DrawType=DT_Mesh\n" );
	fprintf( fp, "    Mesh=%s\n", BaseName.c_str() );
	

	if (setCollision)
	{
	fprintf( fp, "    CollisionHeight=%f\n", CollisionHeight );
	fprintf( fp, "    CollisionRadius=%f\n", CollisionRadius );
	fprintf( fp, "    bBlockActors=true\n" );
	fprintf( fp, "    bBlockPlayers=true\n" );
	fprintf( fp, "    bCollideActors=true\n" );
	fprintf( fp, "    bCollideWorld=true\n" );
	}

	//if (scaleTo != 0.0f)
	//{
	//fprintf( fp, "    DrawScale=%f\n", drawScale );
	//}

	fprintf( fp, "}\n" );


    fclose( fp );
}


cUnrealPolygon* cUnrealModel::GetPolygonByIndex( int indx )
{
	return &mPolygons[indx];
}


cUnrealModel::DeusExVertex* cUnrealModel::GetVertexByIndex( int indx )
{
	return &mVertices[indx];
}