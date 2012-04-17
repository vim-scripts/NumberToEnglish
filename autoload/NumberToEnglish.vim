" -*- vim -*-
" (C) 2009 by Salman Halim, <salmanhalim AT gmail DOT com>

" Concatenates two strings, placing a space between them if neither is
" empty; if either is empty, the result is simply the non-empty one; if
" both are empty, returns the empty string.
function! <SID>AddWithSpace( original, addition, ... )
  let result        = ""
  let originalEmpty = a:original == ''
  let additionEmpty = a:addition == ''

  let separator = exists( "a:1" ) ? a:1 : " "

  if ( originalEmpty && additionEmpty )
    let result = ""
  elseif ( originalEmpty )
    let result = a:addition
  elseif ( additionEmpty )
    let result = a:original
  else
    let result = a:original . separator . a:addition
  endif

  return result
endfunction

function! <SID>GetAndSeparator()
  return GetVar#GetVar( "numberToEnglish_useAnd" ) ? " " . GetVar#GetVar( "numberToEnglish_and" ) . " " : " "
endfunction

function! <SID>GetHyphenSeparator()
  return GetVar#GetVar( "numberToEnglish_useHyphen" ) ? "-" : " "
endfunction

function! <SID>GetList( name, isOrdinal )
  return GetVar#GetVar( "numberToEnglish_" . (a:isOrdinal ? "ordinal_" : "") . a:name )
endfunction
" Converts a number between 1 and 999 to its English equivalent.
" Anything else (such as 0 or 1000) gets the empty string.
"
" If standalone is 1, assumes that numbers such as 23 should be returned as "twenty three"; otherwise, 23 gets returned as "and twenty three", if
" g:numberToEnglish_useAnd is set.
function! <SID>SmallNumberToEnglish( num, standalone, round, isOrdinal )
  " We ignore the 0-based position so we don't have to keep
  " subtracting from our results when we look a number up here.
  let theNum = a:num

  " If not standalone, we start with a space to allow for "and" and separators to come into play--we'll trim that out at the end.
  let result = GetVar#GetVar( "numberToEnglish_useAnd" ) && a:round == 0 && !a:standalone ? " " : ""

  if ( theNum >= 1 || theNum < 1000 )
    let digitsList = <SID>GetList( "digits", a:isOrdinal )
    let teensList  = <SID>GetList( "teens", a:isOrdinal )
    let tensList   = <SID>GetList( "tens", a:isOrdinal )

    let digit = theNum / 100
    let theNum = theNum % 100

    if ( digit > 0 )
      let result = <SID>AddWithSpace( result, <SID>GetList( "digits", 0 )[ digit ] . " " . <SID>GetList( "hundred", a:isOrdinal && theNum == 0 ) )
    endif

    " We can skip the whole thing if the number passed in is an
    " even multiple of a hundred, such as 500.
    if ( theNum > 0 )
      if ( theNum < 10 )
        " Single digit
        let result = <SID>AddWithSpace( result, digitsList[ theNum ], <SID>GetAndSeparator() )
      elseif ( theNum > 10 && theNum < 20 )
        " Teens
        let result = <SID>AddWithSpace( result, teensList[ theNum - 10 ], <SID>GetAndSeparator() )
      else
        " Regular two-digit number; either 10 or between 20 and 99.
        let digit = theNum / 10
        let theNum = theNum % 10

        if ( theNum > 0 )
          let result = <SID>AddWithSpace( result, <SID>GetList( "tens", 0 )[ digit ], <SID>GetAndSeparator() )
          let result = <SID>AddWithSpace( result, digitsList[ theNum ], <SID>GetHyphenSeparator() )
        else
          let result = <SID>AddWithSpace( result, tensList[ digit ], <SID>GetAndSeparator() )
        endif
      endif
    endif
  endif

  " Trim initial spaces, if we put any in for the "and" work.
  return substitute( result, '^\s\+', '', '' )
endfunction

" Converts the given integer (negatives are allowed) to its English
" equivalent; for example, numberToEnglish( -234 ) returns "negative
" two hundred thirty four".
function! <SID>Render( num, isCapitalize, isOrdinal )
  let theNum     = a:num
  let result = ""

  if ( theNum == 0 )
    let result = <SID>GetList( "zero", a:isOrdinal )
  else
    let isNegative = theNum < 0

    if ( isNegative )
      let theNum = abs( theNum )
    endif

    " Starting from the right, take at most three digits from the
    " number and process those; the first time around, we leave
    " them as is.  The second time, we put the word "thousand"
    " after them; the word "million" gets appended the third time.
    " If someone wants billions, the process just gets repeated one
    " more time.
    let i = 0
    while ( i < len( <SID>GetList( "scale", 0 ) ) )
      let triplet = theNum % 1000
      let theNum  = theNum / 1000

      " Skip any empty portions, such as for 1000 or 1000234.
      if ( triplet > 0 )
        let tripletToEnglish = <SID>SmallNumberToEnglish( triplet, theNum == 0, i, ( a:isOrdinal && i == 0 ) )

        let scale = <SID>GetList( "scale", (result == '' && a:isOrdinal ) )[ i ]
        if ( scale != '' )
          let tripletToEnglish .= " " . scale
        endif

        let result = <SID>AddWithSpace( tripletToEnglish, result, ( stridx(result, GetVar#GetVar( "numberToEnglish_and" ) ) == 0 ? " " : ", " ) )
      endif

      let i += 1
    endwhile

    if ( isNegative )
      let result = GetVar#GetVar( "numberToEnglish_negative" ) . " " . result
    endif
  endif

  if ( a:isCapitalize )
    let result = toupper( result[ 0 ] ) . substitute( result, '.', '', '' )
  endif

  return result
endfunction

" Converts the given integer (negatives are allowed) to its English equivalent;
" for example, NumberToEnglish#Cardinal( -234 ) returns "negative two hundred
" thirty four".
function! NumberToEnglish#Cardinal( num, ... )
  return <SID>Render( a:num, a:0 && a:1, 0 )
endfunction

" Converts the given integer to its English ordinal; for example,
" NumberToEnglish#Ordinal( 234 ) returns "two hundred thirty fourth".
function! NumberToEnglish#Ordinal( num, ... )
  return <SID>Render( a:num, a:0 && a:1, 1 )
endfunction
