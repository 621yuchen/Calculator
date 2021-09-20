grammar Calculette;
// règles de la grammaire
start
: calcul EOF
;
calcul
: NEWLINE*
| (instruction)*
;

instruction returns [ int val ]
: arith { System.out.println($arith.val); }
| bool { System.out.println($bool.bl); }
| cmp { System.out.println($cmp.bl); }
;

arith returns [ float val ]
: '-'arith { $val = 0 - $arith.val; }
| '(' arith ')' { $val=$arith.val; }
| a=arith '/' b=arith { $val=$a.val /$b.val; }
| a=arith '*' b=arith { $val=$a.val *$b.val; }
| a=arith '-' b=arith { $val=$a.val -$b.val; }
| a=arith '+' b=arith { $val=$a.val +$b.val; }
| ENTIER { $val = Integer.parseInt($ENTIER.text); }
| arith '/' '0' { System.out.println("error"); $val = 99999999; }
;


bool returns [ Boolean bl ]
: 'not' bool { $bl = !$bool.bl; }
| '(' bool ')' { $bl = $bool.bl; }
| a=bool 'or' b=bool { $bl = $a.bl || $b.bl; }
| a=bool 'and' b=bool { $bl = $a.bl && $b.bl; }
| BOOLEAN { $bl = Boolean.parseBoolean($BOOLEAN.text); }
| cmp { $bl = $cmp.bl; }
;

cmp returns [ Boolean bl, float val ]
: a=cmp '==' b=cmp { $bl = ($a.val == $b.val); }
| a=cmp '>' b=cmp { $bl = ($a.val > $b.val); }
| a=cmp '<' b=cmp { $bl = ($a.val < $b.val); }
| a=cmp '>=' b=cmp { $bl = ($a.val >= $b.val); }
| a=cmp '<=' b=cmp { $bl = ($a.val <= $b.val); }
| a=cmp '<>' b=cmp { $bl = ($a.val != $b.val); }
| arith { $val = $arith.val; }
;

NEWLINE : '\r'? '\n' -> skip;
WS : (' '|'\t')+ -> skip;
BOOLEAN : 'true' | 'false';
ENTIER : ('0'..'9')+;
UNMATCH : . -> skip;


