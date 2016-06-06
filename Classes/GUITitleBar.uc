//================================================================
// ucGUIFramework.GUITitleBar
// ----------------
// Title bar element for panels
// ----------------
// by Chatouille
//================================================================
class GUITitleBar extends GUILabel;

var GUIGroup Decorations;
var GUISeparator Deco1, Deco2;

static function GUITitleBar CreateTitleBar(optional GUIGroup _Parent=None, optional String _Text="- title -")
{
	local GUITitleBar tb;
	tb = new(None) class'GUITitleBar';
	if ( _Parent != None )
		_Parent.AddChild(tb);
	tb.Text = _Text;
	return tb;
}

function InitDefault()
{
	TextFont = class'CRZHud'.default.GlowFonts[0];

	Decorations = class'GUIGroup'.static.CreateGroup(Self);
	Decorations.SetPos("0", "0", "100%", "100%");

	Deco1 = class'GUISeparator'.static.CreateSeparator(Decorations);
	Deco1.SetAlign(ALIGN_LEFT, ALIGN_MIDDLE);
	Deco1.SetPos("0", "50%", "_", "_");
	Deco1.SetColors(TextColor.Val, TRANSPARENT);

	Deco2 = class'GUISeparator'.static.CreateSeparator(Decorations);
	Deco2.SetAlign(ALIGN_RIGHT, ALIGN_MIDDLE);
	Deco2.SetPos("100%", "50%", "_", "_");
	Deco2.SetColors(TextColor.Val, TRANSPARENT);
}

function Vector2D GetIntrinsicSize(Canvas C)
{
	local Vector2D Size;
	Size = Super(GUILabel).GetIntrinsicSize(C);
	Size.X += 32;
	Size.Y = 32;
	return Size;
}

function InternalOnDraw(GUIGroup elem, Canvas C)
{
	local Vector2D TextSize;

	C.Font = TextFont;
	C.TextSize(Text, TextSize.X, TextSize.Y);
	if ( Deco1 != None )
		Deco1.SetPos("_", "_", ""$((absW - TextSize.X) / 2), "_");
	if ( Deco2 != None )
		Deco2.SetPos("_", "_", ""$((absW - TextSize.X) / 2), "_");

	Super.InternalOnDraw(elem, C);
}

function InternalOnHover(GUIGroup elem, bool newHover)
{
	if ( newHover )
		AlphaTo(1, 0.2, ANIM_EASE_IN);
	else
		AlphaTo(0.8, 0.3, ANIM_EASE_OUT);
}

defaultproperties
{
	relW=(Val=1.0)
	offH=(Val=32)
	Text="TITLE"
	TextAlignX=ALIGN_CENTER
	TextAlignY=ALIGN_MIDDLE
	Scale=(Val=0.8)
	TextColor=(Val=(R=255,G=128,B=0,A=255))
	Alpha=(Val=0.8)
	OnHover=InternalOnHover
	bCaptureMouse=true
}
