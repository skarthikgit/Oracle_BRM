/*
Copyright (C) 2007 Karthikeyan Shanmugam
 
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

*/

%{
#include "opcode_parser.h"
%}

NUMBER [0-9]
SPACE  [ \t]
FIELDS PIN_FLD_[A-Z_]*
DATATYPE INT|ENUM|DECIMAL|STR|BINSTR|TSTAMP|POID|ARRAY|SUBSTRUCT|BUF|ERRBUF
BRACE  \[{SPACE}*([0-9]+|\*){SPACE}*
BRACE_TEXT \].*$

%%
^{SPACE}*{NUMBER}+{SPACE}+ 	{ 
	call(1,yytext) ; }
{FIELDS}{SPACE}+		{
	call(2,yytext) ; 
}
{DATATYPE}{SPACE}+		{
	call(3,yytext) ; 
}
{BRACE}				{
	call(4,yytext) ; 
}
{BRACE_TEXT}			{
	call(5,yytext) ; 
}
%%

int main(int argc, char **argv)
{
	char	*variable_list[MAX_VARIABLE_LENGTH] ;
	char	*ptr_flist[MAX_FLIST_LENGTH] ;

	if ( argc != 2 )
	{
		printf("USAGE <opcodegen> <OPCODE>\n") ;
		exit (11) ;
	}

	yylex () ;

	// print_list(start_node) ;

	parse_flist(start_node,ptr_flist,variable_list) ;
	variable_dec(variable_list) ;

	part_1() ;
	print_variables_dec(variable_list) ;
	part_2() ;
	print_flist(ptr_flist) ;
	part_3(argv[1]) ;

	exit (0) ;
}

void call(int type,char *text) 
{
	char 	*strip_text ;
	int 	inx1 = 0 ;

	strip_text = (char *)malloc(strlen(text)+1) ;
	if ( !strip_text )
	{
		printf("Memory Problem : 101\n") ;
		exit (101) ;
	}
	if (type == 4 )
	{
		while ( *text )
		{
			if ( *text != ' ' && *text != '[' )
			{
				strip_text[inx1++] = *text ;
			} 
			*text++ ;
		}
	}
	else if (type == 5 )
	{
		while ( *text == ' ' || *text == ']' )
		{
			*text++ ;
		}
		while ( strip_text[inx1++] = *text++ ) ;
	}
	else	
	{
		while ( *text )
		{
			if ( *text != ' ' )
			{
				strip_text[inx1++] = *text ;
			} 
			*text++ ;
		}
	}
	strip_text[inx1] = '\0' ;
	value_assignment(type,strip_text) ;
	free(strip_text) ;
}

void value_assignment(int type,char *text)
{
	static int field_chk = 0 ;

	if ( type == 1 )
	{
		field_chk = 0 ;
		g_level_str = (char *)malloc(strlen(text)+1 ) ;
		if ( !g_level_str)
		{
			/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
			printf("Memory Problem line: %d \n",__LINE__) ;
			exit (102) ;
		}
		strcpy(g_level_str,text) ;
		g_level = atoi(text) ;
		field_chk++ ;
	}
	else if ( type == 2 )
	{
		g_field_name = (char *)malloc(strlen(text)+1) ;
		if ( !g_field_name )
		{
			/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
			printf("Memory Problem line: %d \n",__LINE__) ;
			exit (102) ;
		}
		strcpy(g_field_name,text) ;
		field_chk++ ;
	}
	else if ( type == 3 )
	{
		g_datatype= (char *)malloc(strlen(text)+1) ;
		if ( !g_datatype)
		{
			/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
			printf("Memory Problem line: %d \n",__LINE__) ;
			exit (103) ;
		}
		strcpy(g_datatype,text) ;
		field_chk++ ;
	}
	else if ( type == 4 )
	{
		g_index = atoi(text) ;
		field_chk++ ;
	}
	else if ( type == 5 )
	{
		int n ;

		g_text_value = (char *)malloc(strlen(text)+1) ;
		if ( !g_text_value )
		{
			/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
			printf("Memory Problem line: %d \n",__LINE__) ;
			exit (104) ;
		}
		strcpy(g_text_value,text) ;
		for ( n = strlen(g_text_value)-1; n>=0; n--)
		{
			if ( g_text_value[n] != ' ' && g_text_value[n] != '\t' )
			{
				break ;
			}
		}
		g_text_value[n+1] = '\0' ;
		field_chk++ ;

		if ( field_chk == 5 )
		{
			build_list ( g_level, g_level_str, g_field_name, g_datatype, g_index, g_text_value, &list_header) ;
		}
		else
		{
			printf("Problem while parsing .please chk the format.\n") ;
		}
		free_global() ;
	}
}


void build_list ( int level, char *level_str, char *field_name, char *datatype, int index, char *text_value, 
		struct field_info_list **list_header)
{
        struct field_info_list *tmp_node ;

        tmp_node = (struct field_info_list *)malloc(sizeof(struct field_info_list)) ;
        if ( !tmp_node )
        {
                printf("Memory Problem : 101\n") ;
                exit (101) ;
        }
        tmp_node->level = level ;
        tmp_node->index = index ;

        tmp_node->level_str = (char *)malloc(strlen(level_str)+1) ;
        if ( !tmp_node->level_str )
	{
		/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
		printf("Memory Problem line: %d \n",__LINE__) ;
		exit (104) ;
	}

        tmp_node->field_name = (char *)malloc(strlen(field_name)+1) ;
        if ( !tmp_node->field_name )
	{
		/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
		printf("Memory Problem line: %d \n",__LINE__) ;
		exit (104) ;
	}
        
	tmp_node->datatype   = (char *)malloc(strlen(datatype)+1) ;
        if ( !tmp_node->datatype )
	{
		/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
		printf("Memory Problem line: %d \n",__LINE__) ;
		exit (105) ;
	}
        
	tmp_node->text_value = (char *)malloc(strlen(text_value)+1) ;
        if ( !tmp_node->text_value )
	{
		/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
		printf("Memory Problem line: %d \n",__LINE__) ;
		exit (106) ;
	}

        strcpy(tmp_node->level_str , level_str ) ;
        strcpy(tmp_node->field_name , field_name) ;
        strcpy(tmp_node->datatype , datatype) ;
        strcpy(tmp_node->text_value , text_value) ;

        tmp_node->next = NULL ;

        if ( *list_header == NULL )
        {
                start_node   = tmp_node ;
                *list_header = tmp_node ;
        }
        else
        {
                while ( (*list_header)->next )
                {
                        *list_header= (*list_header)->next ;
                }
                (*list_header)->next = tmp_node ;
        }
}

void free_global()
{
	g_level = 0 ;
	g_index = 0 ;
	if (g_level_str)
	{
		free (g_level_str) ;
		g_level_str= NULL ;
	}
	if (g_field_name)
	{
		free (g_field_name) ;
		g_field_name = NULL ;
	}
	if ( g_datatype )
	{
		free (g_datatype) ;
		g_datatype = NULL ;
	}
	if ( g_text_value )
	{
		free (g_text_value) ;
		g_text_value = NULL ;
	}
}

void print_list(struct field_info_list *pr_start)
{
        struct field_info_list *tmp_list ;

        tmp_list = pr_start ;

	/* printf("function name : %s ... %X ... %X\n",__FUNCTION__,tmp_list,pr_start) ; */
        while ( tmp_list )
        {
                printf("%d\n",tmp_list->level ) ;
                printf("%s\n",tmp_list->level_str ) ;
                printf("%s\n",tmp_list->field_name) ;
                printf("%s\n",tmp_list->datatype) ;
                printf("%d\n",tmp_list->index) ;
                printf("%s\n",tmp_list->text_value) ;
                tmp_list = tmp_list->next ;
        }
}

void parse_flist(struct field_info_list *pr_start,char **build_flist,char **var_list)
{
        struct field_info_list *tmp_list ;
	char 		*tmp_field ;
	char 		*token ;
	int 		poid_fields = 0 ;
	char 		*poid_val_1 ;
	char 		*poid_val_2 ;
	char		*flist_variable ;
	char		*flist_variable_arr ;
	char		num_to_str[256] ;
	char		flist_tmp[1024] ;
	
        tmp_list = NULL ;
	tmp_field = NULL ;
	token = NULL ;
	poid_val_1 = NULL ;
	poid_val_2 = NULL ;
	flist_variable = NULL ;
	flist_variable_arr = NULL ;
	flist_tmp[0] = '\0' ;

        tmp_list = pr_start ;

	/* printf("flist_0 = PIN_FLIST_CREATE(&errbuf) ;\n") ; */
	sprintf(flist_tmp,"\t%s","flist_in_0 = PIN_FLIST_CREATE(&errbuf) ;\n") ;
	build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
	if ( !build_flist[flist_length] )
	{
		printf("Mem problem : 111\n") ;
		exit (111) ;
	}
	strcpy(build_flist[flist_length],flist_tmp) ;
	flist_length ++ ;
	flist_tmp[0] = '\0' ;


	while ( tmp_list )
	{
		if ( flist_length > MAX_FLIST_LENGTH-1 || variable_length > MAX_VARIABLE_LENGTH-1  )
		{
			printf("It's design limitation. Input lines or ARRAY or SUBSTRUCT reach the upper bound.\n") ;
			printf("No. of lines parsed are %d and Max is %d\n",flist_length,MAX_FLIST_LENGTH) ;
			printf("No. of variables declared are %d and Max is %d\n",variable_length,MAX_VARIABLE_LENGTH) ;
			exit(3001) ;
		}

		/* Process the first element in the list with a condition that is POID type */
		if( !strcmp(tmp_list->datatype,"POID") )
		{
			token = NULL ;
			poid_fields = 0  ; 
			tmp_field = (char *)malloc(strlen(tmp_list->text_value)+1) ;
			if ( !tmp_field )
			{
				/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
				printf("Memory Problem line: %d \n",__LINE__) ;
				exit (1001) ;
			}
			strcpy(tmp_field,tmp_list->text_value) ;
			if ( !strcmp(tmp_field,"NULL") )
			{
				flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
				if ( !flist_variable)
				{
					printf("Memory Problem : 202\n") ;
					exit (202) ;
				}
				strcpy(flist_variable,"flist_in_") ;
				strcat(flist_variable,tmp_list->level_str) ;
				/* printf("PIN_FLIST_FLD_SET ( %s, %s, (void *) %s , &errbuf) ;\n",
					flist_variable,tmp_list->field_name,tmp_list->text_value) ; */
				sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, (void *) %s , &errbuf) ;\n", 
					flist_variable,tmp_list->field_name,tmp_list->text_value) ;
				build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
				if ( !build_flist[flist_length] )
				{
					printf("Mem problem : 111\n") ;
					exit (111) ;
				}
				strcpy(build_flist[flist_length],flist_tmp) ;
				flist_length++ ;
				flist_tmp[0] = '\0' ;

				free(flist_variable) ;
				tmp_list = tmp_list->next ;
				continue ;
			}
			token = strtok(tmp_field," ") ;
			if ( !token )
			{
				printf("POID does NOT carry enough parameters.\n") ;
				exit (1003) ;
			}

			poid_fields++ ; 
			while ( token = strtok(NULL," ") )
			{
				if ( poid_fields == 1 )
				{
					poid_val_1 = (char *)malloc(strlen(token)+1) ;
					if ( !poid_val_1 )
					{
						/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
						printf("Memory Problem line: %d \n",__LINE__) ;
						exit (1002) ;
					}
					strcpy(poid_val_1,token) ;
				}
				else if ( poid_fields == 2 )
				{
					poid_val_2 = (char *)malloc(strlen(token)+1) ;
					if ( !poid_val_2 )
					{
						/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
						printf("Memory Problem line: %d \n",__LINE__) ;
						exit (1003) ;
					}
					strcpy(poid_val_2,token) ;
				}
				poid_fields++ ; 
			}
			if ( poid_fields == 4 )
			{
				/* printf("poid_0 = PIN_POID_CREATE (db_no, \"%s\", (int64)%s, &errbuf) ;\n", 
					poid_val_1, poid_val_2) ; */

				sprintf(flist_tmp,"\tpoid_0 = PIN_POID_CREATE (db_no, \"%s\", (int64)%s, &errbuf) ;\n",
					poid_val_1, poid_val_2) ;
				build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
				if ( !build_flist[flist_length] )
				{
					printf("Mem problem : 111\n") ;
					exit (111) ;
				}
				strcpy(build_flist[flist_length],flist_tmp) ;
				flist_length++ ;
				flist_tmp[0] = '\0' ;

				flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
				if ( !flist_variable)
				{
					printf("Memory Problem : 202\n") ;
					exit (202) ;
				}
				strcpy(flist_variable,"flist_in_") ;
				strcat(flist_variable,tmp_list->level_str) ;
				/* printf("PIN_FLIST_FLD_SET ( %s, %s , (void *)poid_0, &errbuf) ;\n",
					flist_variable, tmp_list->field_name) ; */
				sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s , (void *)poid_0, &errbuf) ;\n",
					flist_variable, tmp_list->field_name) ;
				build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
				if ( !build_flist[flist_length] )
				{
					printf("Mem problem : 111\n") ;
					exit (111) ;
				}
				strcpy(build_flist[flist_length],flist_tmp) ;
				flist_length++ ;
				flist_tmp[0] = '\0' ;

				/* printf("PIN_POID_DESTROY (poid_0) ;\n") ; */
				sprintf(flist_tmp,"\tPIN_POID_DESTROY (poid_0, &errbuf) ;\n") ;
				build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
				if ( !build_flist[flist_length] )
				{
					printf("Mem problem : 111\n") ;
					exit (111) ;
				}
				strcpy(build_flist[flist_length],flist_tmp) ;
				flist_length++ ;
				flist_tmp[0] = '\0' ;

				/* printf("poid_0 = NULL ;\n") ; */
				sprintf(flist_tmp,"\t%s", "poid_0 = NULL ;\n") ;
				build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
				if ( !build_flist[flist_length] )
				{
					printf("Mem problem : 111\n") ;
					exit (111) ;
				}
				strcpy(build_flist[flist_length],flist_tmp) ;
				flist_length++ ;
				flist_tmp[0] = '\0' ;

				free(flist_variable) ;
			}
			else
			{
				printf("POID has %d parameters, it's NOT NULL .\n",poid_fields) ;
				flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;
                                if ( !flist_variable)
                                {
                                        printf("Memory Problem : 202\n") ;
                                        exit (202) ;
                                }
                                strcpy(flist_variable,"flist_in_") ;
                                strcat(flist_variable,tmp_list->level_str) ;
                                /* printf("PIN_FLIST_FLD_SET ( %s, %s, (void *) %s , &errbuf) ;\n",
                                        flist_variable,tmp_list->field_name,tmp_list->text_value) ; */
                                sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, NULL , &errbuf) ;\n",
                                        flist_variable,tmp_list->field_name) ;
                                build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
                                if ( !build_flist[flist_length] )
                                {
                                        printf("Mem problem : 111\n") ;
                                        exit (111) ;
                                }
                                strcpy(build_flist[flist_length],flist_tmp) ;
                                flist_length++ ;
                                flist_tmp[0] = '\0' ;

                                free(flist_variable) ;
			}
			free(tmp_field) ;
		}
		else if ( !strcmp(tmp_list->datatype,"ARRAY") )
		{
			/* datatype is ARRAY */
			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			
			itoa(tmp_list->level+1,num_to_str) ;
			flist_variable_arr = (char *)malloc(strlen("flist_in_")+strlen(num_to_str)+1) ;	
			if ( !flist_variable_arr )
			{
				printf("Memory Problem : 201\n") ;
				exit (201) ;
			}
			strcpy(flist_variable_arr,"flist_in_") ;
			strcat(flist_variable_arr,num_to_str) ;

			if ( tmp_list->level == variable_length )
			{
				sprintf(flist_tmp,"\tpin_flist_t	*%s = NULL ;\n",flist_variable_arr) ;
				var_list[variable_length] = (char *) malloc(strlen(flist_tmp)+1) ;
				if ( !var_list[variable_length] )
				{
					printf("Mem problem : 111\n") ;
					exit (111) ;
				}
				strcpy(var_list[variable_length],flist_tmp) ;
				variable_length++ ;
				flist_tmp[0] = '\0' ;
			}

			/* printf("%s = PIN_FLIST_ELEM_ADD (%s, %s, %d, &errbuf) ;\n",
				flist_variable_arr,flist_variable, tmp_list->field_name,tmp_list->index) ; */
			sprintf(flist_tmp,"\t%s = PIN_FLIST_ELEM_ADD (%s, %s, %d, &errbuf) ;\n",
				flist_variable_arr,flist_variable, tmp_list->field_name,tmp_list->index) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			/* printf("%s = PIN_FLIST_ELEM_ADD (%s, %s, %d, &errbuf) ;\n",
				flist_variable_arr,flist_variable, tmp_list->field_name,tmp_list->index) ; */
			/* 30-03-2007 : Appeared twice so the later is commented 
			sprintf(flist_tmp,"\t%s = PIN_FLIST_ELEM_ADD (%s, %s, %d, &errbuf) ;\n",
				flist_variable_arr,flist_variable, tmp_list->field_name,tmp_list->index) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;
			*/	

			free(flist_variable) ;
			free(flist_variable_arr) ;
		}
		else if ( !strcmp(tmp_list->datatype,"SUBSTRUCT") )
		{
			/* datatype is SUBSTR */
			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			
			itoa(tmp_list->level+1,num_to_str) ;
			flist_variable_arr = (char *)malloc(strlen("flist_in_")+strlen(num_to_str)+1) ;	
			if ( !flist_variable_arr )
			{
				printf("Memory Problem : 201\n") ;
				exit (201) ;
			}
			strcpy(flist_variable_arr,"flist_in_") ;
			strcat(flist_variable_arr,num_to_str) ;

			if ( tmp_list->level == variable_length )
			{
				sprintf(flist_tmp,"\tpin_flist_t	*%s = NULL ;\n",flist_variable_arr) ;
				var_list[variable_length] = (char *) malloc(strlen(flist_tmp)+1) ;
				if ( !var_list[variable_length] )
				{
					printf("Mem problem : 111\n") ;
					exit (111) ;
				}
				strcpy(var_list[variable_length],flist_tmp) ;
				variable_length++ ;
				flist_tmp[0] = '\0' ;
			}

			/* printf("%s = PIN_FLIST_SUBSTR_ADD (%s, %s, &errbuf) ;\n",
				flist_variable_arr,flist_variable, tmp_list->field_name) ; */
			sprintf(flist_tmp,"\t%s = PIN_FLIST_SUBSTR_ADD (%s, %s, &errbuf) ;\n",
				flist_variable_arr,flist_variable, tmp_list->field_name) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			free(flist_variable) ;
			free(flist_variable_arr) ;
		}
		else if ( !strcmp(tmp_list->datatype,"INT") )
		{
			/* printf("tmp_int = %s ;\n",tmp_list->text_value) ; */
			sprintf(flist_tmp,"\ttmp_int = %s ;\n",tmp_list->text_value) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			/* printf("PIN_FLIST_FLD_SET ( %s, %s, &tmp_int, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ; */
			sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, &tmp_int, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			free(flist_variable) ;
		}
		else if ( !strcmp(tmp_list->datatype,"DECIMAL") )
		{
			/* printf("tmp_deci = %s ;\n",tmp_list->text_value) ; */
			/* 20-08-2007 : DECIMAL was treated as INT 
			It's realized that DECIMAL must be treated as pointer */ 
			sprintf(flist_tmp,"\ttmp_deci = pin_decimal(\"%s\",&errbuf) ;\n",tmp_list->text_value) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			/* printf("PIN_FLIST_FLD_SET ( %s, %s, &tmp_deci, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ; */
			sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, (void *)tmp_deci, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			free(flist_variable) ;
		}
		else if ( !strcmp(tmp_list->datatype,"STR") )
		{
			/* datatype is STR */
			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			/* printf("PIN_FLIST_FLD_SET ( %s, %s, (void *) %s , &errbuf) ;\n",
				flist_variable,tmp_list->field_name,tmp_list->text_value) ; */
			sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, (void *) %s , &errbuf) ;\n",
				flist_variable,tmp_list->field_name,tmp_list->text_value) ; 
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			free(flist_variable) ;
		}
		else if ( !strcmp(tmp_list->datatype,"TSTAMP") )
		{
			token = NULL ;
			tmp_field = (char *)malloc(strlen(tmp_list->text_value)+1) ;
			if ( !tmp_field )
			{
				/* printf("Memory Problem line: %d function: %s\n",__LINE__,__FUNCTION__) ; */
				printf("Memory Problem line: %d \n",__LINE__) ;
				exit (1001) ;
			}
			strcpy(tmp_field,tmp_list->text_value) ;
			token = strtok(tmp_field,"()") ;
			if ( !token )
			{
				printf("TSTAMP may be empty.\n") ;
				exit(1002) ;
			}
			sprintf(flist_tmp, "\ttmp_time = %s ;\n",token) ;
                        build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
                        if ( !build_flist[flist_length] )
                        {
                                printf("Mem problem : 111\n") ;
                                exit (111) ;
                        }
                        strcpy(build_flist[flist_length],flist_tmp) ;
                        flist_length++ ;
                        flist_tmp[0] = '\0' ;
	
			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			/* printf("PIN_FLIST_FLD_SET ( %s, %s, &tmp_time, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ; */
			sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, &tmp_time, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			free(flist_variable) ;
			if ( tmp_field )
			{
				free (tmp_field) ;
			}
		}
		else if ( !strcmp(tmp_list->datatype,"ENUM") )
		{
			/* 20-08-2007 : The INT logic is pasted */
			/* printf("tmp_int = %s ;\n",tmp_list->text_value) ; */
			sprintf(flist_tmp,"\ttmp_int = %s ;\n",tmp_list->text_value) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			/* printf("PIN_FLIST_FLD_SET ( %s, %s, &tmp_int, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ; */
			sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, &tmp_int, &errbuf) ;\n",
				flist_variable,tmp_list->field_name) ;
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			free(flist_variable) ;
		}
		else if ( !strcmp(tmp_list->datatype,"BINSTR") )
		{
			printf("Token %s NOT parsed. Parsing logic yet to be defined.\n",tmp_list->datatype) ;
		}
		else if ( !strcmp(tmp_list->datatype,"BUF") )
		{
			/* datatype is BUF:	21-08-2007 */
			flist_variable = (char *)malloc(strlen("flist_in_")+strlen(tmp_list->level_str)+1) ;	
			if ( !flist_variable)
			{
				printf("Memory Problem : 202\n") ;
				exit (202) ;
			}
			strcpy(flist_variable,"flist_in_") ;
			strcat(flist_variable,tmp_list->level_str) ;
			/* printf("PIN_FLIST_FLD_SET ( %s, %s, (void *) %s , &errbuf) ;\n",
				flist_variable,tmp_list->field_name,tmp_list->text_value) ; */
			sprintf(flist_tmp,"\tPIN_FLIST_FLD_SET ( %s, %s, (void *) %s , &errbuf) ;\n",
				flist_variable,tmp_list->field_name,tmp_list->text_value) ; 
			build_flist[flist_length] = (char *) malloc(strlen(flist_tmp)+1) ;
			if ( !build_flist[flist_length] )
			{
				printf("Mem problem : 111\n") ;
				exit (111) ;
			}
			strcpy(build_flist[flist_length],flist_tmp) ;
			flist_length++ ;
			flist_tmp[0] = '\0' ;

			free(flist_variable) ;
			/* printf("Token %s NOT parsed. Parsing logic yet to be defined.\n",tmp_list->datatype) ; */
		}
		else if ( !strcmp(tmp_list->datatype,"ERRBUF") )
		{
			printf("Token %s NOT parsed. Parsing logic yet to be defined.\n",tmp_list->datatype) ;
		}
		else
		{
			printf("Unknown token %s to be parsed.\n",tmp_list->datatype) ;
		}
		tmp_list = tmp_list->next ;
	}
}

/* itoa() is taken from 'The C Programming Language : Second Edition' Page : 64 */
/* itoa : convert n to characters in s */
void itoa(int n,char s[])
{
	int i, sign ;

	if ( (sign = n) < 0 )		/* record sign */
	{
		n = -n ;		/* make n positive */
	}
	i = 0 ;
	do				/* generete digits in reverse order */
	{
		s[i++] = n%10 + '0' ;	/* get next digit */
	} while ( (n/=10)>0 );		/* delete it */
	
	if ( sign < 0 )
	{
		s[i++] = '-' ;
	}
	s[i] = '\0' ;
	reverse(s) ;
}

/* reverse() is taken from 'The C Programming Language : Second Edition' Page : 62 */
/* reverse : reverse string s in place */
void reverse(char s[])
{
	int c, i, j ;

	for ( i=0 , j=strlen(s)-1; i<j ; i++, j--)
	{
		c = s[i] ;
		s[i] = s[j] ;
		s[j] = c ;
	}
}

void print_flist(char **ptr_flist)
{
	int i = 0 ;

	printf("\n\n\t/* FLIST Construction */\n\n") ;
	while ( i < flist_length )
	{
		printf("%s",ptr_flist[i]) ;
		i++ ;
	}
}

void variable_dec(char **var_list)
{
	var_list[variable_length] = (char *) malloc(strlen("\tpin_flist_t	    *flist_in_0 = NULL ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tpin_flist_t     *flist_in_0 = NULL ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tpin_flist_t	    *flist_out = NULL ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tpin_flist_t     *flist_out = NULL ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tpcm_context_t   *ctxp = NULL ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tpcm_context_t   *ctxp = NULL ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tint64           db_no ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tint64           db_no ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tpin_errbuf_t    errbuf ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tpin_errbuf_t    errbuf ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tpoid_t          *poid_0 = NULL ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tpoid_t          *poid_0 = NULL ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\ttime_t          tmp_time = NULL ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\ttime_t          tmp_time = NULL ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tint32             tmp_int  = 0 ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tint32             tmp_int  = 0 ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tpin_buf_t *tmp_buf = NULL ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tpin_buf_t *tmp_buf = NULL ;\n") ;
	variable_length++ ;

	var_list[variable_length] = (char *) malloc(strlen("\tpin_decimal_t *tmp_deci  = NULL ;\n")+1) ;
	if ( !var_list[variable_length] )
	{
		printf("Mem Problem : 222\n") ;
		exit(222) ;
	}
	strcpy(var_list[variable_length],"\tpin_decimal_t *tmp_deci  = NULL ;\n") ;
	variable_length++ ;
}

void print_variables_dec(char **variable_list)
{
	int	i = 0 ;
	printf("\t/* Variable Declarations */\n\n") ;
	while ( i < variable_length )
	{
		printf("%s",variable_list[i]) ;
		i++ ;
	}
}

void    part_1()
{
        printf("#include <stdio.h>\n") ;
        printf("#include <stdlib.h>\n") ;

        printf("#include \"pcm.h\"\n") ;
        printf("#include \"pin_errs.h\"\n") ;
        printf("#include \"pinlog.h\"\n") ;
        printf("#include \"ops/cust.h\"\n") ;
	/* The following line is added on 24-04-2006 after getting compilation error while try to 
	execute PCM_OP_AR_GET_ACCT_BILLS. Debugged by Chokkathangam */
        printf("#include \"ops/ar.h\"\n") ;	
	printf("#include \"ops/subscription.h\"\n") ;	/* 13-09-2007: Karthik */
        printf("#include \"pin_cust.h\"\n") ;
        printf("#include \"pin_os.h\"\n\n") ;

        printf("int main(int argc,char **argv)\n") ;
        printf("{\n") ;
}


void    part_2()
{
        printf("\n\tPIN_ERR_CLEAR_ERR (&errbuf) ;\n") ;
        printf("\tPIN_ERR_SET_PROGRAM (argv[0]) ;\n") ;
        printf("\tPIN_ERR_SET_LEVEL (PIN_ERR_LEVEL_DEBUG) ;\n") ;

        printf("\t/* Openning DB connection */\n") ;
        printf("\tPCM_CONNECT (&ctxp, &db_no, &errbuf) ;\n") ;

        printf("\tif ( PIN_ERR_IS_ERR(&errbuf) )\n") ;
        printf("\t{\n") ;
        printf("\t\tPIN_ERR_LOG_EBUF(PIN_ERR_LEVEL_ERROR,\"Connection Open Error.\\n\",&errbuf) ;\n") ;
        printf("\t}\n") ;
        printf("\telse\n") ;
        printf("\t{\n") ;
        printf("\t\tPIN_ERR_LOG_MSG(PIN_ERR_LEVEL_DEBUG,\"Connection Open Success.\\n\") ;\n") ;
        printf("\t}\n") ;
}

void    part_3(char *opcode)
{
	printf("\n\tPIN_FLIST_PRINT(flist_in_0, NULL, &errbuf) ;\n") ;
        printf("\n\n\tPIN_ERR_LOG_FLIST(PIN_ERR_LEVEL_DEBUG,\"Input flist:\\n\",flist_in_0) ;\n") ;
        printf("\tif ( PIN_ERR_IS_ERR(&errbuf) )\n") ;
        printf("\t{\n") ;
        printf("\t\tPIN_ERR_LOG_EBUF(PIN_ERR_LEVEL_ERROR,\"Input flist Error.\\n\",&errbuf) ;\n") ;
        printf("\t}\n") ;

        printf("\t/* Execute PCM_OP for %s OPCODE */\n",opcode) ;
        printf("\tPCM_OP (ctxp, %s, 0, flist_in_0, &flist_out, &errbuf) ;\n",opcode) ;
        printf("\tif ( PIN_ERR_IS_ERR(&errbuf) )\n") ;
        printf("\t{\n") ;
        printf("\t\tPIN_ERR_LOG_EBUF(PIN_ERR_LEVEL_ERROR,\"PCM_OP Error.\\n\",&errbuf) ;\n") ;
        printf("\t}\n") ;
        printf("\telse\n") ;
        printf("\t{\n") ;
        printf("\t\tPIN_ERR_LOG_MSG(PIN_ERR_LEVEL_DEBUG,\"PCM_OP Success.\\n\") ;\n") ;
        printf("\t}\n") ;

        printf("\tPIN_ERR_LOG_FLIST(PIN_ERR_LEVEL_DEBUG,\"Output flist:\\n\",flist_out) ;\n") ;

        printf("\tPCM_CONTEXT_CLOSE (ctxp,0,&errbuf);\n") ;
        printf("\tif ( PIN_ERR_IS_ERR(&errbuf) )\n") ;
        printf("\t{\n") ;
        printf("\t\tPIN_ERR_LOG_EBUF(PIN_ERR_LEVEL_ERROR,\"Connection Close Error.\\n\",&errbuf) ;\n") ;
        printf("\t}\n") ;
        printf("\telse\n") ;
        printf("\t{\n") ;
        printf("\t\tPIN_ERR_LOG_MSG(PIN_ERR_LEVEL_DEBUG,\"Connection Close Success.\\n\") ;\n") ;
        printf("\t}\n") ;

        printf("\texit (0) ;\n") ;
        printf("}\n") ;
}


