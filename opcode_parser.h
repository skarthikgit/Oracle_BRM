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

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define	MAX_FLIST_LENGTH	2048
#define	MAX_VARIABLE_LENGTH	128	

struct	field_info_list	{
	int	level ;
	char	*level_str ;		/* 1 : 10-04-2007 */
	char	*field_name ;
	char	*datatype ;
	int	index ;
	char	*text_value ;
	struct	field_info_list	*next ;
} ;

int	g_level = 0 ;
char	*g_level_str ;			/* 1 : 10-04-2007 */
char	*g_field_name ;
char	*g_datatype ;
int	g_index = 0 ;
char	*g_text_value ;

struct  field_info_list  *list_header = NULL ;
struct  field_info_list  *start_node  = NULL ;

int	flist_length = 0 ;
int	variable_length = 0 ;

void 	call(int,char *) ;
void 	value_assignment(int ,char *) ;
void 	build_list ( int , char *, char *, char *, int , char *, struct field_info_list**) ;
void 	free_global() ;
void 	print_list(struct field_info_list *) ;
void	parse_flist(struct field_info_list *,char **,char **) ;
void 	itoa(int ,char []) ;
void 	reverse(char []) ;
void 	print_flist(char **) ;
void	variable_dec(char **) ;
void	print_variables_dec(char **) ;
void	part_1() ;
void	part_2() ;
void	part_3(char *) ;


/*
	History Of Changes
	------- -- -------
	
1:	A new filed 'level_str' is added to 'field_info_list'.
	This will be used directly to construct the FLIST variable.
*/

