//================================================================
// ucGUIFramework.GUICheckBox
// ----------------
// Check box element
// ----------------
// by Chatouille
//================================================================
class GUICheckBox extends GUIButton;

var bool bChecked;

var GUILabel Label;

var delegate<Changed> OnChanged;

delegate Changed(GUICheckBox elem);

static function GUICheckBox CreateCheckBox(optional GUIGroup _Parent=None, optional bool _bChecked=false)
{
	local GUICheckBox cb;

	cb = new(None) class'GUICheckBox';
	if ( _Parent != None )
		_Parent.AddChild(cb);

	cb.Label = class'GUILabel'.static.CreateLabel(cb);
	cb.Label.SetPos("0", "0", "100%", "100%");
	cb.Label.TextFont = MultiFont'UI_Fonts_Final.HUD.MF_Small';
	cb.Label.SetTextAlign(ALIGN_CENTER, ALIGN_MIDDLE);
	cb.Label.SetTextColor(MakeColor(128,220,255,255));
	
	cb.SetChecked(_bChecked);
	return cb;
}

function InternalOnClick(GUIButton elem)
{
	bChecked = !bChecked;
	Update();
	OnChanged(Self);
}

function SetChecked(bool newChecked)
{
	bChecked = newChecked;
	Update();
}

function Update()
{
	if ( bChecked )
		Label.Text = "x";
	else
		Label.Text = "";
}

function Free()
{
	Super.Free();

	OnChanged = None;
}

defaultproperties
{
	Text=""
	offW=(Val=20)
	offH=(Val=20)
	OnClick=InternalOnClick
	OnChanged=Changed
}
