grammar CalculetteMVaP;
// règles de la grammaire
@header {
import java.util.HashMap;
}

@parser::members
{
    public class TableSymboles {
        private HashMap<String, Integer> tablesSymboles = new HashMap<String, Integer>();
        private int n = 0;
        public Integer getAdresse(String s) { return tablesSymboles.get(s); }
        public int getTaille() { return tablesSymboles.keySet().size(); }
        public void putAdresse(String s) {
            if (tablesSymboles.get(s) != null)
                System.err.println("Vous ne pouvez pas décalrer "+ s +" plusieurs fois!");
                //System.exit(1);
            tablesSymboles.put(s, n++);
        }
        public String toString() { return tablesSymboles.toString(); }
    }
    private TableSymboles tableSymboles = new TableSymboles();

    public class Label {
        private int x = 0;
        public int nextLabel() {
            int next = x++;
            return next;
        }
    }

    private Label label = new Label();

}

calcul returns [String code]
@init{ $code = new String(); }
@after{ System.out.println($code); }
: (decl { $code += $decl.code; })*
  NEWLINE*
  (instruction { $code += $instruction.code; })* { $code += "  HALT"; }
;

finInstruction
: (NEWLINE | ';')+
;

decl returns [ String code ]
: TYPE IDENTIFIANT finInstruction
{
$code = ($TYPE.text.equals("int") ? "  PUSHI 0\n" : "  PUSHF 0.0\n");
tableSymboles.putAdresse($IDENTIFIANT.text);
}
;

instruction returns [ String code ]
: expression finInstruction { $code = $expression.code; }
| assignation finInstruction { $code = $assignation.code; }
| io finInstruction { $code = $io.code; }
| boucle { $code = $boucle.code; }
| structureConditionnelle { $code = $structureConditionnelle.code; }
| finInstruction { $code=""; }
;

expression returns [ String code ]
: arith { $code = $arith.code+"  WRITEF\n  FREE "+Integer.toString(2+tableSymboles.getTaille())+"\n"; }
| bool { $code = $bool.code+"  WRITE\n  POP\n"; }
| cmp { $code = $cmp.code+"  WRITE\n  POP\n"; }
;

condition returns [ String code ]
: arith { $code = $arith.code; }
| bool { $code = $bool.code; }
| cmp { $code = $cmp.code; }
;

assignation returns [ String code ]
: IDENTIFIANT '=' arith { $code = $arith.code+"  FTOI\n"+"  STOREG "+tableSymboles.getAdresse($IDENTIFIANT.text).toString()+"\n"; }
;


arith returns [ String code ]
: '-'arith { $code = "  PUSHF 0.0\n" + $arith.code + "  FSUB\n"; }
| '(' arith ')' { $code = $arith.code; }
| a=arith '/' b=arith { $code = $a.code + $b.code + "  FDIV\n"; }
| a=arith '*' b=arith { $code = $a.code + $b.code + "  FMUL\n"; }
| a=arith '-' b=arith { $code = $a.code + $b.code + "  FSUB\n"; }
| a=arith '+' b=arith { $code = $a.code + $b.code + "  FADD\n"; }
| ENTIER { $code = "  PUSHI " + $ENTIER.text + "\n  ITOF\n"; }
| IDENTIFIANT { $code = "  PUSHG "+tableSymboles.getAdresse($IDENTIFIANT.text).toString()+"\n  ITOF\n"; }
;

bool returns [ String code ]
: 'not' bool { $code = $bool.code + "  PUSHI 1\n  INF\n"; }
| '(' bool ')' { $code = $bool.code; }
| a=bool 'or' b=bool { $code = $a.code + $b.code + "  ADD\n  PUSHI 1\n  SUPEQ\n"; }
| a=bool 'and' b=bool { $code = $a.code + $b.code + "  MUL\n"; }
| BOOLEAN { $code = "  PUSHI " + ($BOOLEAN.text.equals("true") ? "1\n" : "0\n"); }
| cmp { $code = $cmp.code; }
;

cmp returns [ String code ]
: a=cmp '==' b=cmp { $code = $a.code + $b.code + "  FEQUAL\n" ; }
| a=cmp '>' b=cmp { $code = $a.code + $b.code + "  FSUP\n"; }
| a=cmp '<' b=cmp { $code = $a.code + $b.code + "  FINF\n"; }
| a=cmp '>=' b=cmp { $code = $a.code + $b.code + "  FSUPEQ\n"; }
| a=cmp '<=' b=cmp { $code = $a.code + $b.code + "  FINFEQ\n"; }
| a=cmp ('<>'|'!=') b=cmp { $code = $a.code + $b.code + "  FNEQ\n"; }
| arith { $code = $arith.code; }
;

io returns [ String code ]
: READ '(' IDENTIFIANT ')'
{
    int  at = tableSymboles.getAdresse($IDENTIFIANT.text);
    $code="  READ" ;
    $code+="\n";
    $code+="  STORE" + (at < 0 ? "L" : "G") +" " + at + "\n";
}
| WRITE '('arith ')' {$code = $arith.code+ "  FTOI" + "\n"+"  WRITE" + "\n"+ "  POP" +  "\n";}
;

instructionThen returns [ String code ]
: instruction { $code = $instruction.code; }
| bloc finInstruction { $code = $bloc.code; }
;

bloc returns [ String code ]
@init { $code = new String(); }
: '{' (instruction { $code += $instruction.code; })* '}' NEWLINE*
;

boucle returns [ String code ]
: 'while' '(' condition ')' instructionThen
{
    int before = label.nextLabel();
    int after = label.nextLabel();
    $code = "Label " + Integer.toString(before) + ":\n" + $condition.code + "  JUMPF " +
            Integer.toString(after) + "\n";
    $code += $instructionThen.code + "  JUMP " + Integer.toString(before) + "\n";
    $code += "Label " + Integer.toString(after) + ":\n";
}
;

structureConditionnelle returns [ String code ]
: 'if' '(' condition ')' NEWLINE* instructionThen
{
    int numLabel = label.nextLabel();
    $code = $condition.code + "  JUMPF " + Integer.toString(numLabel) + "\n";
    $code += $instructionThen.code + "Label " + Integer.toString(numLabel) + ":\n";
}
| 'if' '(' condition ')' NEWLINE* a=instructionThen 'else' NEWLINE* b=instructionThen
{
    int numLabel1 = label.nextLabel();
    int numLabel2 = label.nextLabel();
    $code = $condition.code + "  JUMPF " + Integer.toString(numLabel1) + "\n";
    $code += $a.code + "  JUMP " + Integer.toString(numLabel2) + "\n";
    $code += "Label " + Integer.toString(numLabel1) + ":\n";
    $code += $b.code + "Label " + Integer.toString(numLabel2) + ":\n";
}
;

// lexer
TYPE : 'int' | 'float' ; // pour pouvoir gérer des floats
BOOLEAN : 'true' | 'false';
WRITE : 'println'|'writeln';
READ : 'readln';
IDENTIFIANT : (('a'..'z'|'A'..'Z')+('0'..'9')*)+;
NEWLINE : '\r'? '\n' ;
WS : (' '|'\t')+ -> skip;
ENTIER : ('0'..'9')+;
UNMATCH : . -> skip;

