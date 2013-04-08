%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <math.h>
	void obtenerAtributo();
	char* substr(char* cadena, int comienzo, int longitud);
	void aumentarFilaColumna();
	void escribirErrores(int tipo);//0 = Se esperaba token 1 = Se esperaba atributo 2 Carcacter invalido
	int fila=1;
	int columna=0;
	char* infoToken;
	FILE *errores;

	
	typedef union {
		char *stringConstant;
	} YYSTYPE;

 
	// yylval contiene informacion del lexema escaneado

	extern YYSTYPE yylval;
	
%}

%x etiquetaAbierta
%x tokenLeido
%x comentarios

atributo 		([a-z]|":")+"="("\""){texto}("\"")
abrirEtiqueta   "<"
cerrarEtiqueta  ">"
token           "br /"|"?xml"|"html"|"title"|"head"|"a"|"body"|"option"|a|abbr|acronym|address|applet|area|article|aside|audio|b|base|basefont|bdi|bdo|big|blockquote|body|br|button|canvas|caption|center|cite|code|col|colgroup|command|datalist|dd|del|details|dfn|dialog|dir|div|dl|dt|em|embed|fieldset|figcaption|figure|footer|font|form|frame|frameset|h1|h2|h3|h4|h5|h6|head|header|hgroup|hr|html|i|iframe|img|input|ins|kbd|keygen|label|legend|li|link|map|mark|menu|meta|meter|nav|noframes|noscript|object|ol|optgroup|option|output|p|param|pre|progress|q|rp|rt|ruby|s|samp|script|section|select|small|source|span|strike|strong|style|sub|summary|sup|table|tbody|td|textarea|tfoot|th|thead|time|title|tr|track|tt|u|ul|var|video|wbr
texto			([A-z]|[0-9]|"."|";"|"\\"|"-"|"?"|"/"|" "|":"|"\n")*
espacio         " "
comillasTexto   "\""{texto}"\""



%%



"<!--"                     			 {printf("%s","Comentarios");
									aumentarFilaColumna();
									BEGIN(comentarios);
									}
									
<comentarios>.						{aumentarFilaColumna();}
<comentarios>"\n"                   {aumentarFilaColumna();}
<comentarios>"-->"					{printf("%s","Fin comentarios");
									aumentarFilaColumna();
									BEGIN(INITIAL);
									}


"<!DOCTYPE html PUBLIC "{comillasTexto}"\n"{comillasTexto}">"   {printf("%s","DOCTYPE");
																aumentarFilaColumna();}
						


{abrirEtiqueta}						{printf("%s","<");
									aumentarFilaColumna();
									printf("%i",columna);
									BEGIN(etiquetaAbierta);
									}
									


<etiquetaAbierta>{token}			{
									aumentarFilaColumna();
									BEGIN(tokenLeido);
									infoToken= substr(yytext,0,yyleng);
									printf("%s%s","T_Etiqueta = ",infoToken);
									}

<etiquetaAbierta>"/"{token}			{printf("%s%s","T_",yytext);
									aumentarFilaColumna();}
<etiquetaAbierta>{cerrarEtiqueta}|"?"{cerrarEtiqueta}    	{printf("%s",yytext);
															aumentarFilaColumna();
															BEGIN(INITIAL);
															
															
											}
											
<etiquetaAbierta>{texto}	{
							printf("%s%i%s%i","fila",fila,"columna",columna);
							escribirErrores(0);
							aumentarFilaColumna();}




<tokenLeido>{espacio}{atributo}     	 {printf("%s",yytext);aumentarFilaColumna();
										}
<tokenLeido>{cerrarEtiqueta}|"?"{cerrarEtiqueta}     {printf("%s",">");
														aumentarFilaColumna();
														BEGIN(INITIAL);
							
											}

<tokenLeido>{texto}		{
							printf("%s%i%s%i","fila",fila,"columna",columna);
							escribirErrores(1);
							aumentarFilaColumna();
						
						}


<tokenLeido>.|\n		{
						if(yytext=="\n"){
							printf("%s%i%s%i","fila",fila,"columna",columna);
							escribirErrores(1);
							aumentarFilaColumna();
						}
						else{
							printf("%s%i%s%i","fila",fila,"columna",columna);
							escribirErrores(1);
							aumentarFilaColumna();
						}
						}
											

\n					{aumentarFilaColumna();}

.					{
					printf("%s%i%s%i","fila",fila,"columna",columna);
					escribirErrores(2);
					aumentarFilaColumna();}					


%% 
void escribirErrores(int tipo){
	char* error;
	if(tipo==0){
		error = (char*)malloc(sizeof(char) * 17);
		error = "se esperaba token";
	}
	else if(tipo==1){
		error = (char*)malloc(sizeof(char) * 19);
		error = "se esperaba atributo";
	}
	else{
		error =(char*)malloc(sizeof(char) * 17);
		error = "Caracter invalido";
	}
	errores = fopen("errores.txt","a+"); /* apend file (add text to 
	a file or create a file if it does not exist.*/ 
	fprintf(errores,"%s%s%s%i%s%i%s","Error tipo ",error,", en la fila ",fila," columna, ",columna, "\n"); /*writes*/ 
	fclose(errores); /*done!*/ 
}

void obtenerAtributo(){
	int i;
	for(i=0;i < yyleng;i++){
		if(yytext[i] == '\"')
		printf("%s",substr(yytext,i,yyleng-1));
	}
}

char* substr(char* cadena, int comienzo, int longitud)
{
	if (longitud == 0) 
		longitud = strlen(cadena)-comienzo-1;
	char *nuevo = (char*)malloc(sizeof(char) * longitud);
	strncpy(nuevo, cadena + comienzo, longitud);
	return nuevo;
}

void aumentarFilaColumna(){
	int i;
	for(i=0;i < yyleng;i++){
		if(yytext[i] == '\n'){
			columna=0;
			fila++;
		}
		else{
			columna++;
		}
	}
		
		

}


