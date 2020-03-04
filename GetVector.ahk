#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



dist := "10"

~LButton::
MouseGetPos, x1, y1 
Return

~LButton Up::
MouseGetPos, x2, y2
Obj := GetVector(x1, y1, x2, y2, Dist)
X := strSplit(Obj["PlusDist"],",").1
Y := strSplit(Obj["PlusDist"],",").2
MouseMove, %X%, %Y% 

Return

; Below Math comes from https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62763
GetVector(x1, y1, x2, y2, Dist) {

; add in a checker so we don't divide by 0, that way we wont get that bug. 
if ((x2-x1) != 0) && ((y2-y1) != 0) {
	; calculates our slope + y-intercept
		m := (y2 - y1) / (x2 - x1)
		b := y1 - (m * x1)

	; calculates X- and Y-direction to see if it's positive or negative
		xDir := abs(x2-x1)/(x2-x1)
		yDir := abs(y2-y1)/(y2-y1)
		
	; Brute force distance so we don't have to calculate. 
		bruteD := 0
		
		while (bruteD <= dist)
		{
			x3 := Round(x2 + (A_Index * xDir))
			Y3 := Round((m * X3) + b)
			
			bruteD := Round(Sqrt((x3-x2)**2 + (y3-y2)**2))
		}
		
		; compare values to see which is closer, the one we just calculated, or the one right before it
		TempX1D := abs(bruteD - dist)
		
		; calculates the previous X3 + Y3. 
		tempX2 := (x3 - xDir), tempY2 := Round((m * TempX2) + b)
		tempBruteD := Round(Sqrt((TempX2-x2)**2 + (TempY2-y2)**2))
		TempX2D := abs(tempBruteD - dist)
		
		if tempX2D < TempX1D
			x3 := Round(tempX2), y3 := Round(tempY2)
	}
	
; now we'll address the issue of "moving straight up/down"
; that means, the x- doesn't change, but the y-does. 
if ((x2-x1) = 0) && ((y2-y1) != 0) {
	; establish if we're going "Up" or "down"
	yDir := abs(y2-y1)/(y2-y1)
	y3 := round (y2 + (yDir * dist))
	
	; since the X's don't change, we'll assign X3 as X2. 
	x3 := x2
}

; now we'll address the issue of "moving straight right/left"
; that means, the x- changes, but the y-doesn't. 
if ((x2-x1) != 0) && ((y2-y1) = 0) {
	; establish if we're going "Left" or "Right"
	xDir := abs(x2-x1)/(x2-x1)
	x3 := round(x2 + (xDir * dist))
	
	; since the Ys don't change, we'll assign Y3 as Y2.
	Y3 := Y2
}

if ((x2-x1) != 0) || ((y2-y1) != 0) {
		; makes sure we stay within the parameters of our monitor
		if (Y3 >= 0) && (Y3 <= A_ScreenHeight)  && (0 <= X3) && (x3 <= A_ScreenWidth)
			totalDist := Round(sqrt( (x3-x2)**2 + (y3-y2)**2))
	}
VectorObj := {}
VectorObj.Start := x1 ", " y1
VectorObj.End :=  x2 ", " y2
VectorObj.PlusDist := x3 ", " y3
Return VectorObj
}
