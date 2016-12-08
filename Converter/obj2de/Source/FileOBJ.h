#ifndef FILEOBJ_H
#define FILEOBJ_H
// written by Bortnik Eugene
// at 26-11-15
// early work alpha

//#include <exception>

//===========================================================================
class cxFileOBJ : public std::exception {
public:
	cxFileOBJ( const __exString& What );
};

//===========================================================================
class cFileOBJ
{
public:
	//--- TYPES -------------------------------------------------------------
	struct Vertex3d {
		float   X;
		float   Y;
		float   Z;
		Vertex3d(float x, float y, float z)
		{ X = x; Y = y; Z = z; }

		//bool operator<( const XYZ& Rhs ) const; // needed so can be map<> key
	};
	typedef vector<Vertex3d>     cVertexList;

	struct TextureUV {
		unsigned char   U;
		unsigned char   V;

		TextureUV ( unsigned char u, unsigned char v ) 
		{ U = u; V = v; }
	};
	typedef vector<TextureUV>    cTextureUVList;

	struct ObjFace {
		unsigned short V1;
		unsigned short UV1;
		unsigned short N1;

		unsigned short V2;
		unsigned short UV2;
		unsigned short N2;

		unsigned short V3;
		unsigned short UV3;
		unsigned short N3;

		char          TextureNum; // 0-9: which texture is this mapped to?
		char          Type;
	};
	typedef vector<ObjFace>    cFaceList;

	// members
	vector<cVertexList> frames;
	cTextureUVList      textureUVs;
	cVertexList         normals;
	cFaceList           faces;

	int                 currentFrame;
	vector<string>      textures;

	//--- METHODS ------------------------------------------------------------
	explicit cFileOBJ( const char* FileName, bool flipYZ );
	virtual ~cFileOBJ();

	void cFileOBJ::verifyNormals();
	void cFileOBJ::centering();

	int GetNumFrames() const;
	int GetNumPolygons() const;
	int GetNumVertices() const;

protected:
private:
};

inline cxFileOBJ::cxFileOBJ( const __exString& What ) 
: exception( What )
{
}

#endif // FILEOBJ_H