//-----------------------------------------------------------------------
// ApocalypseInsideStub
//
// Stub for the parent ApocalypseInside mod's package, which the three
// game ending maps (06_Conspiracy.dx, 06_Hijacking.dx, 06_Transcend.dx)
// inherited references to but whose source never made it into CNN.
//
// Naming convention: ucc auto-generates an "<package>Text.u" sidecar
// from #exec CONVERSATION IMPORT directives. We need that sidecar to
// be named "ApocalypseInsideText.u" (where the maps look for
// ConList_Mission04), so the source package must be named
// "ApocalypseInside" — hence this directory layout.
//
// Mission04.con was recovered from git history (commit a5b02b9~1 had
// it as Chapter04.con) with all internal "Chapter04" strings hex-
// rewritten to "Mission04" so the imported ConversationList becomes
// ConList_Mission04 (matching the maps' refs). Conversation content
// is from Chapter04 (HowardStrong/Bouncer) — wrong for endings but
// dormant (no matching NPC tags on ending maps), so dialogue stays
// silent. The ConversationList instance just has to exist for the
// maps to load without warnings.
//
// Replace with re-authored ending content (Plan-Dir/ design docs) or
// the parent mod's source if recovered.
//-----------------------------------------------------------------------
class ApocalypseInsideStub extends Object
    abstract;

#exec CONVERSATION IMPORT FILE="Conversations\Mission04.Con"

defaultproperties
{
}
