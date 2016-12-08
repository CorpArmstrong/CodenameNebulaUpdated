#include "3ds2de.h"

void split(const string &s, char delim, vector<string> &elems) 
{
	stringstream ss(s);

	string item;

	while (getline(ss, item, delim)) {
		elems.push_back(item);
	}

}

float s2f ( const string& s )
{
	float tmp_val = 0;

	stringstream ss;
	ss << s;
	ss >> tmp_val;

	return tmp_val;	
}

int s2i ( const string& s )
{
	int tmp_val = 0;

	stringstream ss;
	ss << s;
	ss >> tmp_val;

	return tmp_val;	
}

float VectorLength( const cFileOBJ::Vertex3d& v )
{
	float len = sqrt( v.X*v.X + v.Y*v.Y + v.Z*v.Z );

	return len;
}