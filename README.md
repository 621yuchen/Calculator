# Calculator
__本文只介绍此程序在linux系统下运行方式（Windows下可以使用IDEA）__

## antlr4安装及配置
1. 在主目录下创建一个bin文件夹
2. 将`antlr-4.7.2-complete.jar`包复制到该文件夹内
3. 找到系统文件`.bashrc`(或`.profile`)，并将以下代码添加到该文件内：
```
export CLASSPATH=.:~/bin/antlr-4.7.2-complete.jar:~/bin/MVaP.jar:$CLASSPATH

alias antlr4='java -Xmx500M -cp "~/bin/antlr-4.7.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "~/bin/antlr-4.7.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
```

## 通过g4文件生成相关解析文件
`Calculette.g4` 内部包含四则运算、布尔运算、逻辑运算等语法。是生成词法解析规则和语法解析规则的基础文件。
`CalculetteMVaP.g4` 文件在`Calculette.g4`文件的基础上，加入了if、while、变量声明和赋值等语法，并生成MVaP代码。~（MVaP语言是基于栈式架构的指令集，在此不多做介绍）~

1. 运行```antlr4 Calculette.g4```生成相关文件
2. 运行```javac Calculette*.java```编译生成的相关文件

## 运行程序
__方法一：__ 
1. 运行`grun Calculette start -gui`命令。‘start’是g4文件开始的标识。-gui是生成树的命令，可省
2. 输入想要运算的表达式+回车，如：`1+1*2 == 4 and true`
3. 按下ctrl+D

__方法二__
1. 复制`MainCalculette.java`和`MainCalculetteMVaP.java`文件到g4生成文件文件夹
2. javac编译Main文件
3. 运行编译后的字节码文件
4. 输入想要运算的表达式+回车，如：`1+1*2 == 4 and true`
5. 按下ctrl+D

