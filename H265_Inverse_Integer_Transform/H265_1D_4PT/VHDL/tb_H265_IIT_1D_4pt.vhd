--****************************************************************************
--Description:
--
--	TESTBENCH for H265 INVERSE INTEGER TRANSFORM - 4 POINT
--
--****************************************************************************
--Revision: 1.0
--July 20,2021
--Transformvid Corp
--office:  949-873-5088
--email:  support@transformvid.com
--Disclaimer:
--THIS SOFTWARE AVAILABLE ON THIS SITE IS PROVIDED "AS IS" AND
--ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
--ARE DISCLAIMED.
--Copyright 2021 Transformvid Corp. All rights reserved.
--
--Comment:	
--This code performs the 1-D transform of H265 standard on a 1 x 4 block of data.
--Input data is 16 bits: f(i)
--Output data is 16 bits: m(i)
--A4 is the 4x4 matrix
--Matrix equation is shown below:

--[m(0)  m(1)  m(2)  m(3)] = [f(0)  f(1)  f(2)  f(3)] x A4
--	 _				       _
--	|	64	64	64	64	|
-- A4 =	|	83	36	-36	-83	| 
--	|	64	-64	-64	64	|	
--	|_	36	-83	83	-36    _|
--	 				       
--------------------------------------

--First stage: (intermediate values are k(i))

--k(0) = f(0) x 64 + f(2) x 64
--k(1) = f(0) x 64 - f(2) x 64
--k(2) = f(1) x 36 - f(3) x 83
--k(3) = f(1) x 83 + f(3) x 36

--Second stage:
--m(0) = k(0) + k(3)	--verified to matrix equation
--m(1) = k(1) + k(2)	--verified to matrix equation
--m(2) = k(1) - k(2)	--verified to matrix equation
--m(3) = k(0) - k(3)	--verified to matrix equation

--multipliers needed:
	--83 =	64 + 16 + 2 + 1
	--36= 	32 + 4

---------------------------------------
--VHDL code starts here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.numeric_std.ALL;
USE ieee.numeric_bit.ALL;
USE ieee.std_logic_signed.ALL;


ENTITY test_tb IS
END test_tb;

ARCHITECTURE behavior OF test_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT H265_1D_4pt 
    
    PORT(
    	--inputs 	
    	clk: 	IN std_logic;
    	reset: 	IN std_logic;
    	f: 	IN std_logic_vector(15 downto 0);
    	dienb:	IN std_logic;
    	  
    	--outputs 
    
    	m: 		OUT std_logic_vector(15 downto 0);
    	mem_addr:	OUT std_logic_vector(4 downto 0);
    	dovalid:	OUT std_logic;
    	dovalid_row:	OUT std_logic
        );
    END COMPONENT;
    
signal  f: std_logic_vector(15 downto 0);    
signal  m: std_logic_vector(15 downto 0);

   	--declare inputs and initialize them
signal clk 		: std_logic := '0';
signal reset 		: std_logic := '0';
signal dienb 		: std_logic := '0';  
signal dovalid		: std_logic := '0';
signal dovalid_row	: std_logic := '0';

   
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: H265_1D_4pt PORT MAP (

	clk		=>clk,
	reset		=>reset,
	f		=>f,	
	dienb		=>dienb,
	m		=>m,
	dovalid 	=>dovalid,
	dovalid_row 	=>dovalid_row
	);
    	    

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        clk <= '0';
        wait for 10 ns;  --for 10 ns signal is '0'.
        clk <= '1';
        wait for 10 ns;  --for next 10 ns signal is '1'.
   end process;
   
  Input: process 
    begin
  	wait until dienb='1';	
   	wait for 20 ns;
   	wait for 20 ns;		
     	f	<= x"0001";	wait for 20 ns; 
  	f	<= x"0005";	wait for 20 ns; 
  	f	<= x"0007";	wait for 20 ns; 
  	f	<= x"0003";	wait for 20 ns; 
    	--start test2
  	f	<= x"FFFF";	wait for 20 ns; 			
  	f	<= x"FFFB";	wait for 20 ns; 	
  	f	<= x"FFF9";	wait for 20 ns; 			
  	f	<= x"FFFD";	wait for 20 ns; 	
    	--start test3
  	f	<= x"000F";	wait for 20 ns; 			
  	f	<= x"000B";	wait for 20 ns; 	
  	f	<= x"FFFF";	wait for 20 ns; 			
  	f	<= x"FFFD";	wait for 20 ns; 	
    	--start test4
  	f	<= x"0011";	wait for 20 ns; 			
  	f	<= x"0022";	wait for 20 ns; 	
  	f	<= x"0033";	wait for 20 ns; 			
  	f	<= x"0044";	wait for 20 ns; 	
  	--start test5
  	f	<= x"FFF3";	wait for 20 ns; 			
  	f	<= x"FFF1";	wait for 20 ns; 	
  	f	<= x"FFF0";	wait for 20 ns; 			
  	f	<= x"FFF2";	wait for 20 ns; 	
 
  
  --repeat tests above
  	--start test5
   	wait until dienb = '1';
   	wait for 20 ns;
   	wait for 20 ns;		
     	f	<= x"0001";	wait for 20 ns; 
  	f	<= x"0005";	wait for 20 ns; 
  	f	<= x"0007";	wait for 20 ns; 
  	f	<= x"0003";	wait for 20 ns; 
    	--start test6
  	f	<= x"FFFF";	wait for 20 ns; 			
  	f	<= x"FFFB";	wait for 20 ns; 	
  	f	<= x"FFF9";	wait for 20 ns; 			
  	f	<= x"FFFD";	wait for 20 ns; 	
    	--start test7
  	f	<= x"000F";	wait for 20 ns; 			
  	f	<= x"000B";	wait for 20 ns; 	
  	f	<= x"FFFF";	wait for 20 ns; 			
  	f	<= x"FFFD";	wait for 20 ns; 	
    	--start test8
  	f	<= x"0011";	wait for 20 ns; 			
  	f	<= x"0022";	wait for 20 ns; 	
  	f	<= x"0033";	wait for 20 ns; 			
  	f	<= x"0044";	wait for 20 ns; 	
  	--start test9
  	f	<= x"0001";	wait for 20 ns; 			
  	f	<= x"0005";	wait for 20 ns; 	
  	f	<= x"0007";	wait for 20 ns; 			
  	f	<= x"0003";	wait for 20 ns; 
  	--start test10
   	f	<= x"FFFF";	wait for 20 ns; 			
  	f	<= x"FFFB";	wait for 20 ns; 	
  	f	<= x"FFF9";	wait for 20 ns; 			
  	f	<= x"FFFD";	wait for 20 ns; 	
    	--start test11
  	f	<= x"000F";	wait for 20 ns; 		
  	f	<= x"000B";	wait for 20 ns; 	
  	f	<= x"FFFF";	wait for 20 ns; 			
  	f	<= x"FFFD";	wait for 20 ns; 	
    	--start test12
  	f	<= x"0000";	wait for 20 ns; 			
  	f	<= x"0000";	wait for 20 ns; 	
  	f	<= x"0000";	wait for 20 ns; 			
  	f	<= x"0000";	wait for 20 ns;   
  
  --this is end of test
  	wait;

    end process;

 Output: process
    begin
    	wait until dovalid_row='1';
		wait for 10 ns; assert (m=9 AND dovalid_row='1') REPORT "ERROR in TEST 1: m0 failed" SEVERITY error; wait for 10 ns;--f3 -1			
		wait for 10 ns; assert (m=3 AND dovalid_row='1') REPORT "ERROR in TEST 1: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
		wait for 10 ns; assert (m=1 AND dovalid_row='1') REPORT "ERROR in TEST 1: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
		wait for 10 ns; assert (m=1 AND dovalid_row='1') REPORT "ERROR in TEST 1: m3 failed" SEVERITY error; wait for 10 ns;--f2 -3	
 	 REPORT "TEST 1: completed. Output Data and dovalid have been checked.";
  		wait for 10 ns; assert (m=-9 AND dovalid_row='1')REPORT "ERROR in TEST 2: m0 failed" SEVERITY error; wait for 10 ns;--f3 +1			
  		wait for 10 ns; assert (m=-3 AND dovalid_row='1')REPORT "ERROR in TEST 2: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
  		wait for 10 ns; assert (m=-1 AND dovalid_row='1')REPORT "ERROR in TEST 2: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
  		wait for 10 ns; assert (m=-1 AND dovalid_row='1')REPORT "ERROR in TEST 2: m3 failed" SEVERITY error; wait for 10 ns;--f2 +3	
 	REPORT "TEST 2: completed. Output Data and dovalid have been checked.";
  		wait for 10 ns; assert (m=9 AND dovalid_row='1')  REPORT "ERROR in TEST 3: m0 failed" SEVERITY error; wait for 10 ns;--f3 +1			
  		wait for 10 ns; assert (m=-6 AND dovalid_row='1') REPORT "ERROR in TEST 3: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
  		wait for 10 ns; assert (m=8 AND dovalid_row='1')  REPORT "ERROR in TEST 3: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
  		wait for 10 ns; assert (m=-13 AND dovalid_row='1')REPORT "ERROR in TEST 3: m3 failed" SEVERITY error; wait for 10 ns;--f2 +3	
 	REPORT "TEST 3: completed. Output Data and dovalid have been checked.";
   		wait for 10 ns; assert (m=86 AND dovalid_row='1') REPORT "ERROR in TEST 4: m0 failed" SEVERITY error; wait for 10 ns;--f3 0			
   		wait for 10 ns; assert (m=-10 AND dovalid_row='1')REPORT "ERROR in TEST 4: m1 failed" SEVERITY error; wait for 10 ns;--f1 0	
   		wait for 10 ns; assert (m=-7 AND dovalid_row='1') REPORT "ERROR in TEST 4: m2 failed" SEVERITY error; wait for 10 ns;--f0 0			
   		wait for 10 ns; assert (m=33 AND dovalid_row='1') REPORT "ERROR in TEST 4: m3 failed" SEVERITY error; wait for 10 ns;--f2 0	
	REPORT "TEST 4: completed. Output Data and dovalid have been checked.";
 
	wait until dovalid_row='1';
		wait for 10 ns; assert (m=9 AND dovalid_row='1') REPORT "ERROR in TEST 5: m0 failed" SEVERITY error; wait for 10 ns;--f3 -1			
		wait for 10 ns; assert (m=3 AND dovalid_row='1') REPORT "ERROR in TEST 5: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
		wait for 10 ns; assert (m=1 AND dovalid_row='1') REPORT "ERROR in TEST 5: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
		wait for 10 ns; assert (m=1 AND dovalid_row='1') REPORT "ERROR in TEST 5: m3 failed" SEVERITY error; wait for 10 ns;--f2 -3	
 	 REPORT "TEST 5: completed. Output Data and dovalid have been checked.";
  		wait for 10 ns; assert (m=-9 AND dovalid_row='1')REPORT "ERROR in TEST 6: m0 failed" SEVERITY error; wait for 10 ns;--f3 +1			
  		wait for 10 ns; assert (m=-3 AND dovalid_row='1')REPORT "ERROR in TEST 6: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
  		wait for 10 ns; assert (m=-1 AND dovalid_row='1')REPORT "ERROR in TEST 6: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
  		wait for 10 ns; assert (m=-1 AND dovalid_row='1')REPORT "ERROR in TEST 6: m3 failed" SEVERITY error; wait for 10 ns;--f2 +3	
 	REPORT "TEST 6: completed. Output Data and dovalid have been checked.";
  		wait for 10 ns; assert (m=9 AND dovalid_row='1')  REPORT "ERROR in TEST 7: m0 failed" SEVERITY error; wait for 10 ns;--f3 +1			
  		wait for 10 ns; assert (m=-6 AND dovalid_row='1') REPORT "ERROR in TEST 7: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
  		wait for 10 ns; assert (m=8 AND dovalid_row='1')  REPORT "ERROR in TEST 7: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
  		wait for 10 ns; assert (m=-13 AND dovalid_row='1')REPORT "ERROR in TEST 7: m3 failed" SEVERITY error; wait for 10 ns;--f2 +3	
 	REPORT "TEST 7: completed. Output Data and dovalid have been checked.";
   		wait for 10 ns; assert (m=86 AND dovalid_row='1') REPORT "ERROR in TEST 8: m0 failed" SEVERITY error; wait for 10 ns;--f3 0			
   		wait for 10 ns; assert (m=-10 AND dovalid_row='1')REPORT "ERROR in TEST 8: m1 failed" SEVERITY error; wait for 10 ns;--f1 0	
   		wait for 10 ns; assert (m=-7 AND dovalid_row='1') REPORT "ERROR in TEST 8: m2 failed" SEVERITY error; wait for 10 ns;--f0 0			
   		wait for 10 ns; assert (m=33 AND dovalid_row='1') REPORT "ERROR in TEST 8: m3 failed" SEVERITY error; wait for 10 ns;--f2 0	
	REPORT "TEST 8: completed. Output Data and dovalid have been checked.";
  		wait for 10 ns; assert (m=9 AND dovalid_row='1')REPORT "ERROR in TEST 9: m0 failed" SEVERITY error; wait for 10 ns;--f3 +1			
  		wait for 10 ns; assert (m=3 AND dovalid_row='1')REPORT "ERROR in TEST 9: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
  		wait for 10 ns; assert (m=1 AND dovalid_row='1')REPORT "ERROR in TEST 9: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
  		wait for 10 ns; assert (m=1 AND dovalid_row='1')REPORT "ERROR in TEST 9: m3 failed" SEVERITY error; wait for 10 ns;--f2 +3	
 	REPORT "TEST 9: completed. Output Data and dovalid have been checked.";
  		wait for 10 ns; assert (m=-9 AND dovalid_row='1')  REPORT "ERROR in TEST 10: m0 failed" SEVERITY error; wait for 10 ns;--f3 +1			
  		wait for 10 ns; assert (m=-3 AND dovalid_row='1') REPORT "ERROR in TEST 10: m1 failed" SEVERITY error; wait for 10 ns;--f1 -5	
  		wait for 10 ns; assert (m=-1 AND dovalid_row='1')  REPORT "ERROR in TEST 10: m2 failed" SEVERITY error; wait for 10 ns;--f0 -7			
  		wait for 10 ns; assert (m=-1 AND dovalid_row='1')REPORT "ERROR in TEST 10: m3 failed" SEVERITY error; wait for 10 ns;--f2 +3	
 	REPORT "TEST 10: completed. Output Data and dovalid have been checked.";
   		wait for 10 ns; assert (m=9 AND dovalid_row='1') REPORT "ERROR in TEST 11: m0 failed" SEVERITY error; wait for 10 ns;--f3 0			
   		wait for 10 ns; assert (m=-6 AND dovalid_row='1')REPORT "ERROR in TEST 11: m1 failed" SEVERITY error; wait for 10 ns;--f1 0	
   		wait for 10 ns; assert (m=8 AND dovalid_row='1') REPORT "ERROR in TEST 11: m2 failed" SEVERITY error; wait for 10 ns;--f0 0			
   		wait for 10 ns; assert (m=-13 AND dovalid_row='1') REPORT "ERROR in TEST 11: m3 failed" SEVERITY error; wait for 10 ns;--f2 0	
	REPORT "TEST 11: completed. Output Data and dovalid have been checked.";


	REPORT "ALL TESTS COMPLETED. If No errors then PASS.";

 
 	wait;	
  
    end process;

  -- Test process
  test_proc: process
   begin 
   	dienb <='0';
   	reset <= '1';

   	wait for 10 ns;
   	reset <= '0';  
 	--start test1  
 	wait for 120ns;		
 	wait for 10 ns;
 	dienb <= '1';
 	wait for 20 ns;
 	wait for 20 ns;		
 	
 	wait for 400 ns;	--wait for 5 tests to run 5x4x20ns

--repeat tests above
	dienb <= '0';
	wait for 1000 ns;
	--start test5
 	dienb <= '1';
 	wait for 20 ns;
 	wait for 20 ns;		
 	
 	wait for 640 ns;	--wait for 8 tests to run 8x4x20ns
 	

--this is end of test
	dienb <= '0';
	
	wait;	

  end process;

END;

--VHDL code ends here