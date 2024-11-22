function b = pm(matrix,rownames,colnames,flag_as_cellstr,precision)

eval(default('colnames','{[]}','flag_as_cellstr','0','precision','4'));

b = print_matrix(matrix,rownames,colnames,flag_as_cellstr,precision);
