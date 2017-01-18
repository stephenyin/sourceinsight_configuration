/* Utils.em - a small collection of useful editing macros */



/*-------------------------------------------------------------------------
	I N S E R T   H E A D E R

	Inserts a comment header block at the top of the current function.
	This actually works on any type of symbol, not just functions.

	To use this, define an environment variable "MYNAME" and set it
	to your email name.  eg. set MYNAME=raygr
-------------------------------------------------------------------------*/
macro InsertHeader()
{
	// Get the owner's name from the environment variable: MYNAME.
	// If the variable doesn't exist, then the owner field is skipped.
	szMyName = getenv(MYNAME)

	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)

	// begin assembling the title string
	sz = "/*   "

	/* convert symbol name to T E X T   L I K E   T H I S */
	cch = strlen(szFunc)
	ich = 0
	while (ich < cch)
		{
		ch = szFunc[ich]
		if (ich > 0)
			if (isupper(ch))
				sz = cat(sz, "   ")
			else
				sz = cat(sz, " ")
		sz = Cat(sz, toupper(ch))
		ich = ich + 1
		}

	sz = Cat(sz, "   */")
	InsBufLine(hbuf, ln, sz)
	InsBufLine(hbuf, ln+1, "/*-------------------------------------------------------------------------")

	/* if owner variable exists, insert Owner: name */
	if (strlen(szMyName) > 0)
		{
		InsBufLine(hbuf, ln+2, "    Owner: @szMyName@")
		InsBufLine(hbuf, ln+3, " ")
		ln = ln + 4
		}
	else
		ln = ln + 2

	InsBufLine(hbuf, ln,   "    ") // provide an indent already
	InsBufLine(hbuf, ln+1, "-------------------------------------------------------------------------*/")

	// put the insertion point inside the header comment
	SetBufIns(hbuf, ln, 4)
}


/* InsertFileHeader:

   Inserts a comment header block at the top of the current function.
   This actually works on any type of symbol, not just functions.

   To use this, define an environment variable "MYNAME" and set it
   to your email name.  eg. set MYNAME=raygr
*/

macro InsertFileHeader()
{
	szMyName = getenv(MYNAME)

	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")

	/* if owner variable exists, insert Owner: name */
	InsBufLine(hbuf, 1, "    ")
	if (strlen(szMyName) > 0)
		{
		sz = "    Owner: @szMyName@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
		}
	else
		ln = 2

	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
}



// Inserts "Returns True .. or False..." at the current line
macro ReturnTrueOrFalse()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLineCur(hbuf)

	InsBufLine(hbuf, ln, "    Returns True if successful or False if errors.")
}



/* Inserts ifdef REVIEW around the selection */
macro IfdefReview()
{
	IfdefSz("REVIEW");
}


/* Inserts ifdef BOGUS around the selection */
macro IfdefBogus()
{
	IfdefSz("BOGUS");
}


/* Inserts ifdef NEVER around the selection */
macro IfdefNever()
{
	IfdefSz("NEVER");
}


// Ask user for ifdef condition and wrap it around current
// selection.
macro InsertIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefSz(sz);
}

macro InsertCPlusPlus()
{
	IfdefSz("__cplusplus");
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefSz(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)

	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
}


// Delete the current line and appends it to the clipboard buffer
macro KillLine()
{
	hbufCur = GetCurrentBuf();
	lnCur = GetBufLnCur(hbufCur)
	hbufClip = GetBufHandle("Clipboard")
	AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))
	DelBufLine(hbufCur, lnCur)
}


// Paste lines killed with KillLine (clipboard is emptied)
macro PasteKillLine()
{
	Paste
	EmptyBuf(GetBufHandle("Clipboard"))
}



// delete all lines in the buffer
macro EmptyBuf(hbuf)
{
	lnMax = GetBufLineCount(hbuf)
	while (lnMax > 0)
		{
		DelBufLine(hbuf, 0)
		lnMax = lnMax - 1
		}
}


// Ask the user for a symbol name, then jump to its declaration
macro JumpAnywhere()
{
	symbol = Ask("What declaration would you like to see?")
	JumpToSymbolDef(symbol)
}


// list all siblings of a user specified symbol
// A sibling is any other symbol declared in the same file.
macro OutputSiblingSymbols()
{
	symbol = Ask("What symbol would you like to list siblings for?")
	hbuf = ListAllSiblings(symbol)
	SetCurrentBuf(hbuf)
}


// Given a symbol name, open the file its declared in and
// create a new output buffer listing all of the symbols declared
// in that file.  Returns the new buffer handle.
macro ListAllSiblings(symbol)
{
	loc = GetSymbolLocation(symbol)
	if (loc == "")
		{
		msg ("@symbol@ not found.")
		stop
		}

	hbufOutput = NewBuf("Results")

	hbuf = OpenBuf(loc.file)
	if (hbuf == 0)
		{
		msg ("Can't open file.")
		stop
		}

	isymMax = GetBufSymCount(hbuf)
	isym = 0;
	while (isym < isymMax)
		{
		AppendBufLine(hbufOutput, GetBufSymName(hbuf, isym))
		isym = isym + 1
		}

	CloseBuf(hbuf)

	return hbufOutput

}

macro MultiLineComment()
{
    hwnd = GetCurrentWnd()
    selection = GetWndSel(hwnd)
    LnFirst = GetWndSelLnFirst(hwnd)      //取首行行号
    LnLast = GetWndSelLnLast(hwnd)      //取末行行号
    hbuf = GetCurrentBuf()

    if(GetBufLine(hbuf, 0) == "//magic-number:tph85666031"){
        stop
    }

    Ln = Lnfirst
    buf = GetBufLine(hbuf, Ln)
    len = strlen(buf)

    while(Ln <= Lnlast) {
        buf = GetBufLine(hbuf, Ln)  //取Ln对应的行
        if(buf == ""){                    //跳过空行
            Ln = Ln + 1
            continue
        }

        if(StrMid(buf, 0, 1) == "/") {       //需要取消注释,防止只有单字符的行
            if(StrMid(buf, 1, 2) == "/"){
                PutBufLine(hbuf, Ln, StrMid(buf, 2, Strlen(buf)))
            }
        }

        if(StrMid(buf,0,1) != "/"){          //需要添加注释
            PutBufLine(hbuf, Ln, Cat("//", buf))
        }
        Ln = Ln + 1
    }

    SetWndSel(hwnd, selection)
}

macro AddMacroComment()
{
    hwnd=GetCurrentWnd()
    sel=GetWndSel(hwnd)
    lnFirst=GetWndSelLnFirst(hwnd)
    lnLast=GetWndSelLnLast(hwnd)
    hbuf=GetCurrentBuf()

    if(LnFirst == 0) {
            szIfStart = ""
    }else{
            szIfStart = GetBufLine(hbuf, LnFirst-1)
    }
    szIfEnd = GetBufLine(hbuf, lnLast+1)
    if(szIfStart == "#if 0" && szIfEnd == "#endif") {
            DelBufLine(hbuf, lnLast+1)
            DelBufLine(hbuf, lnFirst-1)
            sel.lnFirst = sel.lnFirst – 1
            sel.lnLast = sel.lnLast – 1
    }else{
            InsBufLine(hbuf, lnFirst, "#if 0")
            InsBufLine(hbuf, lnLast+2, "#endif")
            sel.lnFirst = sel.lnFirst + 1
            sel.lnLast = sel.lnLast + 1
    }

    SetWndSel( hwnd, sel )
}

macro CommentSingleLine()
{
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur(hbuf)
    str = GetBufLine (hbuf, ln)
    str = cat("/*",str)
    str = cat(str,"*/")
    PutBufLine (hbuf, ln, str)
}

macro CommentSelStr()
{
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur(hbuf)
    str = GetBufSelText(hbuf)
    str = cat("/*",str)
    str = cat(str,"*/")
    SetBufSelText (hbuf, str)
}

/**************************************************************
 *          Source Insight Macro Collection
 *
 * Usage:
 *     1. Add this file to your project, or to the base project so
 *        that you just need to do it once for all your projects.
 *
 *     2. From menu "Options" -> "Key Assignments..." to bind any
 *        macro functions in this file to keys.
 *
 *     3. Enjoy the macros!
 *
 * Copyright (c) 2014-2015, Jia Shi
 **************************************************************/

/*-------------------------------------------------------------------------
  Automatically insert code snippet.

  Currently the following code snippets are supported, but this can
  be extened easily:

      - if
      - else
      - for
      - while
      - do-while
      - switch
      - case
      - default
      - main

  For example:
      1. bind this function to "Tab"
      2. type "for" and press "Tab"
      3. this is what will be inserted:
         for (###; ###; ###)
         {
             ###
         }
      4. and the first ### pattern is selected.
  -------------------------------------------------------------------------*/
macro simcInsertSnippet()
{
    var sMacroName; sMacroName = "simcInsertSnippet"
    var hWnd
    var rSel
    var hBuf
    var sLine
    var iCh
    var sIndent
    var iChLim
    var asciiA
    var asciiZ
    var cCharUpper
    var asciiCharUpper
    var rWordinfo
    var lnCurrent
    var PATTERN; PATTERN = "###"
    var TAB; TAB = CharFromAscii(9)
    var SPACE; SPACE = CharFromAscii(32)

    // if no windows is opened, then do nothing.
    hWnd = GetCurrentWnd()
    if (hWnd == 0)
    {
        stop
    }
    else
    {
        rSel = GetWndSel(hWnd)
        hBuf = GetWndBuf(hWnd)
        sLine = GetBufLine(hBuf, rSel.lnFirst)

        // scan backwords over white space and tab, if any,
        // to the ending of a word
        iCh = rSel.ichFirst - 1
        if (iCh >= 0)
        {
            while (sLine[iCh] == SPACE || sLine[iCh] == TAB)
            {
                iCh = iCh - 1
                if (iCh < 0)
                    break
            }
        }

        // scan backwords to start of word
        iChLim = iCh + 1
        asciiA = AsciiFromChar("A")
        asciiZ = AsciiFromChar("Z")
        while (iCh >= 0)
        {
            cCharUpper = toupper(sLine[iCh])
            asciiCharUpper = AsciiFromChar(cCharUpper)
            if ((asciiCharUpper < asciiA || asciiCharUpper > asciiZ) && !IsNumber(cCharUpper))
                break // stop at first non-identifier character
            iCh = iCh - 1
        }

        // parse word just to the left of the cursor
        // and store the result to the rWordinfo record
        // rWordinfo.szWord = the word string
        // rWordinfo.ich    = the first ich of the word
        // rWordinfo.ichLim = the limit ich of the word
        iCh = iCh + 1
        rWordinfo = ""
        rWordinfo.sWord = strmid(sLine, iCh, iChLim)
        rWordinfo.iCh = iCh
        rWordinfo.iChLim = iChLim

        // generate the indent string, tab will be replaced
        // by 4 spaces.
        iCh = 0
        sIndent = ""
        while (sLine[iCh] == SPACE || sLine[iCh] == TAB)
        {
            if (sLine[iCh] == SPACE)
                sIndent = sIndent # SPACE
            else if (sLine[iCh] == TAB)
                sIndent = sIndent # SPACE # SPACE # SPACE # SPACE

            iCh++
        }

        // select any space / tab between the end
        // of the identifier and the cursor and
        // replace them with the snippet.
        if (rWordinfo.sWord == "if"     || rWordinfo.sWord == "while" ||
            rWordinfo.sWord == "else"   || rWordinfo.sWord == "for"   ||
            rWordinfo.sWord == "switch" || rWordinfo.sWord == "do"    ||
            rWordinfo.sWord == "case"   || rWordinfo.sWord == "default"  )
        {
            SetBufIns(hBuf, rSel.lnFirst, rWordinfo.iChLim)
            rSel.ichFirst = rWordinfo.ichLim
            rSel.ichLim = rSel.ichLim
            SetWndSel(hWnd, rSel)
        }

        if (rWordinfo.sWord == "if" || rWordinfo.sWord == "while")
        {
            SetBufSelText(hBuf, " (@PATTERN@)")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "{")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    @PATTERN@")
            InsBufLine(hBuf, rSel.lnFirst + 3, sIndent # "}")
        }
        else if (rWordinfo.sWord == "else")
        {
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "{")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    @PATTERN@")
            InsBufLine(hBuf, rSel.lnFirst + 3, sIndent # "}")
        }
        else if (rWordinfo.sWord == "for")
        {
            SetBufSelText(hBuf, " (@PATTERN@; @PATTERN@; @PATTERN@)")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "{")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    @PATTERN@")
            InsBufLine(hBuf, rSel.lnFirst + 3, sIndent # "}")
        }
        else if (rWordinfo.sWord == "switch")
        {
            SetBufSelText(hBuf, " (@PATTERN@)")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "{")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    case @PATTERN@:")
            InsBufLine(hBuf, rSel.lnFirst + 3, sIndent # "        @PATTERN@")
            InsBufLine(hBuf, rSel.lnFirst + 4, sIndent # "        break;")
            InsBufLine(hBuf, rSel.lnFirst + 5, sIndent # "}")
        }
        else if (rWordinfo.sWord == "case")
        {
            SetBufSelText(hBuf, " @PATTERN@:")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "    @PATTERN@")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    break;")
        }
        else if (rWordinfo.sWord == "default")
        {
            SetBufSelText(hBuf, ":")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "    @PATTERN@")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    break;")
        }
        else if (rWordinfo.sWord == "do")
        {
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "{")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    @PATTERN@")
            InsBufLine(hBuf, rSel.lnFirst + 3, sIndent # "} while (@PATTERN@)")
        }
        else if (rWordinfo.sWord == "main")
        {
            SetBufSelText(hBuf, "()")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "{")
            InsBufLine(hBuf, rSel.lnFirst + 2, sIndent # "    return @PATTERN@;")
            InsBufLine(hBuf, rSel.lnFirst + 3, sIndent # "}")
        }
        else if (rWordinfo.sWord == "add")
        {
            delete_line
            InsBufLine(hBuf, rSel.lnFirst, sIndent # "/* Begin Add by: @PATTERN@ PN: @PATTERN@ Dsc: @PATTERN@ */")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "/* End Add PN: @PATTERN@ */")

        }
        else if (rWordinfo.sWord == "mod")
        {
            delete_line
            InsBufLine(hBuf, rSel.lnFirst, sIndent # "/* Begin Modify by: @PATTERN@ PN: @PATTERN@ Dsc: @PATTERN@ */")
            InsBufLine(hBuf, rSel.lnFirst + 1, sIndent # "/* End Modify PN: @PATTERN@ */")

        }
        else if (rWordinfo.sWord == "del")
        {
            delete_line
            InsBufLine(hBuf, rSel.lnFirst, sIndent # "/* Delete by: @PATTERN@ PN: @PATTERN@ Dsc: @PATTERN@ */")
        }
        else
        {
            // incase this macro is associated with
            // tab, then it needs to behavior like
            // a normal tab when the user doesn't want
            // to insert any snippets.
            if (CmdFromKey(AsciiFromChar(TAB)) == sMacroName)
            {
                // insert expanded tab (4 spaces) at the
                // begining of each selected line.
                rSel = GetWndSel(hWnd)
                lnCurrent = rSel.lnFirst
                while (lnCurrent <= rSel.lnLast)
                {
                    SetBufIns(hBuf, lnCurrent, rSel.ichFirst)
                    SetBufSelText(hBuf, SPACE # SPACE # SPACE # SPACE)
                    lnCurrent++
                }

                // in case multi-line are selected, keep the lines
                // selected after the macro finished executing, this
                // has the same behavior as pressing tabs.
                if (rSel.lnFirst != rSel.lnLast)
                {
                    rSel.ichLim = rSel.ichLim + 4
                    SetWndSel(hWnd, rSel)
                }
            }

            stop
        }

        // select the first PATTERN
        rSel.ichFirst = rWordinfo.ichLim
        rSel.ichLim = rWordinfo.ichLim
        SetWndSel(hWnd, rSel)
        LoadSearchPattern(PATTERN, False, False, True)
        Search_Forward
    }
}


/*-------------------------------------------------------------------------
  Close all non-dirty file windows, dirty file windows are those source
  file windows with unsaved mofidication.
  -------------------------------------------------------------------------*/
macro simcCloseAllNonDirtyWindow()
{
    var hWnd; hWnd = GetCurrentWnd()
    var hWndNext
    var hBuf

    while (hWnd != 0)
    {
        hWndNext = GetNextWnd(hWnd)
        hBuf = GetWndBuf(hWnd)

        if (!IsBufDirty(hBuf))
            CloseBuf(hBuf)

        hWnd = hWndNext
    }
}


/*-------------------------------------------------------------------------
  Comment out the selected lines in single line comments style.

  By changing the @TOKEN@ variable in the macro function, user can
  replace default comment token from "// " to any other tokens, for
  example, "# " for Python.
  -------------------------------------------------------------------------*/
macro simcCommentLineOut()
{
    var hWnd; hWnd = GetCurrentWnd()
    var hBuf; hBuf = GetCurrentBuf()
    var rSelOrig; rSelOrig = GetWndSel(hWnd)
    var rSelTemp; rSelTemp = rSelOrig
    var lnCurrentLine; lnCurrentLine = rSelOrig.lnFirst
    var sCurrentLine
    var iCurrentLineLen
    var iChar
    var TAB; TAB = CharFromAscii(9)
    var SPACE; SPACE = CharFromAscii(32)
    var TOKEN; TOKEN = "// "

    while (lnCurrentLine <= rSelOrig.lnLast)
    {
        sCurrentLine = GetBufLine(hBuf, lnCurrentLine)
        iCurrentLineLen = GetBufLineLength(hBuf, lnCurrentLine)
        iChar = 0

        while (iChar < iCurrentLineLen)
        {
            if (sCurrentLine[iChar] == SPACE || sCurrentLine[iChar] == TAB)
            {
                iChar++
            }
            else
            {
                rSelTemp.lnFirst = lnCurrentLine
                rSelTemp.lnLast = lnCurrentLine
                rSelTemp.ichFirst = iChar
                rSelTemp.ichLim = iChar
                SetWndSel(hWnd, rSelTemp)
                SetBufSelText(hBuf, TOKEN)
                break
            }
        }
        lnCurrentLine++
    }

    SetWndSel(hWnd, rSelOrig)
}

/*-------------------------------------------------------------------------
  Uncomment out the lines which have been commented out in single line
  comments style.

  By changing the @TOKEN@ variable in the macro function, user can
  replace default comment token from "// " to any other tokens, for
  example, "# " for Python.
  -------------------------------------------------------------------------*/
macro simcUncommentLineOut()
{
    var hWnd; hWnd = GetCurrentWnd()
    var hBuf; hBuf = GetCurrentBuf()
    var rSelOrig; rSelOrig = GetWndSel(hWnd)
    var rSelTemp; rSelTemp = rSelOrig
    var lnCurrentLine; lnCurrentLine = rSelOrig.lnFirst
    var sCurrentLine
    var sCurrentLineTemp
    var iCurrentLineLen
    var iChar
    var TOKEN; TOKEN = "// "
    var TOKEN_LEN; TOKEN_LEN = strlen(TOKEN)

    while (lnCurrentLine <= rSelOrig.lnLast)
    {
        sCurrentLine = GetBufLine(hBuf, lnCurrentLine)
        sCurrentLineTemp = ""
        iCurrentLineLen = GetBufLineLength(hBuf, lnCurrentLine)
        iChar = 0

        while (iChar <= iCurrentLineLen - TOKEN_LEN)
        {
            if (strmid (sCurrentLine, iChar, iChar+TOKEN_LEN) == TOKEN)
            {
                 rSelTemp.lnFirst = lnCurrentLine
                 rSelTemp.lnLast = lnCurrentLine
                 rSelTemp.ichFirst = iChar + TOKEN_LEN
                 rSelTemp.ichLim = iCurrentLineLen
                 SetWndSel(hWnd, rSelTemp)
                 PutBufLine(hBuf, lnCurrentLine, cat(sCurrentLineTemp, strmid(sCurrentLine, rSelTemp.ichFirst, rSelTemp.ichLim)))
                 break
            }
            else
            {
                sCurrentLineTemp = cat(sCurrentLineTemp, sCurrentLine[iChar])
                iChar++
                continue
            }
        }
        lnCurrentLine++
    }
    SetWndSel(hWnd, rSelOrig)
}

/*-------------------------------------------------------------------------
  Comment out the selected lines in block comments style.

  By changing the @iFirstCommLineLen@ user can adjust the number of the
  asterisks in the first block comment line. But the final length of the
  first block comment line is decided by the longest line in the comment,
  if it is longer than default @iFirstCommLineLen@, then its length will
  be used as the value of @iFirstCommLineLen@.
  -------------------------------------------------------------------------*/
macro simcCommentBlockOut()
{
    var hWnd; hWnd = GetCurrentWnd()
    var hBuf; hBuf = GetCurrentBuf()
    var rSelOrig; rSelOrig = GetWndSel(hWnd)
    var lnCurrentLine
    var sCurrentLine
    var iLineLen
    var iFirstCommLineLen; iFirstCommLineLen = 40 // default len of the 1st comment line

    // calculate the length of the longest line
    lnCurrentLine = rSelOrig.lnFirst
    while (lnCurrentLine <= rSelOrig.lnLast)
    {
        iLineLen = GetBufLineLength(hBuf, lnCurrentLine)
        if (iLineLen > iFirstCommLineLen)
            iFirstCommLineLen = iLineLen
        lnCurrentLine++
    }

    // insert the first block comment line.
    InsBufLine(hBuf, rSelOrig.lnFirst, cat("/", __str_rep("*", iFirstCommLineLen)))

      // since an extra line in inserted, rSelOrig became incorrect
    // and needs to be fixed
    rSelOrig.lnFirst = rSelOrig.lnFirst + 1
    rSelOrig.lnLast = rSelOrig.lnLast + 1
    lnCurrentLine = rSelOrig.lnFirst
    while (lnCurrentLine <= rSelOrig.lnLast)
    {
        sCurrentLine = GetBufLine(hBuf, lnCurrentLine)
        PutBufLine(hBuf, lnCurrentLine, cat(" * ", sCurrentLine))
        lnCurrentLine++
    }
    InsBufLine(hBuf, lnCurrentLine, cat(" ", cat(__str_rep("*", iFirstCommLineLen), "/")))
}

/*-------------------------------------------------------------------------
  Uncomment out the selected lines in block comments style.
  -------------------------------------------------------------------------*/
macro simcUncommentBlockOut()
{
    var hWnd; hWnd = GetCurrentWnd()
    var hBuf; hBuf = GetCurrentBuf()
    var rSelOrig; rSelOrig = GetWndSel(hWnd)
    var lnCurrentLine; lnCurrentLine = rSelOrig.lnFirst
    var sCurrentLine
    var TOKEN_BEG; TOKEN_BEG = "/*"
    var TOKEN_MID; TOKEN_MID = "*"
    var TOKEN_END; TOKEN_END = "*/"
    var TAB; TAB = CharFromAscii(9)
    var SPACE; SPACE = CharFromAscii(32)

    while lnCurrentLine <= rSelOrig.lnLast
    {
        sCurrentLine = GetBufLine(hBuf, lnCurrentLine)
        if __str_only_contain(sCurrentLine, TOKEN_MID # SPACE # TAB) // performance consideration
        {
            PutBufLine(hBuf, lnCurrentLine, "")
            lnCurrentLine++
        }
        else if __str_only_contain(sCurrentLine, TOKEN_BEG # TOKEN_END # SPACE # TAB) // performance consideration
        {
            DelBufLine(hBuf, lnCurrentLine)

            if (rSelOrig.lnLast > rSelOrig.lnFirst)
                rSelOrig.lnLast = rSelOrig.lnLast - 1 // the first line has been removed, no need to ++
            else
                lnCurrentLine++
        }
        else
        {
            if __str_begin_with(sCurrentLine, TOKEN_BEG)
                sCurrentLine = __str_lstrip(sCurrentLine, TOKEN_BEG # TAB # SPACE)

            if __str_begin_with(sCurrentLine, TOKEN_MID)
            {
                sCurrentLine = __str_lstrip(sCurrentLine, TOKEN_MID # TAB # SPACE)
            }

            if __str_end_with(sCurrentLine, TOKEN_END)
                sCurrentLine = __str_rstrip(sCurrentLine, TOKEN_END # TAB # SPACE)

            PutBufLine(hBuf, lnCurrentLine, sCurrentLine)
            lnCurrentLine++
        }
    }
}

/*-------------------------------------------------------------------------
  Trims white spaces from the ends of the selected lines in the current
  file buffer, if the selection is empty, it does the whole file.
  -------------------------------------------------------------------------*/
macro simcTrimSpaces()
{
    var TAB; TAB = CharFromAscii(9)
    var SPACE; SPACE = CharFromAscii(32)
    var hBuf; hBuf = GetCurrentBuf()
    var hWnd; hWnd = GetCurrentWnd()
    var rSel; rSel = GetWndSel(hWnd)
    var lnCurrent; lnCurrent = rSel.lnFirst

    while (lnCurrent <= rSel.lnLast)
    {
        PutBufLine(hBuf, lnCurrent, __str_rstrip(GetBufLine(hBuf, lnCurrent), SPACE # TAB))
        lnCurrent++
    }
}

/*-------------------------------------------------------------------------
  Paste what in the clipboard to every selected line at the position of
  the cursor in the first line.
  -------------------------------------------------------------------------*/
macro simcBatchInsert()
{
    var hBuf; hBuf = GetCurrentBuf()
    var hWnd; hWnd = GetCurrentWnd()
    var rSel; rSel = GetWndSel(hWnd)
    var rCursor;
    var sLineBefore
    var sLineAfter
    var sClipboard
    var lnCurrentLine;lnCurrentLine = rSel.lnFirst

    // read content from clipboard
    sLineBefore = GetBufLine(hBuf, rSel.lnFirst)
    PasteBufLine(hBuf, rSel.lnFirst)
    sLineAfter = GetBufLine(hBuf, rSel.lnFirst)
    PutBufLine(hBuf, rSel.lnFirst, sLineBefore)
    sClipboard= __str_subtract(sLineAfter, sLineBefore)

    // generate the cursor selection
    rCursor = rSel
    rCursor.ichLim = rCursor.ichFirst
    rCursor.fExtended = False

    while (lnCurrentLine <= rSel.lnLast)
    {
        rCursor.lnFirst = lnCurrentLine
        rCursor.lnLast = rCursor.lnFirst

        if (strlen(GetBufLine(hBuf, lnCurrentLine)) < rCursor.ichFirst)
            PutBufLine(hBuf, lnCurrentLine, __str_padding(GetBufLine(hBuf, lnCurrentLine), rCursor.ichFirst))

        SetWndSel(hWnd, rCursor)
        SetBufSelText(hBuf, sClipboard)
        lnCurrentLine++
    }
}

/*-------------------------------------------------------------------------
  This macro allows users to bind macros with keys in Emacs style, e.g.
  <Ctrl+k><Ctrl+x>, in this case, macro simcEmacsStyleKeyBinding is binded
  to <Ctrl+k>, and <Ctrl+x> is binded to the macro or command that the user
  want to execute.

  The main function of this macro is to extend the number of key bindings
  -------------------------------------------------------------------------*/
macro simcEmacsStyleKeyBinding()
{
    var hBuf; hBuf = GetCurrentBuf()
    var hWnd; hWnd = GetCurrentWnd()
    var rSel; rSel = GetWndSel(hWnd)
    var functionKey; functionKey = GetKey()

    // Map the functionKey code into a simple character.
    ch = CharFromKey(functionKey)

    if ch == "w"
        simcCloseAllNonDirtyWindow
    else if ch == "s"
        simcSurrounder
    else if ch == "c"
        simcCommentLineOut
    else if ch == "C"
        simcUncommentLineOut
    else if ch == "b"
        simcCommentBlockOut
    else if ch == "B"
        simcUncommentBlockOut
    else if ch == "t"
        simcTrimSpaces
    else if ch == "d"
        simcMatchDelimiter
    else if ch == "i"
        simcBatchInsert
}

/*-------------------------------------------------------------------------
  Macro command that performs a progressive forward search as the user types,
  the search is case-insensitive and regex is not supported.

  Quit progressive search with 'Enter'
  -------------------------------------------------------------------------*/
macro simcProgressiveSearch()
{
    var hBuf; hBuf = GetCurrentBuf()
    var hWnd; hWnd = GetCurrentWnd()
    var rSel; rSel = GetWndSel(hWnd)
    var rSearchRes
    var iKeyCode
    var cChar
    var sSearchStr; sSearchStr = ""

    while 1
    {
        iKeyCode = GetKey()
        cChar = CharFromKey(iKeyCode)

        if iKeyCode == 13       // Enter - perform search
            stop
        else if iKeyCode == 8   // Backspace
        {
            if strlen(sSearchStr) > 0
                sSearchStr = strtrunc(sSearchStr, strlen(sSearchStr)-1)
            else
                continue
        }
        else
            sSearchStr = cat(sSearchStr, cChar)

        rSearchRes = SearchInBuf(hBuf, sSearchStr, rSel.lnFirst, rSel.ichFirst, 0, 0, 0)

        // wrap search
        if rSearchRes == ""
            rSearchRes = SearchInBuf(hBuf, sSearchStr, 0, 0, 0, 0, 0)

        if rSearchRes!= ""
        {
            ScrollWndToLine(hWnd, rSearchRes.lnFirst)
            SetWndSel(hWnd, rSearchRes)
            LoadSearchPattern(sSearchStr, 0, 0, 0)
        }
    }
}

macro simcJumpForward()
{
    var hBuf; hBuf = GetCurrentBuf()
    var hWnd; hWnd = GetCurrentWnd()
    var rSel; rSel = GetWndSel(hWnd)
    var rSearchRes
    var iKeyCode
    var cChar
    var sSearchStr; sSearchStr = ""

    while 1
    {
        iKeyCode = GetKey()
        cChar = CharFromKey(iKeyCode)

        if iKeyCode == 13       // Enter - perform search
            break
        else if iKeyCode == 8   // Backspace
        {
            if strlen(sSearchStr) > 0
                sSearchStr = strtrunc(sSearchStr, strlen(sSearchStr)-1)
            else
                continue
        }
        else
            sSearchStr = cat(sSearchStr, cChar)

    }
    LoadSearchPattern(sSearchStr, 0, 0, 0)
    Search_Forward
}

macro simcJumpBackward()
{
    var hBuf; hBuf = GetCurrentBuf()
    var hWnd; hWnd = GetCurrentWnd()
    var rSel; rSel = GetWndSel(hWnd)
    var rSearchRes
    var iKeyCode
    var cChar
    var sSearchStr; sSearchStr = ""

    while 1
    {
        iKeyCode = GetKey()
        cChar = CharFromKey(iKeyCode)

        if iKeyCode == 13       // Enter - perform search
            break
        else if iKeyCode == 8   // Backspace
        {
            if strlen(sSearchStr) > 0
                sSearchStr = strtrunc(sSearchStr, strlen(sSearchStr)-1)
            else
                continue
        }
        else
            sSearchStr = cat(sSearchStr, cChar)

    }
    LoadSearchPattern(sSearchStr, 0, 0, 0)
    Search_Backward
}

/*-------------------------------------------------------------------------
   Finds matching scoping delimiters and jumps to them.

   If the cursor is not positioned on a delimiter but is inside
   a matching part then the macro will jump to the start of the closest
   scope.

   Currently matches [], (), <>, {}
  -------------------------------------------------------------------------*/
macro simcMatchDelimiter()
{
    var hWnd; hWnd = GetCurrentWnd()
    var hBuf; hBuf = GetCurrentBuf()
    var rSel; rSel = GetWndSel(hWnd)
    var sOpenDelim; sOpenDelim = "[{(<"
    var sClosDelim; sClosDelim = "]})>"
    var sCurrentLine
    var cCurrentChar
    var iNumofSquareBracket;iNumofSquareBracket = 0
    var iNumofParentheses;iNumofParentheses = 0
    var iNumofFrenchQuotes;iNumofFrenchQuotes = 0
    var iNumofBrace;iNumofBrace = 0

    sCurrentLine = GetBufLine(hBuf, rSel.lnFirst)
    cCurrentChar = sCurrentLine[rSel.ichFirst]

    if(__str_contain(sOpenDelim, cCurrentChar))
        jump_to_match
    else if(__str_contain(sClosDelim, cCurrentChar))
        jump_to_match
    else
    {
        while 1
        {
            LoadSearchPattern("[\\[(<{}>)\\]]", 0, 1, 0)
            search_backward
            rSel = GetWndSel(hWnd)

            sCurrentLine = GetBufLine(hBuf, rSel.lnFirst)
            cCurrentChar = sCurrentLine[rSel.ichFirst]

            if cCurrentChar == "["
                iNumofSquareBracket++
            else if cCurrentChar == "]"
                iNumofSquareBracket--
            else if cCurrentChar == "{"
                iNumofBrace++
            else if cCurrentChar == "}"
                iNumofBrace--
            else if cCurrentChar == "("
                iNumofParentheses++
            else if cCurrentChar == ")"
                iNumofParentheses--
            else if cCurrentChar == "<"
                iNumofFrenchQuotes++
            else if cCurrentChar == ">"
                iNumofFrenchQuotes--

            if iNumofBrace > 0 || iNumofFrenchQuotes > 0 || iNumofParentheses > 0 || iNumofSquareBracket >0
                break
        }
    }
}

/*-------------------------------------------------------------------------
  Surround the selection with what you type.

  Hit 'Enter' to quit.
  -------------------------------------------------------------------------*/
macro simcSurrounder()
{
    var hWnd; hWnd = GetCurrentWnd()
    var hBuf; hBuf = GetCurrentBuf()
    var rSel; rSel = GetWndSel(hWnd)
    var rSelOrig; rSelOrig = rSel
    var iKeyCode
    var cChar
    var sSelection
    var iLenSel; iLenSel = strlen(GetBufSelText(hBuf))
    var sSurroundSymbol; sSurroundSymbol = ""
    var sSurroundSymbolPrev; sSurroundSymbolPrev = sSurroundSymbol

    if !rSel.fExtended
        stop

    while 1
    {
        SetWndSel(hWnd, rSel)
        iKeyCode = GetKey()
        cChar = CharFromKey(iKeyCode)

        if iKeyCode == 13       // Enter
            stop
        else if iKeyCode == 8 // && sSurroundSymbolPrev!= ""  // Backspace
        {
            sSelection = GetBufSelText(hBuf)

            if strlen(sSelection) >= 2
            {
                SetBufSelText(hBuf, strmid(sSelection, 1, strlen(sSelection)-1))

                // update selection
                rSel.ichLim = rSel.ichLim - 2
            }
        }
        else
        {
            sSurroundSymbol = cat(sSurroundSymbol, cChar)

            if sSurroundSymbol != ""
            {
                 sSurroundSymbolPrev = sSurroundSymbol
                 rSel.ichLim = rSel.ichLim + 2 * strlen(sSurroundSymbol)
                 sSelection = GetBufSelText(hBuf)

                 // insert surrounder
                 if sSurroundSymbol == "(" || sSurroundSymbol == ")"
                     SetBufSelText(hBuf, cat("(", cat(sSelection, ")")))
                 else if sSurroundSymbol == "[" || sSurroundSymbol == "]"
                     SetBufSelText(hBuf, cat("[", cat(sSelection, "]")))
                 else if sSurroundSymbol == "{" || sSurroundSymbol == "}"
                     SetBufSelText(hBuf, cat("{", cat(sSelection, "}")))
                 else if sSurroundSymbol == "<" || sSurroundSymbol == ">"
                     SetBufSelText(hBuf, cat("<", cat(sSelection, ">")))
                 else
                     SetBufSelText(hBuf, cat(sSurroundSymbol, cat(sSelection, sSurroundSymbol)))

                 sSurroundSymbol = ""
             }
        }
    }
}


/*-------------------------------------------------------------------------
  Return the FIRST different part from string sA, sB must be a substring
  of sA.

  for exampele:

    sA = "Hello world!"
    sB = "world"
    __str_subtract will return: "Hello "
  -------------------------------------------------------------------------*/
macro __str_subtract(sA, sB)
{
    var iLenA; iLenA = strlen(sA)
    var iLenB; iLenB = strlen(sB)
    var iLim; iLim = iLenA - iLenB
    var iCh; iCh = 0

    if iLenA <= iLenB // sB must be a substing of sA
        return ""

    while iCh <= iLim
    {
        i = 0
        while(sA[iCh+i] == sB[i])
        {
            cA = sA[iCh+i]
            cB = sB[i]

            if (i < iLenB)
                i++
            else
                return strmid(sA, 0, iCh)
        }
        iCh++
    }
}

/*-------------------------------------------------------------------------
  Padding space at the end of the string to length iLen
  -------------------------------------------------------------------------*/
macro __str_padding(sLine, iLen)
{
    var iLenLine; iLenLine = strlen(sLine)
    var SPACE; SPACE = CharFromAscii(32)
    var iLenDiff

    iLenDiff = iLenLine - iLen

    if iLenDiff >= 0
        return sLine

    while iLenDiff < 0
    {
        sLine = cat(sLine, SPACE)
        iLenDiff++
    }

    return sLine
}

/*-------------------------------------------------------------------------
  Repeat strings and return the result
  -------------------------------------------------------------------------*/
macro __str_rep(sString, iRepeatTimes)
{
    var iIndex; iIndex = 0
    var sRet; sRet = ""

    while (iIndex++ < iRepeatTimes)
    {
        sRet = sRet # sString
    }

    return sRet
}

/*-------------------------------------------------------------------------
  If string contains substring, return True, else False
  -------------------------------------------------------------------------*/
macro __str_contain(sStr, sSubStr)
{
    var iStrLen; iStrLen = strlen(sStr)
    var iSubStrLen; iSubStrLen = strlen(sSubStr)
    var iChar; iChar = 0
    var iChStrLim; iChStrLim = iStrLen - iSubStrLen

    // every string contains a trailing ""
    if(iSubStrLen == 0)
        return True

    while (iChar <= iChStrLim)
    {
        if (iSubStrLen != 1)
        {
            if (strmid(sStr, iChar, iChar+iSubStrLen) == sSubStr)
                return True
        }
        else
        {
            // this will improve the performance dramatically!
            if (sStr[iChar] == sSubStr)
                return True
        }

        iChar++
    }
    return False
}

/*-------------------------------------------------------------------------
  If string only contains chars which in substring, return True, else False
  -------------------------------------------------------------------------*/
macro __str_only_contain(sStr, sSubStr)
{
    var iStrLen; iStrLen = strlen(sStr)
    var iSubStrLen; iSubStrLen = strlen(sSubStr)
    var iChStr; iChStr = 0
    var iChSubStr; iChSubStr = 0
    var cCharInStr

    while (iChStr <= iStrLen)
    {
        cCharInStr = sStr[iChStr++]

        if !(__str_contain(sSubStr, cCharInStr))
            return False
    }
    return True
}

/*-------------------------------------------------------------------------
  If string begins with substring, then return true.

  the prefix spaces/tabs are ignored.
  -------------------------------------------------------------------------*/
macro __str_begin_with(sStr, sSubStr)
{
    var TAB; TAB = CharFromAscii(9)
    var SPACE; SPACE = CharFromAscii(32)

    sStr = __str_lstrip(sStr, TAB # SPACE)
    sSubStr = __str_lstrip(sSubStr, TAB # SPACE)
    var iStrLen; iStrLen = strlen(sStr)
    var iSubStrLen; iSubStrLen = strlen(sSubStr)

    if iSubStrLen > iStrLen
        return False

    if (strmid(sStr, 0, iSubStrLen) == sSubStr)
        return True
    else
        return False
}

/*-------------------------------------------------------------------------
  If string ends with substring, then return true.

  the suffix spaces/tabs are ignored.
  -------------------------------------------------------------------------*/
macro __str_end_with(sStr, sSubStr)
{

    var TAB; TAB = CharFromAscii(9)
    var SPACE; SPACE = CharFromAscii(32)

    sStr = __str_rstrip(sStr, TAB # SPACE)
    sSubStr = __str_rstrip(sSubStr, TAB # SPACE)
    var iStrLen; iStrLen = strlen(sStr)
    var iSubStrLen; iSubStrLen = strlen(sSubStr)

    if iSubStrLen > iStrLen
        return False

    if (strmid(sStr, iStrLen-iSubStrLen, iStrLen) == sSubStr)
        return True
    else
        return False

}

/*-------------------------------------------------------------------------
  returns a copy of the string in which all chars in sSubStr have been
  stripped from the beginning of the string.
  -------------------------------------------------------------------------*/
macro __str_lstrip(sStr, sSubStr)
{
    var iStrLen; iStrLen = strlen(sStr)
    var cCharInStr
    var iCharInStr; iCharInStr = 0

    while iCharInStr < iStrLen
    {
        cCharInStr = sStr[iCharInStr]
        s = strmid(sStr, iCharInStr, iStrLen)

       if !__str_contain(sSubStr, cCharInStr)
        {
            return strmid(sStr, iCharInStr, iStrLen)
        }

        iCharInStr++
    }
    return ""
}

/*-------------------------------------------------------------------------
  returns a copy of the string in which all chars in sSubStr have been
  stripped from the ending of the string.
  -------------------------------------------------------------------------*/
macro __str_rstrip(sStr, sSubStr)
{
    var iStrLen; iStrLen = strlen(sStr)
    var cCharInStr
    var iCharInStr

    if (iStrLen == 0)
        return ""

    iCharInStr = iStrLen - 1
    while(iCharInStr >= 0)
    {
        cCharInStr = sStr[iCharInStr]


        if !(__str_contain(sSubStr, cCharInStr))
            return strmid(sStr, 0, iCharInStr+1)

        iCharInStr--
    }
    return ""
}

/*-------------------------------------------------------------------------
  strip the substr from the str in left and right side and return the
  stripped string.

  the prefix and suffix spaces/tabs are stripped by default.
  -------------------------------------------------------------------------*/
macro __str_strip(sStr, sSubStr)
{
    var sStrStripped

    sStrStripped = __str_lstrip(sStr, sSubStr)
    sStrStripped = __str_rstrip(sStrStripped, sSubStr)

    return sStrStripped
}


