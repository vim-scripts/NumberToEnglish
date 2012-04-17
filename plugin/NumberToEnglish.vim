" -*- vim -*-
" (C) 2009 by Salman Halim, <salmanhalim AT gmail DOT com>

" Version 1.5
"
" Added parallel function and mappings for ordinal numbers ("forty-second"),
" also configurable via g:numberToEnglish_ordinal_... variables.
" Made remaining hard-coded words configurable via variables
" g:numberToEnglish_zero, g:numberToEnglish_negative.
" Allowed to use hyphen separator for numbers in range 21-99;
" g:numberToEnglish_useHyphen.
" Split into plugin and autoload script to minimize footprint.
" Change default to let g:numberToEnglish_useAnd = 1
" Fix additional comma in "one thousand, and one".
"
" Version 1.4
"
" Added an option to put in the word "and" (nine hundred AND twenty); off by default to retain old behavior:
"
" let g:numberToEnglish_useAnd = 1
"
" Added another configuration variable (French, in this example):
"
" let g:numberToEnglish_and = "et"
"
" Sections are now separated by commas; for example, "12345" becomes "twelve thousand, three hundred and forty five"
"
" Version 1.3
"
" Made the plugin accept global values for overriding the returned string; useful for changing the language, for example. Place the following in your _vimrc for
" French:
"
" let g:numberToEnglish_digits = [ "", "un",   "deux",  "trois",  "quatre",   "cinq",      "six",      "sept",         "huit",         "neuf" ]
" let g:numberToEnglish_teens  = [ "", "onze", "douze", "treize", "quatorze", "quinze",    "seize",    "dix-sept",     "dix-huit",     "dix-neuf" ]
" let g:numberToEnglish_tens   = [ "", "dix",  "vingt", "trente", "quarante", "cinquante", "soixante", "soixante dix", "quatre vingt", "quatre vingt dix" ]
"
" let g:numberToEnglish_scale = [ "", "mille", "million", "billion" ]
"
" let g:numberToEnglish_hundred = "cent"
"
" This change necessitates the use of GetVar (http://vim.sourceforge.net/scripts/script.php?script_id=353). Technically, the usage of GetVar allows the setting
" of any combination of these variables on a per-window, buffer or tab level (allowing different languages, capitalizations, etc., depending upon the buffer
" type, for example).
"
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

" Only set up these variables if their corresponding versions don't already exist (in _vimrc, for example).
if ( !exists( "g:numberToEnglish_digits" ) )
  let g:numberToEnglish_digits = [ "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" ]
endif
if ( !exists( "g:numberToEnglish_ordinal_digits" ) )
  let g:numberToEnglish_ordinal_digits = [ "", "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth" ]
endif

if ( !exists( "g:numberToEnglish_teens" ) )
  let g:numberToEnglish_teens = [ "", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen" ]
endif
if ( !exists( "g:numberToEnglish_ordinal_teens" ) )
  let g:numberToEnglish_ordinal_teens = [ "", "eleventh", "twelfth", "thirteenth", "fourteenth", "fifteenth", "sixteenth", "seventeenth", "eighteenth", "nineteenth" ]
endif

if ( !exists( "g:numberToEnglish_tens" ) )
  let g:numberToEnglish_tens = [ "", "ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety" ]
endif
if ( !exists( "g:numberToEnglish_ordinal_tens" ) )
  let g:numberToEnglish_ordinal_tens = [ "", "tenth", "twentieth", "thirtieth", "fortieth", "fiftieth", "sixtieth", "seventieth", "eightieth", "ninetieth" ]
endif

if ( !exists( "g:numberToEnglish_scale" ) )
  let g:numberToEnglish_scale = [ "", "thousand", "million", "billion" ]
endif
if ( !exists( "g:numberToEnglish_ordinal_scale" ) )
  let g:numberToEnglish_ordinal_scale = [ "", "thousandth", "millionth", "billionth" ]
endif

if ( !exists( "g:numberToEnglish_hundred" ) )
  let g:numberToEnglish_hundred = "hundred"
endif
if ( !exists( "g:numberToEnglish_ordinal_hundred" ) )
  let g:numberToEnglish_ordinal_hundred = "hundredth"
endif

if ( !exists( "g:numberToEnglish_zero" ) )
  let g:numberToEnglish_zero = "zero"
endif
if ( !exists( "g:numberToEnglish_ordinal_zero" ) )
  let g:numberToEnglish_ordinal_zero = "zeroth"
endif

if ( !exists( "g:numberToEnglish_and" ) )
  let g:numberToEnglish_and = "and"
endif

if ( !exists( "g:numberToEnglish_useAnd" ) )
  let g:numberToEnglish_useAnd = 1
endif

if ( !exists( "g:numberToEnglish_useHyphen" ) )
  let g:numberToEnglish_useHyphen = 1
endif

if ( !exists( "g:numberToEnglish_negative" ) )
  let g:numberToEnglish_negative = "negative"
endif

" Mappings
imap <Plug>NumberToEnglish <c-o>diw<c-r>=NumberToEnglish#Cardinal( '<c-r>*' )<cr>
imap <Plug>DNumberToEnglish <c-o>diw<c-r>=NumberToEnglish#Cardinal( '<c-r>*' )<cr> (<c-r>*)
imap <Plug>CNumberToEnglish <c-o>diw<c-r>=NumberToEnglish#Cardinal( '<c-r>*', 1 )<cr>
imap <Plug>DCNumberToEnglish <c-o>diw<c-r>=NumberToEnglish#Cardinal( '<c-r>*', 1 )<cr> (<c-r>*)

imap <Plug>OrdinalToEnglish <c-o>diw<c-r>=NumberToEnglish#Ordinal( '<c-r>*' )<cr>
imap <Plug>DOrdinalToEnglish <c-o>diw<c-r>=NumberToEnglish#Ordinal( '<c-r>*' )<cr> (<c-r>*)
imap <Plug>COrdinalToEnglish <c-o>diw<c-r>=NumberToEnglish#Ordinal( '<c-r>*', 1 )<cr>
imap <Plug>DCOrdinalToEnglish <c-o>diw<c-r>=NumberToEnglish#Ordinal( '<c-r>*', 1 )<cr> (<c-r>*)
