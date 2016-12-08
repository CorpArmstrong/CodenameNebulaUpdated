// File3DS.cpp
// $Author:   Dave Townsend  $
// $Date:   1 Jan 1997 12:00:00  $
// $Revision:   1.0  $

// May 25, 2001: Modified for the Deus Ex format -- Steve Tack

#include "3ds2de.h"
using namespace std;
//===========================================================================
bool cFile3DS::XYZ::operator<( const XYZ& Rhs ) const
{
    if( X == Rhs.X ) {
        if( Y == Rhs.Y ) 
            return Z < Rhs.Z;
        return Y < Rhs.Y;
    }
    return X < Rhs.X;
}

//===========================================================================
/* cm-hints: explicit */
cFile3DS::cFile3DS( const char* FileName ) 
: mCurrentFrame( -1 )
{
    for( int i = 0; i < 10; ++i ) 
        mTextures.push_back( "" );

    FILE*   fp = fopen( FileName, "rb" );
    if( fp == 0 )
        throw cxFile3DS( "file not found" );

    // Load in the frame/polygon data
    ParseChunk( fp );

    printf( "%s: imported %d frame%s\n",
            FileName, mCurrentFrame + 1, mCurrentFrame == 0 ? "" : "s" );
}

//===========================================================================
/* cm-hints: virtual */
cFile3DS::~cFile3DS() 
{
}

//===========================================================================
cFile3DS::cFaceList::const_iterator cFile3DS::BeginFace() const
{
    return mFaces.begin();
}

//===========================================================================
cFile3DS::cXYZList::const_iterator cFile3DS::BeginXYZ( int FrameNum ) const
{
    return mFrames[ FrameNum ].begin();
}

//===========================================================================
cFile3DS::cFaceList::const_iterator cFile3DS::EndFace() const
{
    return mFaces.end();
}

//===========================================================================
cFile3DS::cXYZList::const_iterator cFile3DS::EndXYZ( int FrameNum ) const
{
    return mFrames[ FrameNum ].end();
}

//===========================================================================
/* cm-hints: private */
int cFile3DS::FindAlias( int AbsVertexIndex ) 
{
    if( 0 <= AbsVertexIndex && AbsVertexIndex < mTextureUVs.size() )
        return mTextureUVs[ AbsVertexIndex ].Alias;

    throw exception( "cFile3DS::FindAlias: AbsVertexIndex out of range" );
    return 0; // shuts up compiler warning: not all paths return value
}

//===========================================================================
int cFile3DS::GetNumFrames() const
{   
    return mFrames.size();
}

//===========================================================================
int cFile3DS::GetNumPolygons() const
{
    return mFaces.size();
}

//===========================================================================
int cFile3DS::GetNumVertices() const
{
    int Sum = 0;

    for( int i = 0; i < mFrames.size(); ++i )
        Sum += mFrames[ i ].size();

    return Sum;
}

#if 0
//===========================================================================
int cFile3DS::GetTextureFlags() const
{
    int Flags = 0;
    for( int i = 0; i < mTextures.size(); ++i )
        if( mTextures[ i ] != "" )
            Flags |= ( 1 << i );
    return Flags;
}
#endif

//===========================================================================
const string& cFile3DS::GetTextureName( int TextureNum ) const
{
    if( TextureNum < 0 || 9 < TextureNum )
        throw cxFile3DS( "GetTextureName(): bad TextureNum" );

    return mTextures[ TextureNum ];
}

//===========================================================================
/* cm-hints: private */
bool cFile3DS::ParseChunk( FILE* fp ) 
{
    unsigned long   StartPos = ftell( fp );

    unsigned short  ID;
    unsigned long   Len;
    ReadChunkHeader( fp, &ID, &Len );

//    printf( "0x%04x %8d\n", ID, Len );

    switch( ID ) {
    case 0x3d3d:    // editor portion of file
    case 0x4100:    // where the fun stuff lives
    case 0x4d4d:    // 3DS magic number
        while( ftell( fp ) - StartPos < Len ) 
            if( !ParseChunk( fp ) )
                break;
        break;

    case 0x4000:
        if( ParseNamedObject( fp ) )
            while( ftell( fp ) - StartPos < Len ) 
                if( !ParseChunk( fp ) )
                    break;
        break;

    case 0x4110: ParseVertexArray( fp );  break;

    case 0x4120: 
        if( ParseFaceArray( fp ) )
            while( ftell( fp ) - StartPos < Len )
                if( !ParseChunk( fp ) )
                    break;
        break;

    case 0x4130: ParseFaceMaterial( fp ); break;
    case 0x4140: ParseMapCoords( fp );    break;

    // Chunk lengths include the ID/Len already read
    default:     fseek( fp, Len - sizeof ID - sizeof Len , SEEK_CUR );    break;
    }

    // skip remaining data
    int ChunkRead = ftell( fp ) - StartPos;
    if( ChunkRead < Len )
        fseek( fp, Len - ChunkRead, SEEK_CUR );

    return true;
}

//===========================================================================
/* cm-hints: private */
string cFile3DS::ParseCStr( FILE* fp ) 
{
    string Str;
    int    ch;

    while( ( ch = fgetc( fp ) ) != EOF && ch != '\0' )
        Str += char(ch);

    return Str;
}

//===========================================================================
/* cm-hints: private */
bool cFile3DS::ParseFaceArray( FILE* fp ) 
{
    short   NumFaces;
    if( fread( &NumFaces, sizeof(NumFaces), 1, fp ) != 1 )
        throw cxFile3DS( "read error [NumFaces]" );

    struct ExtFace {
        short V0, V1, V2, Flags;
    };

    // Only load faces once
    if( GetNumPolygons() > 0 ) {
        fseek( fp, sizeof(ExtFace) * NumFaces, SEEK_CUR );
        return false;
    }

    while( NumFaces-- > 0 ) {
        ExtFace XFace;

        if( fread( &XFace, sizeof(XFace), 1, fp ) != 1 )
            throw cxFile3DS( "read error [face]" );
        
        Face CurFace;
        CurFace.V0  = FindAlias( XFace.V1 );
        CurFace.V0U = mTextureUVs[ XFace.V1 ].U;
        CurFace.V0V = mTextureUVs[ XFace.V1 ].V;

        CurFace.V1  = FindAlias( XFace.V2 );
        CurFace.V1U = mTextureUVs[ XFace.V2 ].U;
        CurFace.V1V = mTextureUVs[ XFace.V2 ].V;

        CurFace.V2  = FindAlias( XFace.V0 );
        CurFace.V2U = mTextureUVs[ XFace.V0 ].U;
        CurFace.V2V = mTextureUVs[ XFace.V0 ].V;

        CurFace.TextureNum = CurFace.Type = 0;
            
        mFaces.push_back( CurFace );
    }

    return true;
}

//===========================================================================
/* cm-hints: private */
void cFile3DS::ParseFaceMaterial( FILE* fp ) 
{
    string MaterialName = ParseCStr( fp );

    // TBD: parse name extensions (_T, _B, etc.)

    char TextureNum = 1;
    char Type       = 0;

    // Don't use basic_string<>::operator==() because it's case-sensitive.
    if( !stricmp( MaterialName.c_str(), "SKIN" ) ) {
        TextureNum = 0;

    } else {
        // Find a free texture number.  Use 0 [=SKIN] last.
        int i;
		
		for( i = 1; i < 10; ++i ) {
            if( mTextures[ i ] == "" )
                break;
        }

        if( i == 10 ) {
            if( mTextures[ 0 ].empty() ) // use SKIN if we have to
                i = 0;
            else
                throw cxFile3DS( "too many textures" );
        }

        TextureNum = i;

        if( !stricmp( MaterialName.c_str(), "WEAPON" ) ) 
            Type = 8;

        else if( !stricmp( MaterialName.c_str(), "TWOSIDED" ) ) // twosided with holes at extra black places (maybe Translucet + Twosided)
            Type = 3;

        else if( !stricmp( MaterialName.c_str(), "TRANSLUCENT" ) ) // normal translucent
            Type = 2;

        else if( !stricmp( MaterialName.c_str(), "TWOSIDEDNORM" ) ) // normal twosided
            Type = 1;

        else if( !stricmp( MaterialName.c_str(), "UNLIT" ) ) 
            Type = 16;

        else if( !stricmp( MaterialName.c_str(), "FLAT" ) ) 
            Type = 32;

        else if( !stricmp( MaterialName.c_str(), "ENVMAPPED" ) ) 
            Type = 64;

    }

    mTextures[ TextureNum ] = MaterialName;

    short  NumFaces;
    if( fread( &NumFaces, sizeof(NumFaces), 1, fp ) != 1 )
        throw cxFile3DS( "read error [NumMatFaces]" );

    if( mCurrentFrame != 0 ) {
        fseek( fp, NumFaces * sizeof(short), SEEK_CUR );

    } else {
        for( int i = 0; i < NumFaces; ++i ) {
            short FaceNum;
            if( fread( &FaceNum, sizeof(FaceNum), 1, fp ) != 1 )
                throw cxFile3DS( "read error [MatFace]" );

            if( 0 <= FaceNum && FaceNum < mFaces.size() ) {
                mFaces[ FaceNum ].TextureNum = TextureNum;
                mFaces[ FaceNum ].Type       = Type;
            } else {
                throw cxFile3DS( "bad face num" );
            }
        }
    }
}

//===========================================================================
/* cm-hints: private */
void cFile3DS::ParseMapCoords( FILE* fp ) 
{
    short   NumCoordPairs;
    if( fread( &NumCoordPairs, sizeof(NumCoordPairs), 1, fp ) != 1 )
        throw cxFile3DS( "read error [MapCoords]" );

    if( NumCoordPairs != mTextureUVs.size() )
        throw cxFile3DS( "# map coords != # vertices read" );

    // Only care about first set of UVs
    if( mCurrentFrame != 0 ) {
        fseek( fp, NumCoordPairs * 2 * sizeof(float), SEEK_CUR );

    } else {
        for( int i = 0; i < NumCoordPairs; ++i ) {
            float   U;
            float   V;
            if( fread( &U, sizeof U, 1, fp ) != 1 ||
                fread( &V, sizeof V, 1, fp ) != 1 )
                throw cxFile3DS( "read error [UV]" );

            // 3DS UVs appear 
            mTextureUVs[ i ].U =       (unsigned char)(U * 256.0);
            mTextureUVs[ i ].V = 255 - (unsigned char)(V * 256.0);
        }
    }
}

//===========================================================================
/* cm-hints: private */
bool cFile3DS::ParseNamedObject( FILE* fp ) 
{
    string ObjName = ParseCStr( fp );
    int Len = ObjName.length();

    int SeqNumPos = ObjName.find_last_not_of( "0123456789" );
    if( ObjName[ SeqNumPos ] != '\0' )
        ++SeqNumPos;

    // Remember: mCurrentFrame is a 0-based index, and the sequence numbers
    // are 1-based.
    if( SeqNumPos == Len || atoi( &ObjName[ SeqNumPos ] ) != mCurrentFrame + 2 ) {
        printf( "warning: out of sequence obj (%s) skipped\n", ObjName.c_str() );
        return false;
    } 

    ++mCurrentFrame;
    mFrames.push_back( cXYZList() );
    return true;
}

//===========================================================================
/* cm-hints: private */
void cFile3DS::ParseVertexArray( FILE* fp ) 
{
    typedef map<XYZ, int>   cUniqueVertexList;

    cUniqueVertexList   UniqueVertices;

    short   NumVertices;
    if( fread( &NumVertices, sizeof(NumVertices), 1, fp ) != 1 )
        throw cxFile3DS( "read error [NumVerts]" );

    while( NumVertices-- > 0 ) {
        float   v[3];
        if( fread( v, sizeof(v[0]), 3, fp ) != 3 )
            throw cxFile3DS( "read error [vertex]" );
        
        XYZ        CurVert = { v[0], v[1], v[2] };
        XYZTexture XYZT    = { 0, 0.0, 0.0 };  // dummy info; filled in later

        cUniqueVertexList::iterator i = UniqueVertices.find( CurVert );
        if( i == UniqueVertices.end() ) { // it's a new vertex
            XYZT.Alias = mFrames[ mCurrentFrame ].size();

            cUniqueVertexList::value_type Val( CurVert, XYZT.Alias );
            UniqueVertices.insert( Val );

            mFrames[ mCurrentFrame ].push_back( CurVert );
            
        } else { // we've already seen this vertex
            XYZT.Alias = (*i).second;

        }

        if( mCurrentFrame == 0 ) {
            mTextureUVs.push_back( XYZT );
        }
    }
}

//===========================================================================
/* cm-hints: private */
void cFile3DS::ReadChunkHeader( FILE*           fp,
                                unsigned short* pID,
                                unsigned long*  pLen ) 
{
    if( ( fread( pID,  sizeof(*pID),  1, fp ) != 1 ) ||
        ( fread( pLen, sizeof(*pLen), 1, fp ) != 1 ))
        throw cxFile3DS( "error reading chunk header" );
}


