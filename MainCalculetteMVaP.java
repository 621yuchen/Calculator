import org.antlr.v4.runtime.*;
public class MainCalculetteMVaP {
	public static void main(String args[]) throws Exception {
		CalculetteMVaPLexer lex;
		if (args.length == 0)
			lex = new CalculetteMVaPLexer(new ANTLRInputStream(System.in));
		else
			lex = new CalculetteMVaPLexer(new ANTLRFileStream(args[0]));
		CommonTokenStream tokens = new CommonTokenStream(lex);
		CalculetteMVaPParser parser = new CalculetteMVaPParser(tokens);
		try {
			parser.calcul();
			// start l’axiome de la grammaire
		} catch (RecognitionException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
