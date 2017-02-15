//=============================================================================
// Custom Decorations.
//=============================================================================
Class DecoFolders expands Object
	abstract;

// Folder

#exec MESH IMPORT MESH=Folder ANIVFILE=Models\Folder_a.3d DATAFILE=Models\Folder_d.3d
#exec MESH ORIGIN MESH=Folder X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=Folder X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=Folder   SEQ=All	STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Folder   SEQ=Still	STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=Folder MESH=Folder

#exec TEXTURE IMPORT NAME=FolderTex1  FILE=Models\Folder_a.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=FolderTex2  FILE=Models\Folder_b.pcx GROUP="Skins"
#exec TEXTURE IMPORT NAME=DocumentTex1  FILE=Models\Document_a.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=Folder NUM=0  TEXTURE=FolderTex1
#exec MESHMAP SETTEXTURE MESHMAP=Folder NUM=1  TEXTURE=DocumentTex1

// FolderOpen

#exec MESH IMPORT MESH=FolderOpen ANIVFILE=Models\FolderOpen_a.3d DATAFILE=Models\FolderOpen_d.3d
#exec MESH ORIGIN MESH=FolderOpen X=0 Y=0 Z=0
#exec MESHMAP SCALE MESHMAP=FolderOpen X=0.00390625 Y=0.00390625 Z=0.00390625
#exec MESH SEQUENCE MESH=FolderOpen   SEQ=All	STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=FolderOpen   SEQ=Still	STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=FolderOpen MESH=FolderOpen

#exec TEXTURE IMPORT NAME=DocumentTex2  FILE=Models\Document_b.pcx GROUP="Skins"
#exec MESHMAP SETTEXTURE MESHMAP=FolderOpen NUM=0  TEXTURE=FolderTex1
#exec MESHMAP SETTEXTURE MESHMAP=FolderOpen NUM=1  TEXTURE=DocumentTex1
#exec MESHMAP SETTEXTURE MESHMAP=FolderOpen NUM=2  TEXTURE=DocumentTex2

defaultproperties
{
}
