/*
	Scale-A-Boggle
	Needlessly complex but fun :)
*/
Boggle:=New ScaleABoggle(100,100)
return
GuiEscape:
ExitApp
return
GuiClose:
ExitApp
return
Class ScaleABoggle{
	Letters:=[["A","A","E","E","G","N"]
		    ,["A","B","B","J","O","O"]
		    ,["A","C","H","O","P","S"]
		    ,["A","F","F","K","P","S"]
		    ,["A","O","O","T","T","W"]
		    ,["C","I","M","O","T","U"]
		    ,["D","E","I","L","R","X"]
		    ,["D","E","L","R","V","Y"]
		    ,["D","I","S","T","T","Y"]
		    ,["E","E","G","H","N","W"]
		    ,["E","E","I","N","S","U"]
		    ,["E","H","R","T","V","W"]
		    ,["E","I","O","S","S","T"]
		    ,["E","L","R","T","T","Y"]
		    ,["H","I","M","N","U","Qu"]
		    ,["H","L","N","N","R","Z"]]
	__New(Count:=16,Timer:=150,Color:=""){
		static
		Color:=Color?Color:["0x0000FF","0x00FF00","0xFF0000"]
		Gui,Destroy
		Gui,+HWNDMain
		this.ID:="ahk_id" Main,this.HWND:=Main
		Gui,Add,Text,,F1 For Help
		Gui,Add,StatusBar
		Gui,Font,S20 CDefault,Verdana
		Gui,Margin,10,10
		this.Dice:=[],Dup:=[],this.Count:=Count,this.Die:=[],this.Timer:=Timer,this.Color:=Color
		Loop,%Count%{
			if(!Mod(A_Index-1,16))
				Dup:=[]
			while(Dup[Random]||!Random)
				Random,Random,1,16
			Dup[Random]:=1,this.Die.Push(A_Index)
			this.Dice.Push(this.Letters[Random])
		}
		Columns:=Ceil(Sqrt(Count)),this.Controls:=[]
		for a,b in this.Dice{
			Random,Random,1,6
			Gui,Add,Edit,% "x" (!Mod(A_Index-1,Columns)?"m":"+m") " w50 h50 HWNDHWND -TabStop Center ReadOnly Disabled +0x400000"
			this.Controls[A_Index]:=HWND
		}
		this.CountDown:=this.CountDown.Bind(this)
		Gui,Add,Edit,% "xm w" Columns*55 " HWNDTry"
		Gui,Add,ListView,% "xm w" Columns*55,Guesses
		this.Try:=Try,this.TID:="ahk_id" Try
		Hotkey,IfWinActive,% this.ID
		for a,b in {Backspace:this.Backspace.Bind(this),Enter:this.Enter.Bind(this)}
			Hotkey,%a%,%b%,On
		Bind:=this.Guess.Bind(this)
		GuiControl,+g,%Try%,%Bind%
		this.Connect:=this.GetConnect(Count)
		Gui,Show,,Scale-A-Boggle
	}Backspace(){
		ControlGetText,Word,,% this.TID
		SendMessage,0xB0,0,0,,% this.TID
		End:=ErrorLevel>>16,Start:=ErrorLevel&0xFF
		if(Start!=End)
			SendMessage,0xB1,%Start%,%Start%,,% this.TID
		else{
			Obj:=StrSplit(Word)
			if(Obj[Start]="Q"){
				End:=Start+1,Start-=1
			}else if(Obj[Start]="u"&&Obj[Start-1]="Q")
				Start-=2,End:=Start+2
			else{
				Start-=1,End:=Start+1
			}
			SendMessage,0xB1,%Start%,%End%,,% this.TID
			SendMessage,0xC2,1,,,% this.TID
		}
	}Check(Possible,Letter,Current){
		static LastPossible
		New:=[]
		for a,b in Possible{
			Matches:=Possible[a].Matches:=[]
			for c,d in b.Connect{
				for e,f in StrSplit(a,".")
					if(d=f)
						Continue,2
				if(this.Grid[d]=Letter)
					New[a "." d]:={Connect:this.Connect[d]}
			}
		}return New
	}CountDown(){
		this.Running--
		if(this.Running=0){
			CountDown:=this.CountDown
			SetTimer,%CountDown%,Off
			SB_SetText("Game Over")
			Score:=Count:=0
			for a,b in this.Score
				Score+=(Len:=StrLen(a))~="(3|4)"?1:Len=5?2:Len=6?3:Len=7?5:Len>=8?11:0,Count++
			MsgBox,,Scale-A-Boggle,% "Time's Up!`n`nScore: " Score "`n`nWords: " Count
		}else
			SB_SetText("Time Remaining: " this.Running)
	}Enter(){
		if(!this.Running){
			ControlSetText,,,% this.TID
			this.Running:=this.Timer
			CountDown:=this.CountDown
			SetTimer,%CountDown%,1000
			LV_Delete()
			this.Shuffle(),this.Score:=[]
		}else{
			Word:=this.GetWord()
			if(this.Exist&&!this.Score[Word]){
				LV_Insert(1,"",Word),this.Exist:=0,this.Score[Word]:=1
				ControlSetText,,,% this.TID
			}
		}
	}GetConnect(Count,WithGrid:=0){
		Columns:=Ceil(Sqrt(Count))
		Lines:=[],Rows:=[],Connect:=[],RR:=0
		Loop,%Count%{
			Index:=A_Index
			if(!Mod(Index-1,Columns))
				Lines.Push(Row:=[]),RR++
			Row.Push(Index)
			Rows[Index]:=RR
		}
		Loop,%Count%{
			Index:=A_Index
			Obj:=Lines[Rows[Index]]
			for a,b in Obj{
				if(b=Index){
					Column:=a
					Break
				}
			}
			Above:=Lines[Rows[Index]-1]
			Current:=Lines[Rows[Index]]
			Below:=Lines[Rows[Index]+1]
			Item:=Connect[Index]:=[]
			if(Above){
				if(Column-1)
					Item.Push(Above[Column-1])
				Item.Push(Above[Column])
				if(Column+1<=Columns)
					Item.Push(Above[Column+1])
			}if(Column-1)
				Item.Push(Index-1)
			if(Column+1<=Columns&&Value:=Index+1<=Count)
				Item.Push(Index+1)
			if(Below){
				if(Column-1)
					Item.Push(Below[Column-1])
				if(Value:=Below[Column])
					Item.Push(Value)
				if(Column+1<=Columns&&(Value:=Below[Column+1]))
					Item.Push(Value)
			}if(!Mod(Index-1,Columns)&&Index>1)
				Grid.="`n"
			Grid.=Index "`t"
		}return WithGrid?{Connect:Connect,Grid:Grid}:Connect
	}GetWord(){
		ControlGetText,Word,,% this.TID
		return Word
	}Guess(x*){
		Word:=this.GetWord()
		this.Exist:=0
		SendMessage,0xB0,,,,% this.TID
		Start:=(ErrorLevel&0xFF)-1
		if(Word~="\s"){
			ControlSetText,,% RegExReplace(Word,"\s"),% this.TID
			SendMessage,0xB1,%Start%,%Start%,,% this.TID
		}
		Letters:=StrSplit(Word)
		if(Letters[Start+1]="Q")
			Send,u
		this.Reset()
		Possible:=[]
		if(!Word)
			return
		Obj:=[]
		for a,b in StrSplit(Word){
			if(Skip){
				Skip:=0
				Continue
			}if(b="Q")
				Skip:=1,Obj.Push("Qu")
			else
				Obj.Push(b)
		}
		Status:=0
		for a,b in this.Grid{
			if(b=SubStr(Word,1,StrLen(b))){
				Possible[a]:={Connect:this.Connect[a]}
				GuiControl,-Disabled,% this.Controls[a]
			}
		}
		for a,b in Obj{
			if(A_Index>1){
				Possible:=this.Check(Possible,b,a)
			}
		}
		Index:=0
		this.Reset()
		for a,b in Possible{
			Show:=StrSplit(a,".")
			if(Show.MaxIndex()!=Obj.MaxIndex())
				Continue
			Index++
			ColorIndex:=this.Color.MaxIndex()+((Mod(Index,this.Color.MaxIndex()))-this.Color.MaxIndex())+1
			Color:=this.Color[ColorIndex]
			for a,b in Show{
				GuiControl,-Disabled,% this.Controls[b]
				CC:=Color|((A_Index-1)*0x0C0C0C)
				Gui,Font,% "c" Format("{:0X}",CC)
				GuiControl,Font,% this.Controls[b]
				this.Exist:=1
			}
		}
	}m(x*){
		for a,b in x
			Msg.=b "`n"
		MsgBox,,Scale-A-Boggle,% Trim(Msg,"`n")
	}Reset(){
		Loop,% this.Count
			GuiControl,+Disabled,% this.Controls[A_Index]
	}Shuffle(){
		this.Grid:=[]
		TrackDie:=this.Die.Clone()
		for a,b in this.Dice{
			Random,DD,1,% TrackDie.MaxIndex()
			Random,Roll,1,6
			this.Grid.Push(this.Dice[TrackDie[DD],Roll])
			TrackDie.Remove(DD)
		}
		for a,b in this.Grid{
			GuiControl,,% this.Controls[a],%b%
		}
	}
}