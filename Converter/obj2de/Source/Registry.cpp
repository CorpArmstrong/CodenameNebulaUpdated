#include "3ds2de.h"

//===========================================================================
cRegistry::cRegistry( const char* Path ) 
: mHKey( 0 )
{
    assert( Path != 0 );
    mKeyPath = Path;
}

//===========================================================================
/* cm-hints: virtual */
cRegistry::~cRegistry() 
{
    if( mHKey )
        ::RegCloseKey( mHKey );
}

//===========================================================================
void cRegistry::GetValue( const char* KeyName, char* Value, int ValueLen ) 
{
    assert( KeyName != 0 );
    assert( Value != 0 );
    assert( ValueLen > 0 );

    *Value = '\0';

    LONG RV;
    RV = ::RegOpenKeyEx( HKEY_CURRENT_USER, mKeyPath.c_str(), 0L,
                         KEY_READ, &mHKey );
    if( RV == ERROR_SUCCESS ) {
        DWORD Type;
        DWORD DataLen = ValueLen;
        ::RegQueryValueEx( mHKey, KeyName, 0, &Type, 
                           reinterpret_cast<unsigned char*>( Value ),
                           &DataLen );
        ::RegCloseKey( mHKey );
        mHKey = 0;
    }
}

//===========================================================================
void cRegistry::SetValue( const char* KeyName, const char* Value, int ValueLen ) 
{
    assert( KeyName != 0 );
    assert( Value != 0 );

    if( ValueLen <= 0 )
        ValueLen = ::strlen( Value );

    DWORD Res;
    LONG RV;
    RV = ::RegCreateKeyEx( HKEY_CURRENT_USER, mKeyPath.c_str(), 0L, REG_NONE,
                          REG_OPTION_NON_VOLATILE, KEY_WRITE, 0, &mHKey, &Res );
    if( RV == ERROR_SUCCESS ) {
        ::RegSetValueEx( mHKey, KeyName, 0L, REG_SZ,
                         (CONST BYTE*)Value, ValueLen );
        ::RegCloseKey( mHKey );
        mHKey = 0;
    }
}

