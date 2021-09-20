//import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.ANTLRFileStream;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;

public class MainCalculette {
	public static void main(String args[]) throws Exception {
		CalculetteLexer lex;
		if (args.length == 0)
			lex = new CalculetteLexer(new ANTLRInputStream(System.in));
		else
			lex = new CalculetteLexer(new ANTLRFileStream(args[0]));
		CommonTokenStream tokens = new CommonTokenStream(lex);
		CalculetteParser parser = new CalculetteParser(tokens);
		try {
			parser.start();
			// start l’axiome de la grammaire
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
