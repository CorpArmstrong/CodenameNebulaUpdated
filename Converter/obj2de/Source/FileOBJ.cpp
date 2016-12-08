/*#include "FileOBJ.h"

#include <iostream>
#include <fstream>
#include <string>

#include "SomeFunctions.h"

using namespace std;
*/
#include "3ds2de.h"
using namespace std;

cFileOBJ::Vertex3d calcTriangleNormal(cFileOBJ::Vertex3d P1, cFileOBJ::Vertex3d P2, cFileOBJ::Vertex3d P3)
{
	cFileOBJ::Vertex3d a (P2.X - P1.X, P2.Y - P1.Y, P2.Z - P1.Z);
	cFileOBJ::Vertex3d b (P3.X - P1.X, P3.Y - P1.Y, P3.Z - P1.Z);

	// (a_y*b_z - a_z*b_y), (a_z*b_x - a_x*b_z), (a_x*b_y - a_y*b_x)

	cFileOBJ::Vertex3d n ( (a.Y*b.Z - a.Z*b.Y), (a.Z*b.X - a.X*b.Z), (a.X*b.Y - a.Y*b.X));

	float n_len = VectorLength(n);

	n.X /= n_len;
	n.Y /= n_len;
	n.Z /= n_len;
	
	return n;
}


cFileOBJ::cFileOBJ( const char* FileName, bool flipYZ )
{
	
	ifstream inputFile;
	inputFile.open( FileName, ios::in );
	
	//std::istream inputFile(std::basic_streambuf(FileName));

	cVertexList vertices1;

	int current_texture_num = 0;
	int current_attribute_type = 0;

	while( inputFile )
	{
		string str;
		getline(inputFile, str);
		
		vector<string> words;

		split( str, ' ', words );
			
		if ( words.size() > 1 )
		{
			
			
			// VERTICES
			if ( words[0] == "v" )
			{
				// todo few frames support
				if (words.size() == 4)
					if ( !flipYZ )
						vertices1.push_back(Vertex3d( s2f(words[1]), 
													  s2f(words[2]), 
													  s2f(words[3]) ));
					else 
						vertices1.push_back(Vertex3d( s2f(words[1]), 
													  s2f(words[3]), 
													  s2f(words[2]) ));
			}
			// TEXTURE VERTICES (UV)
			else if ( words[0] == "vt" )
			{
				if (words.size() == 3)
					textureUVs.push_back(TextureUV( (unsigned char)(s2f(words[1]) * 255) ,
					                                (unsigned char)(s2f(words[2]) * 255) ));
			}
			// VERTEX NORMALS (todo use normals, flip polygons)
			else if ( words[0] == "vn" )
			{
				if (words.size() == 4)
					if ( !flipYZ )
						normals.push_back(Vertex3d( s2f(words[1]), 
													s2f(words[2]),
													s2f(words[3]) ));
					else
						normals.push_back(Vertex3d( s2f(words[1]), 
													s2f(words[3]),
													s2f(words[2]) ));
			}
			// MATERIAL NAME (TEXTURE NAME AND FLAGS)
			else if ( words[0] == "usemtl" )
			{
				// todo FLAGS PARSING
	
				if ( words.size() == 2 )
				{
					string preDotName;
					string afterDotName;
				
					if ( words[1].find(".") != string::npos )
					{
						preDotName = afterDotName = words[1];
						
						preDotName.erase( preDotName.find("."), preDotName.size() );
						afterDotName.erase(0, afterDotName.find_last_of(".")+1);

						current_attribute_type = 0; // no attributes
						
						if(afterDotName!="")
						{
							if( afterDotName.find("Ts") != string::npos )
								current_attribute_type = current_attribute_type | 1;

							if( afterDotName.find("Tr") != string::npos )
								current_attribute_type = current_attribute_type | 2;
							
							if( afterDotName.find("Md") != string::npos )
								current_attribute_type = current_attribute_type | 4;
							
							if( afterDotName.find("Wp") != string::npos )
								current_attribute_type = current_attribute_type | 8;

							if( afterDotName.find("Un") != string::npos )
								current_attribute_type = current_attribute_type | 16;

							if( afterDotName.find("Fl") != string::npos )
								current_attribute_type = current_attribute_type | 32;

							if( afterDotName.find("En") != string::npos )
								current_attribute_type = current_attribute_type | 64;
						}
					}
					else
					{
						current_attribute_type = 0; // no attributes
						preDotName = words[1];
						afterDotName = "";
					}

					
					// we use pre dot name fragmet like a name of texture

					// find this  name in array
					bool finded = false;
					int finded_texture_num = 0;

					for (int i = 0; i < textures.size() && !finded ; i++)
						if ( textures[i] == preDotName )
						{
							finded_texture_num = i;
							finded = true;
						}

					// ADD material pre dot name fragment to textures array					
					if ( !finded )
					{
						textures.push_back(preDotName+".pcx");
						current_texture_num = textures.size()-1;
						
						if (textures.size() > 10)
							cout <<endl <<"too many materials in model" <<endl;
					}
					else
						current_texture_num = finded_texture_num;
					// all polygon who stay after that "usemtl" will get his texture number in array
				}
				else
				{
					throw cxFileOBJ("Name of material error.");
				}
			}
			// FACES 
			else if ( words[0] == "f" )
			{
				
				if ( words.size() == 4 )
				{
					ObjFace face;

					face.TextureNum = current_texture_num;
					face.Type = current_attribute_type;

					// 1st point group
					{
						vector<string> point_info;
						split( words[1], '/', point_info );

						if ( point_info.size() == 3 )
						{
							face.V1 = s2i(point_info[0]);
							face.UV1 = s2i(point_info[1]);
							face.N1 = s2i(point_info[2]);
						}
					}
					
					// 2st point group
					{
						vector<string> point_info;
						split( words[2], '/', point_info );

						if ( point_info.size() == 3 )
						{
							face.V2 = s2i(point_info[0]);
							face.UV2 = s2i(point_info[1]);
							face.N2 = s2i(point_info[2]);
						}
					}

					// 3st point group
					{
						vector<string> point_info;
						split( words[3], '/', point_info );

						if ( point_info.size() == 3 )
						{
							face.V3 = s2i(point_info[0]);
							face.UV3 = s2i(point_info[1]);
							face.N3 = s2i(point_info[2]);
						}
					}

					faces.push_back(face);
				}
				else
				{
					throw cxFileOBJ("Mesh use not triangulated edges! Use only triangulated meshes!");
				}
			}
		}
		

	}

	if (textureUVs.size() == 0)
		throw cxFileOBJ("File not includes texture coordinates!");

	if (normals.size() == 0)
		throw cxFileOBJ("File not includes normals!");

	if (vertices1.size() == 0)
		throw cxFileOBJ("File not includes vertices!");

	printf("\n");

	frames.push_back(vertices1);
	
	
	verifyNormals();


	cout <<endl <<"vertices: " <<vertices1.size() 
		 <<endl <<"UV coords: "<<textureUVs.size()
		 <<endl <<"vertex normals: "<<normals.size()
		 <<endl <<"texture materials: "<<textures.size()
		 <<endl <<"faces: "<<faces.size()
		 <<endl;

	inputFile.close();


}

cFileOBJ::~cFileOBJ(void)
{
}

void cFileOBJ::verifyNormals()
{
	// VERIFY NORMALS ON FACES
	// and flip polygon by normal if it needs	
	for ( int i = 0; i < faces.size(); i ++ )
	{
		// calc normal by 3 points of triangle
		Vertex3d calculated_normal = calcTriangleNormal(frames[0][faces[i].V1-1], frames[0][faces[i].V2-1], frames[0][faces[i].V3-1]);

		// calc normal by 3 near vertex'es normals
		Vertex3d average( (normals[faces[i].N1-1].X + normals[faces[i].N2-1].X + normals[faces[i].N3-1].X) / 3,
			(normals[faces[i].N1-1].Y + normals[faces[i].N2-1].Y + normals[faces[i].N3-1].Y) / 3,
			(normals[faces[i].N1-1].Z + normals[faces[i].N2-1].Z + normals[faces[i].N3-1].Z) / 3 );

		float average_len = VectorLength(average);

		average.X /= average_len;
		average.Y /= average_len;
		average.Z /= average_len;

		Vertex3d difference1( calculated_normal.X - average.X,
			calculated_normal.Y - average.Y,
			calculated_normal.Z - average.Z );

		float difference1_len = VectorLength(difference1);

		Vertex3d difference2( -calculated_normal.X - average.X,
			-calculated_normal.Y - average.Y,
			-calculated_normal.Z - average.Z );

		float difference2_len = VectorLength(difference2);


		if ( difference1_len > difference2_len )
		{
			printf("\n incorrect face normal %f %f", difference1_len, difference2_len );

			int bufVertex, bufNormal, bufUV;

			bufVertex = faces[i].V2;
			bufNormal = faces[i].N2;
			bufUV = faces[i].UV2;

			faces[i].V2 = faces[i].V3;
			faces[i].N2 = faces[i].N3;
			faces[i].UV2 = faces[i].UV3;

			faces[i].V3 = bufVertex;
			faces[i].N3 = bufNormal;
			faces[i].UV3 = bufUV;

			printf(" face was flipped.");
		}
		else if ( difference1_len < difference2_len )
			//printf("- ");
			printf("\n correct normal %f %f ", difference1_len, difference2_len );
		else
			//printf("0 ");
			printf("\n 0 %f %f ", difference1_len, difference2_len );
	}
}

void cFileOBJ::centering()
{
	// CENTERING
	Vertex3d Min(0,0,0);
	Vertex3d Max(0,0,0);
	//bounding box finding
	for( int i = 0; i < frames[0].size(); i ++ )
	{
		if (frames[0][i].X < Min.X)
			Min.X = frames[0][i].X;
		if (frames[0][i].Y < Min.Y)
			Min.Y = frames[0][i].Y;
		if (frames[0][i].Z < Min.Z)
			Min.Z = frames[0][i].Z;

		if (frames[0][i].X > Max.X)
			Max.X = frames[0][i].X;
		if (frames[0][i].Y > Max.Y)
			Max.Y = frames[0][i].Y;
		if (frames[0][i].Z > Max.Z)
			Max.Z = frames[0][i].Z;
	}

	// real model center
	Vertex3d Center( (Max.X - Min.X) / 2 + Min.X, 
		(Max.Y - Min.Y) / 2 + Min.Y, 
		(Max.Z - Min.Z) / 2 + Min.Z );

	// shift center of model to center of coordinates.
	for( int frameNum = 0; frameNum < frames.size(); frameNum++)
		for( int i = 0; i < frames[frameNum].size(); i ++ )
		{
			frames[frameNum][i].X -= Center.X;
			frames[frameNum][i].Y -= Center.Y;
			frames[frameNum][i].Z -= Center.Z;
		}
}

int cFileOBJ::GetNumFrames() const
{
	return frames.size();
}

int cFileOBJ::GetNumPolygons() const
{
	return 0;
}

int cFileOBJ::GetNumVertices() const
{
	return 0;
}