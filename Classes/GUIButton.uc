//================================================================
// ucGUIFramework.GUIButton
// ----------------
// Button element
// ----------------
// by Chatouille
//================================================================
class GUIButton extends GUILabel;

var bool bAutoColor;
var sColorAnim AutoColor;
var Vector2D AutoPadding;

var bool bHover;
var bool bActive;

var delegate<Click> OnClick;

delegate Click(GUIButton elem);

static function GUIButton CreateButton(optional GUIGroup _Parent=None, optional String _Text="button", optional delegate<Click> _OnClick=Click)
{
	local GUIButton btn;
	btn = new(None) class'GUIButton';
	if ( _Parent != None )
		_Parent.AddChild(btn);
	btn.Text = _Text;
	btn.OnClick = _OnClick;
	return btn;
}

function Vector2D GetIntrinsicSize(Canvas C)
{
	local Vector2D Size;
	Size = Super.GetIntrinsicSize(C);
	Size.X = FCeil(Size.X + AutoPadding.X);
	Size.Y = FCeil(Size.Y + AutoPadding.Y);
	return Size;
}

function SetAutoColor(Color newColor)
{
    AutoColor.Val = newColor;
    AutoColor.Queue.Length = 0;
}

function AutoColorTo(Color newColor, float Dur, eAnimMode Mode)
{
    AutoColor.Queue.Length = 0;

    QueueAutoColor(newColor, Dur, Mode);
}

function QueueAutoColor(Color newColor, float Dur, eAnimMode Mode)
{
    local int i;

    i = AutoColor.Queue.Length;
    AutoColor.Queue.Length = i+1;
    AutoColor.Queue[i].Target = newColor;
    AutoColor.Queue[i].TotalDur = Dur;
    AutoColor.Queue[i].Mode = Mode;

    if ( i == 0 )
    {
        AutoColor.Start = AutoColor.Val;
        AutoColor.RemDur = Dur;
    }
}

function GUITick(float dt)
{
    Super.GUITick(dt);

    AnimColor(AutoColor, dt);
}

function InternalOnDraw(GUIGroup elem, Canvas C)
{
    if ( bAutoColor )
    {
        if ( bHover && bActive )
        {
            BgColor.Val = MultColor(AutoColor.Val, 1.0, 0.55);
            BoxColor.Val = MultColor(AutoColor.Val, 0.8, 1.1);
            TextColor.Val = MultColor(AutoColor.Val, 0.8, 1.1);
        }
        else if ( bHover )
        {
            BgColor.Val = MultColor(AutoColor.Val, 1.0, 0.75);
            BoxColor.Val = MultColor(AutoColor.Val, 1.1, 1.1);
            TextColor.Val = MultColor(AutoColor.Val, 1.1, 1.1);
        }
        else
        {
            BgColor.Val = MultColor(AutoColor.Val, 1.0, 0.35);
            BoxColor.Val = AutoColor.Val;
            TextColor.Val = AutoColor.Val;
        }
    }
    Super.InternalOnDraw(elem, C);
}

function InternalOnHover(GUIGroup elem, bool newHover)
{
    bHover = newHover;
}

function InternalOnLeftMouse(GUIGroup elem, bool bDown)
{
    if ( bActive && !bDown && bHover )
        OnClick(Self);

    bActive = bDown;
}

function Free()
{
	Super.Free();

	OnClick = None;
}

defaultproperties
{
    TextAlignX=ALIGN_CENTER
    TextAlignY=ALIGN_MIDDLE

    Texture=Texture2D'GUIResources.GizmoTexture'
    bAutoColor=true
    AutoColor=(Val=(R=255,G=255,B=255,A=230))
	AutoPadding=(X=16,Y=8)

    bCaptureMouse=true
    OnHover=InternalOnHover
    OnLeftMouse=InternalOnLeftMouse
    OnClick=Click
}
