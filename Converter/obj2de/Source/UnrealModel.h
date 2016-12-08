// UnrealModel.h
// $Author:   Dave Townsend  $
// $Date:   1 Jan 1997 12:00:00  $
// $Revision:   1.0  $

#ifndef UNREALMODEL_H
#define UNREALMODEL_H

#include <vector>
using std::vector;

//===========================================================================
class cUnrealPolygon {
public:
    cUnrealPolygon( int V0, int V1, int V2 );
    cUnrealPolygon( int V0, int V1, int V2, int Type, 
                    unsigned char V0u, unsigned char V0v,
                    unsigned char V1u, unsigned char V1v,
                    unsigned char V2u, unsigned char V2v,
                    int TextureNum );

	unsigned short		mVertex[3];		// Vertex indices.
	char				mType;			// James' mesh type.
	char				mColor;			// Color for flat and Gouraud shaded.
	unsigned char		mTex[3][2];  	// Texture UV coordinates.
	char				mTextureNum;	// Source texture offset.
	char				mFlags;			// Unreal mesh flags (currently unused).
};


//===========================================================================
class cUnrealModel {
public:
    cUnrealModel();
    virtual ~cUnrealModel();

    void AddPolygon( const cUnrealPolygon& NewPoly );

    // REQUIRE: 0 <= TextureNum < 10
    void AddTexture( int TextureNum, const string& TextureName );

    void AddVertex( float X, float Y, float Z );

    int GetNumPolygons() const;

	int GetNumFrames() const;

    void NewSequence( const string& Name, int Len );

    // REQUIRE: GetNumPolygons() > 0
    void Write( const string& ProjDir, const string& BaseName, float scaleTo, bool calcCollision );

	cUnrealPolygon* GetPolygonByIndex( int indx );

	struct DeusExVertex { 
		short x;
		short y;
		short z;
		short dummy;
	};

	DeusExVertex* GetVertexByIndex( int indx );

protected:
private:
    struct Seq {
        string  Name;
        int     Length;
    };

//    typedef vector<unsigned long>   cVertexList;
    typedef vector<DeusExVertex>   cVertexList;
    typedef vector<cUnrealPolygon>  cPolygonList;
    typedef vector<Seq>             cSeqList;

    cUnrealModel( const cUnrealModel& Rhs ); // no copying
    cUnrealModel& operator=( const cUnrealModel& Rhs ); // no assignment

    cVertexList    mVertices;
    cPolygonList   mPolygons;
    cSeqList       mSequences;
    vector<string> mTextures;
};

#endif // UNREALMODEL_H
