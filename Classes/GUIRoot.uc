//================================================================
// ucGUIFramework.GUIRoot
// ----------------
// Root element - fixed on screen bounds
// ----------------
// by Chatouille
//================================================================
class GUIRoot extends GUIGroup;

var GameViewportClient Viewport;

var Vector2D MousePos;
var GUIGroup Hovering;
var GUIGroup PrevHovering;
var GUIGroup Active;

static function GUIRoot Create(Object _Outer, GameViewportClient _Viewport)
{
	local GUIRoot R;

	R = new(_Outer) class'GUIRoot';
	R.Root = R;
	R.Viewport = _Viewport;
	return R;
}

function Tick(float dt)
{
    PrevHovering = Hovering;
    Hovering = None;

    if ( dt < 0 )
        dt = 0.01;

    GUITick(dt);
    PostTick(dt);

    if ( Hovering != PrevHovering )
    {
        if ( PrevHovering != None )
            PrevHovering.OnHover(PrevHovering, false);
        if ( Hovering != None )
            Hovering.OnHover(Hovering, true);
    }
}

function PostRender(Canvas C)
{
    MousePos = GetCanvasMousePos(C, Viewport);
	
    OnDraw(Self, C);
    PostDraw(C);
}

function bool KeyEvent(Name Key, EInputEvent EventType)
{
	if ( Key == 'LeftMouseButton' )
	{
		if ( EventType == IE_Pressed && Hovering != None )
		{
			Hovering.OnLeftMouse(Hovering, true);
			Active = Hovering;
		}
		else if ( EventType == IE_Repeat && Active != None )
		{
			Active.OnHold(Active);
		}
		else if ( EventType == IE_Released && Active != None )
		{
			Active.OnLeftMouse(Active, false);
			Active = None;
		}
		return true;
	}
	else if ( Key == 'RightMouseButton' )
	{
		if ( EventType == IE_Pressed && Hovering != None )
		{
			Hovering.OnRightMouse(Hovering, true);
			Active = Hovering;
		}
		else if ( EventType == IE_Released && Active != None )
		{
			Active.OnRightMouse(Active, false);
			Active = None;
		}
		return true;
	}
	return false;
}

// set screen size dimensions (do in Draw to get canvas sizes)
// avoid resizings (remove anims)
// allow root alpha
function GUITick(float dt)
{
    AnimFloat(Alpha, dt);

	// always hovering self if capturing mouse
	if ( bCaptureMouse && bEnabled )
		Hovering = Self;
}

function InternalOnDraw(GUIGroup elem, Canvas C)
{
    absX = 0;
    absY = 0;
    absW = C.ClipX;
    absH = C.ClipY;
}

function bool MouseInBounds(int X1, int Y1, int X2, int Y2)
{
    return (MousePos.X >= X1 && MousePos.X <= X2 && MousePos.Y >= Y1 && MousePos.Y <= Y2);
}

static function Vector2D GetCanvasMousePos(Canvas C, GameViewportClient gViewport)
{
    local Vector2D p;
    local Vector2D RealScreenSize;

    p = gViewport.GetMousePosition();
    gViewport.GetViewportSize(RealScreenSize);
    if ( int(C.ClipY) != int(RealScreenSize.Y) )
    {
        p.Y -= (RealScreenSize.Y - C.ClipY) / 2;
    }

    return p;
}

defaultproperties
{
	OnDraw=InternalOnDraw
}
