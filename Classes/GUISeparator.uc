//================================================================
// ucGUIFramework.GUISeparator
// ----------------
// Horizontal separator element
// ----------------
// by Chatouille
//================================================================
class GUISeparator extends GUIGroup;

static function GUISeparator CreateSeparator(optional GUIGroup _Parent=None)
{
	local GUISeparator sep;
	sep = new(None) class'GUISeparator';
	if ( _Parent != None )
		_Parent.AddChild(sep);
	return sep;
}

defaultproperties
{
    Texture=Texture2D'GUIResources.sep_hor'
    offH=(Val=4)
}
