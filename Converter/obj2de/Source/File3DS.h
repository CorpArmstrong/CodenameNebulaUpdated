// File3DS.h
// $Author:   Dave Townsend  $
// $Date:   1 Jan 1997 12:00:00  $
// $Revision:   1.0  $

#ifndef FILE3DS_H
#define FILE3DS_H

//#include <exception>

//===========================================================================
class cxFile3DS : public std::exception {
public:
    cxFile3DS( const __exString& What );
};

//===========================================================================
class cFile3DS {
public:
    //--- TYPES -------------------------------------------------------------
    struct XYZ {
        float   X;
        float   Y;
        float   Z;
        bool operator<( const XYZ& Rhs ) const; // needed so can be map<> key
    };
    typedef vector<XYZ>     cXYZList;

    struct XYZTexture {
        int             Alias;  // index of pt for which this pt is an alias
        unsigned char   U;
        unsigned char   V;
    };
    typedef vector<XYZTexture>    cXYZTextureList;

    struct Face {
        short         V0;
        unsigned char V0U;
        unsigned char V0V;
        short         V1;
        unsigned char V1U;
        unsigned char V1V;
        short         V2;
        unsigned char V2U;
        unsigned char V2V;
        char          TextureNum; // 0-9: which texture is this mapped to?
        char          Type;
    };
    typedef vector<Face>    cFaceList;

    //--- METHODS ------------------------------------------------------------
    explicit cFile3DS( const char* FileName );
    virtual ~cFile3DS();

    cFaceList::const_iterator  BeginFace() const;
    cXYZList::const_iterator   BeginXYZ( int FrameNum ) const;
    cFaceList::const_iterator  EndFace() const;
    cXYZList::const_iterator   EndXYZ( int FrameNum ) const;

    int GetNumFrames() const;
    int GetNumPolygons() const;
    int GetNumVertices() const;

    // REQUIRE: 0 <= TextureNum < 10
    // RETURNS: name of given texture ("" if that texture # is unused)
    const string& GetTextureName( int TextureNum ) const;
#if 0
    int GetTextureFlags() const;    // bits 0-9; 1 means texture is used
#endif

protected:
private:
    int    FindAlias( int AbsoluteVertexIndex ); // returns unique vertex index
    bool   ParseChunk( FILE* fp );       // return true=parse obj, false=skip obj
    string ParseCStr( FILE* fp );
    bool   ParseFaceArray( FILE* fp );   // return true=parse obj, false=skip obj
    void   ParseFaceMaterial( FILE* fp );
    void   ParseMapCoords( FILE* fp );
    bool   ParseNamedObject( FILE* fp ); // return true=parse obj, false=skip obj
    void   ParseVertexArray( FILE* fp );
    void   ReadChunkHeader( FILE* fp, unsigned short* pID, unsigned long* pLen );

    vector<cXYZList>    mFrames;
    cFaceList           mFaces;
    int                 mCurrentFrame;
    vector<XYZTexture>  mTextureUVs;
    vector<string>      mTextures;

    cFile3DS( const cFile3DS& Rhs ); // no copying
    cFile3DS& operator=( const cFile3DS& Rhs ); // no assignment
};

//===========================================================================
inline cxFile3DS::cxFile3DS( const __exString& What ) 
: exception( What )
{
}

#endif // FILE3DS_H

