#ifndef F3DS2UNR_H
#define F3DS2UNR_H

#define WIN32_LEAN_AND_MEAN
#define STRICT  1

#pragma warning (disable:4786) // ignore "debug information truncated..."

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <exception>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>

#include <string>
using std::string;

#include <vector>
#include <map>
using std::vector;
using std::map;

#include <windows.h>
#include <shlobj.h>



#include "FileOBJ.h"
#include "File3DS.h"
#include "Registry.h"
#include "UnrealModel.h"
#include "SomeFunctions.h"

const char Version[] = "0.1a 25-Nov-15";

#endif // F3DS2UNR_H
