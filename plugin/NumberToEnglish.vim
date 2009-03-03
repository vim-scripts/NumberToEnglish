" -*- vim -*-
" (C) 2009 by Salman Halim, <salmanhalim AT gmail DOT com>

" Version 1.2
"
" Added two new mappings:
"
" <Plug>DNumberToEnglish and <Plug>DCNumberToEnglish -- the D is short for "Detailed".
"
" Differs from the versions without the D in that it places the original number at the end of the expanded version:
"
" Thus, 12341234 becomes twelve million three hundred forty one thousand two hundred thirty four (12341234).
"
" Version 1.1
"
" Took the hard-coded values out of the functions into script-local variables -- no sense defining them every time.
"
" Version 1.0
"
" Converts a number (such as -1234) to English (negative one thousand two hundred thirty four); handles the biggest integer Vim can work with (billions).
"
" This actually figures out the English value by crunching the numbers (not through abbreviations) and thus doesn't have any startup overhead.
"
" Usage: call the function NumberToEnglish and pass it the number; optionally, a second parameter can be passed in which, if not 1, will cause the return
" value's first letter to be capitalized (Two hundred thirty four vs. two hundred thirty four).
"
" Two insert-mode mappings have been provided for convenience to make this happen on the currently typed number while typing.
"
" <Plug>NumberToEnglish: converts the (positive only) number to English
"
" <Plug>CNumberToEnglish: converts the (positive only) number to English, capitalizing the first letter
"
" Just drop it into your plugin directory and, if you like, set up the mappings; for example:
"
" imap <leader>ne <Plug>NumberToEnglish
" imap <leader>nE <Plug>CNumberToEnglish

imap <Plug>NumberToEnglish <c-o>diw<c-r>=NumberToEnglish( '<c-r>*' )<cr>
imap <Plug>DNumberToEnglish <c-o>diw<c-r>=NumberToEnglish( '<c-r>*' )<cr> (<c-r>*)
imap <Plug>CNumberToEnglish <c-o>diw<c-r>=NumberToEnglish( '<c-r>*', 1 )<cr>
imap <Plug>DCNumberToEnglish <c-o>diw<c-r>=NumberToEnglish( '<c-r>*', 1 )<cr> (<c-r>*)

" Concatenates two strings, placing a space between them if neither is
" empty; if either is empty, the result is simply the non-empty one; if
" both are empty, returns the empty string.
function! <SID>AddWithSpace( original, addition )
  let result        = ""
  let originalEmpty = a:original == ''
  let additionEmpty = a:addition == ''

  if ( originalEmpty && additionEmpty )
    let result = ""
  elseif ( originalEmpty )
    let result = a:addition
  elseif ( additionEmpty )
    let result = a:original
  else
    let result = a:original . " " . a:addition
  endif

  return result
endfunction

let s:digits = [ "", "one",    "two",    "three",    "four",     "five",    "six",     "seven",     "eight",    "nine" ]
let s:teens  = [ "", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen" ]
let s:tens   = [ "", "ten",    "twenty", "thirty",   "forty",    "fifty",   "sixty",   "seventy",   "eighty",   "ninety" ]

let s:scale = [ "", "thousand", "million", "billion" ]

" Converts a number between 1 and 999 to its English equivalent.
" Anything else (such as 0 or 1000) gets the empty string.
function! SmallNumberToEnglish( num )
  " We ignore the 0-based position so we don't have to keep
  " subtracting from our results when we look a number up here.
  let theNum = a:num

  let result = ""

  if ( theNum >= 1 || theNum < 1000 )
    let digit = theNum / 100

    if ( digit > 0 )
      let result = <SID>AddWithSpace( result, s:digits[ digit ] . " hundred" )
    endif

    let theNum = theNum % 100

    " We can skip the whole thing if the number passed in is an
    " even multiple of a hundred, such as 500.
    if ( theNum > 0 )
      if ( theNum < 10 )
        " Single digit
        let result = <SID>AddWithSpace( result, s:digits[ theNum ] )
      elseif ( theNum > 10 && theNum < 20 )
        " Teens
        let result = <SID>AddWithSpace( result, s:teens[ theNum - 10 ] )
      else
        " Regular two-digit number; either 10 or between 20 and 99.
        let digit = theNum / 10
        let theNum = theNum % 10

        let result = <SID>AddWithSpace( result, s:tens[ digit ] )

        if ( theNum > 0 )
          let result = <SID>AddWithSpace( result, s:digits[ theNum ] )
        endif
      endif
    endif
  endif

  return result
endfunction

" Converts the given integer (negatives are allowed) to its English
" equivalent; for example, numberToEnglish( -234 ) returns "negative
" two hundred thirty four".
function! NumberToEnglish( num, ... )
  let theNum     = a:num
  let capitalize = exists( "a:1" ) && a:1

  let result = ""

  if ( theNum == 0 )
    let result = "zero"
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
    while ( i < len( s:scale ) )
      let triplet = theNum % 1000
      let theNum  = theNum / 1000

      " Skip any empty portions, such as for 1000 or 1000234.
      if ( triplet > 0 )
        let tripletToEnglish = SmallNumberToEnglish( triplet )

        if ( s:scale[ i ] != '' )
          let tripletToEnglish .= " " . s:scale[ i ]
        endif

        let result = <SID>AddWithSpace( tripletToEnglish, result )
      endif

      let i += 1
    endwhile

    if ( isNegative )
      let result = "negative " . result
    endif
  endif

  if ( capitalize )
    let result = toupper( result[ 0 ] ) . substitute( result, '.', '', '' )
  endif

  return result
endfunction
