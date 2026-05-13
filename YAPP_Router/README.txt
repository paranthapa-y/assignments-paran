Path for LABS which are compiled : /home/vdudyala/Desktop/UVM_LAB/ 


-----------------To Run UVM LABS-------------- 

For all labs I have added Do files so we can run do files directly on Questa by using cmd : do compile.do
  
Changes made : 

1. For all labs included directories in do file  which are needed to compile top file 
2. 
  a.  From lab07 to lab09c there are no hbus , channel directories in labs , they are available in Solutions directory , so included them in do file .  
  b.  In Top wrapper missing hbus and channel  .svf files , So include them in top_wrapper.sv (Check top_dut.sv and add includes which are missing in top_wrapper.sv) 



