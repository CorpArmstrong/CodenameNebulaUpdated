// Registry.h
// $Author:   Dave Townsend  $
// $Date:   1 Jan 1997 12:00:00  $
// $Revision:   1.0  $

#ifndef REGISTRY_H
#define REGISTRY_H

// For now, always uses HKEY_CURRENT_USER root
class cRegistry {
public:
    cRegistry( const char* Path );
    virtual ~cRegistry();

    // REQUIRE: KeyName != 0
    // REQUIRE: Value != 0
    // REQUIRE: ValueLen == size of Value buffer
    void GetValue( const char* KeyName, char* Value, int ValueLen );

    // REQUIRE: KeyName != 0
    // If ValueLen == -1, strlen(Value) is used as length of data 
    void SetValue( const char* KeyName, const char* Value, int ValueLen = -1 );

protected:
private:
    cRegistry( const cRegistry& Rhs ); // no copying
    cRegistry& operator=( const cRegistry& Rhs ); // no assignment

    string  mKeyPath;
    HKEY    mHKey;
};

#endif // REGISTRY_H
