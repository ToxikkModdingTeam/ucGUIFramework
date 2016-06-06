//================================================================
// ucGUIFramework.GUIPanel
// ----------------
// Panel with draggable title bar
// ----------------
// by Chatouille
//================================================================
class GUIPanel extends GUIDraggable;

var GUITitleBar TitleBar;
var GUIGroup Content;

static function GUIPanel CreatePanel(optional GUIGroup _Parent=None, optional String _Title, optional GUIGroup _Lock)
{
	local GUIPanel p;
	p = new(None) class'GUIPanel';
	if ( _Parent != None )
		_Parent.AddChild(p);

	p.TitleBar = class'GUITitleBar'.static.CreateTitleBar(p, _Title);
	p.TitleBar.InitDefault();
	p.TitleBar.OnLeftMouse = p.InternalOnLeftMouse;
	p.TitleBar.OnHold = p.InternalOnHold;

	p.SetLock(_Lock);

	p.Content = class'GUIGroup'.static.CreateGroup(p);
	p.Content.SetPosAuto("width:100%; bottom:100%; height:100%-"$p.TitleBar.offH.Val);

	return p;
}

defaultproperties
{
	Text=""
	bAutoColor=false
	BgColor=(Val=(R=0,G=0,B=0,A=160))
	BoxColor=(Val=(R=255,G=255,B=255,A=230))
	bCaptureMouse=false
}