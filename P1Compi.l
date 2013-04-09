%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <math.h>
	char* substr(char* cadena, int comienzo, int longitud);
	void aumentarFilaColumna();
	void escribirErrores(int tipo);//0 = Se esperaba token 1 = Se esperaba atributo 2 = Carcacter invalido
	int fila=1;
	int columna=0;
	FILE *errores;
	
	
	
	
%}

%x etiquetaAbierta
%x tokenLeido
%x comentarios

atributo 		([a-z]|":")+"="{comillasTexto}
abrirEtiqueta   "<"
cerrarEtiqueta  ">"
etiqueta           "br /"|"hr /"|"?xml"|"html"|"title"|"head"|"a"|"body"|"option"|abbr|acronym|address|applet|area|article|aside|audio|b|base|basefont|bdi|bdo|big|blockquote|body|br|button|canvas|caption|center|cite|code|col|colgroup|command|datalist|dd|del|details|dfn|dialog|dir|div|dl|dt|em|embed|fieldset|figcaption|figure|footer|font|form|frame|frameset|h1|h2|h3|h4|h5|h6|head|header|hgroup|hr|html|i|iframe|img|input|ins|kbd|keygen|label|legend|li|link|map|mark|menu|meta|meter|nav|noframes|noscript|object|ol|optgroup|option|output|p|param|pre|progress|q|rp|rt|ruby|s|samp|script|section|select|small|source|span|strike|strong|style|sub|summary|sup|table|tbody|td|textarea|tfoot|th|thead|time|title|tr|track|tt|u|ul|var|video|wbr
texto			([A-z]|[0-9]|{caracteresPermitidos})*
textoConEspacio  (texto|" ")*
caracteresPermitidos "."|";"|"\\"|"-"|"?"|"/"|":"|"&"|"!"|"#"|"$"|"%"|"'"|"("|")"|"*"|"+"|","|"@"|"["|"]"|"^"|"_"|"{"|"}"|"|"
espacio         " "
comillasTexto   "\""({texto}|" ")*"\""




%%



"<!--"                     			{
										printf("%s","T_AbrirComentarios\n");
										aumentarFilaColumna();
										BEGIN(comentarios);
									}
									
<comentarios>{texto}				{
										aumentarFilaColumna();
										printf("%s","T_Comentarios\n");
										
									}
<comentarios>"-->"					{
										printf("%s","T_CerrarComentarios\n");
										aumentarFilaColumna();
										BEGIN(INITIAL);
									}



"<!DOCTYPE html PUBLIC "{comillasTexto}\n{comillasTexto}">" {
																	printf("%s%s%s","T_DOCTYPE = ",yytext,"\n");
																	aumentarFilaColumna();
																}

{abrirEtiqueta}						{
										printf("%s","T_AbrirEtiqueta\n");
										aumentarFilaColumna();
										BEGIN(etiquetaAbierta);
									}
									


<etiquetaAbierta>{etiqueta}			{
										aumentarFilaColumna();
										printf("%s%s%s","T_Etiqueta = ",yytext,"\n");
										BEGIN(tokenLeido);
									}

<etiquetaAbierta>"/"{etiqueta}			{
										printf("%s%s%s","T_Etiqueta = ",yytext,"\n");
										aumentarFilaColumna();
									}
<etiquetaAbierta>{cerrarEtiqueta}|"?"{cerrarEtiqueta}    	{
																printf("%s","T_CerrarEtiqueta\n");
																aumentarFilaColumna();
																BEGIN(INITIAL);
															}
<etiquetaAbierta>{espacio}	{
								printf("%s%s%s","T_Espacio = ",yytext,"\n");
								escribirErrores(0);
								aumentarFilaColumna();
							}
							
<etiquetaAbierta>"\n"	{
								printf("%s","T_NuevaLInea\n ");
								escribirErrores(0);
								aumentarFilaColumna();
							}
																		
<etiquetaAbierta>{texto}	{
								printf("%s%s%s","T_Texto = ",yytext,"\n");
								escribirErrores(0);
								aumentarFilaColumna();
							}

<etiquetaAbierta>.	{
								printf("%s%s%s","T_CaracterInvalido = ",yytext,"\n");
								escribirErrores(0);
								aumentarFilaColumna();
							}



<tokenLeido>{espacio}{atributo}     	 {
											printf("%s%s%s","T_Atributo = ",yytext,"\n");
											aumentarFilaColumna();
										}
<tokenLeido>{cerrarEtiqueta}|"?"{cerrarEtiqueta}     {
														printf("%s","T_CerrarEtiqueta\n");
														aumentarFilaColumna();
														BEGIN(INITIAL);
													}
<tokenLeido>{espacio}	{
								printf("%s%s%s","T_Espacio = ",yytext,"\n");
								escribirErrores(1);
								aumentarFilaColumna();
							}
							
<tokenLeido>"\n"	{
								printf("%s","T_NuevaLInea\n");
								escribirErrores(1);
								aumentarFilaColumna();
							}

<tokenLeido>{texto}		{
							printf("%s%s%s","T_Texto = ",yytext,"\n");
							escribirErrores(1);
							aumentarFilaColumna();
						}


<tokenLeido>.|\n		{
							if(yytext=="\n"){
								printf("%s","T_NuevaLinea \n");
								escribirErrores(1);
								aumentarFilaColumna();
							}
							else{
								printf("%s%s%s","T_CarcaterInvalido = ",yytext,"\n");
								escribirErrores(1);
								aumentarFilaColumna();
							}
						}
						
\n                                  {
										printf("%s","T_NuevaLinea\n");
										aumentarFilaColumna();
									}
											

({texto}|" ")*					{
										printf("%s%s%s","T_Texto = ",yytext,"\n");
										aumentarFilaColumna();
										BEGIN(INITIAL);
									}

.					{
					printf("%s%s%s","T_CarcaterInvalido = ",yytext,"\n");
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
