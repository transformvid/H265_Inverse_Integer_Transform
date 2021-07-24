--****************************************************************************
--Description:
--
--	H265 INVERSE INTEGER TRANSFORM - 4 POINT PIPELINED
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
--This code performs the 1-D transform of H265 standard on a 4 x 4 block of data.
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
--
--This version is pipelined:
--Order of input is : f3, f1, f0, f2		
--Order of output is :m0, m1, m2, m3		

--------------------------------------

--First pipe stage:
--g2 = f1 x 36  
--g3 = f1 x 83
--g4 = f3 x 83
--g5 = f3 x 36

--Second pipe stage
--k(0) = f(0) x 64 + f(2) x 64		
--k(1) = f(0) x 64 - f(2) x 64		
--k(2) = f(1) x 36 - f(3) x 83		
--k(3) = f(1) x 83 + f(3) x 36	


--Third pipe stage:
--m(0) = k(0) + k(3)	
--m(1) = k(1) + k(2)	
--m(2) = k(1) - k(2)	
--m(3) = k(0) - k(3)	

--multipliers needed:
	--83 =	64 + 16 + 2 + 1
	--36= 	32 + 4

---------------------------------------
---------------------------------------
--VHDL code starts here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.numeric_std.ALL;
USE ieee.numeric_bit.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY H265_1D_4pt IS
PORT(
	--inputs 	

	clk:	IN std_logic;
	reset:	IN std_logic;
	f: 	IN std_logic_vector(15 downto 0);
	dienb:	IN std_logic;
	
	--outputs 

	m: 	OUT std_logic_vector(15 downto 0);
	mem_addr:OUT std_logic_vector(4 downto 0);
	dovalid:OUT std_logic;
	dovalid_row:OUT std_logic
	);
END H265_1D_4pt;



ARCHITECTURE rtl of H265_1D_4pt IS
signal reg_g4 	:std_logic_vector(22 downto 0);
signal reg_g5 	:std_logic_vector(22 downto 0);
signal reg_g2 	:std_logic_vector(22 downto 0);
signal reg_g3 	:std_logic_vector(22 downto 0);

signal reg_k0 	:std_logic_vector(22 downto 0);
signal reg_k1 	:std_logic_vector(22 downto 0);
signal reg_k2 	:std_logic_vector(22 downto 0);
signal reg_k3 	:std_logic_vector(22 downto 0);
signal reg_k3_trans2 	:std_logic_vector(22 downto 0);

signal reg_inp	:std_logic_vector(15 downto 0);
signal reg_inp2 :std_logic_vector(15 downto 0);

signal m0_inp 	:std_logic_vector(22 downto 0);
signal mem_addr_int	:std_logic_vector(4 downto 0);
signal dienb_sr		:std_logic_vector(23 downto 0); 
--define states
type state_type is (START,STATE_0,STATE_1,STATE_2,STATE_3,STATE_4,STATE_5,STATE_6,STATE_7);
signal current_state, next_state : state_type ;
signal count 		:std_logic_vector(1 downto 0);
signal count_inp 	:std_logic_vector(1 downto 0);

BEGIN
mem_addr 	<= mem_addr_int;
reg_inp		<= f;					
m 		<= m0_inp(22 downto 7);
dovalid 	<= dienb_sr(15);			
dovalid_row 	<= dienb_sr(5);				

--process to update state
state_reg : process (clk, reset)
	begin
	if (reset='1') then
		current_state <= START;		
		reg_g2 		<= (others =>'0');
		reg_g3 		<= (others =>'0');
		reg_g4 		<= (others =>'0');
		reg_g5		<= (others =>'0');
		reg_k0 		<= (others =>'0');
		reg_k1 		<= (others =>'0');
		reg_k2 		<= (others =>'0');
		reg_k3 		<= (others =>'0');
		reg_k3_trans2 	<= (others =>'0');
		reg_inp2 	<= (others =>'0');		
		mem_addr_int	<= "01010";		
		dienb_sr	<= (others =>'0');
		count	 	<= (others =>'0');
	elsif clk'event and clk='1' then
		current_state 	<= next_state;
		reg_inp2 	<= reg_inp;			
		mem_addr_int	<= mem_addr_int + 1;
		count	 	<= count_inp;
		CASE current_state IS
			when START   =>
				dienb_sr 	<= 	"000000000000000000000001"		;	 
				mem_addr_int <= "01011";	--change for dienb
				
			when STATE_0 =>
				reg_k0 		<= (reg_inp(15)&reg_inp&"000000")+ (reg_inp2(15)&reg_inp2&"000000");	
	        		reg_k1 		<= (reg_inp2(15)&reg_inp2&"000000") - (reg_inp(15)&reg_inp&"000000");
	        		dienb_sr 	<= dienb_sr(22 downto 0) & dienb;  --change for dienb and below states
	        		
			when STATE_1 =>
				reg_g4 		<= (reg_inp(15)&reg_inp&"000000") + (reg_inp(15)&reg_inp(15)&reg_inp(15)&reg_inp&"0000") +(reg_inp&"0") + reg_inp;
				reg_g5 		<= (reg_inp(15)&reg_inp(15)&reg_inp&"00000") + (reg_inp&"00");
				dienb_sr 	<= dienb_sr(22 downto 0) & dienb;
			
			when STATE_2 =>
				reg_g3 		<= reg_g4;
				reg_g2  	<= reg_g5;
				reg_g4  	<= (reg_inp(15)&reg_inp&"000000") + (reg_inp(15)&reg_inp(15)&reg_inp&"0000") +(reg_inp&"0") + reg_inp;
				reg_g5  	<= (reg_inp(15)&reg_inp(15)&reg_inp&"00000") + (reg_inp&"00");
				dienb_sr 	<= dienb_sr(22 downto 0) & dienb;
				
			when STATE_3 =>
				reg_k3		<= reg_g2 + reg_g4;
				reg_k2		<= reg_g5 - reg_g3;
				dienb_sr 	<= dienb_sr(22 downto 0) & dienb;
				
			when STATE_4 =>
				reg_k0 		<= (reg_inp(15)&reg_inp&"000000")+ (reg_inp2(15)&reg_inp2&"000000");	
	        		reg_k1 		<= (reg_inp2(15)&reg_inp2&"000000") - (reg_inp(15)&reg_inp&"000000");
	        		dienb_sr 	<= dienb_sr(22 downto 0) & dienb;
			
			when STATE_5 =>
				reg_g4 		<= (reg_inp(15)&reg_inp&"000000") + (reg_inp&"0000") +(reg_inp&"0") + reg_inp;
				reg_g5 		<= (reg_inp(15)&reg_inp(15)&reg_inp&"00000") + (reg_inp&"00");
				dienb_sr 	<= dienb_sr(22 downto 0) & dienb;
			
			when STATE_6 =>
				reg_g2 		<= reg_g5;
				reg_g3 		<= reg_g4;
				reg_g4  	<= (reg_inp(15)&reg_inp&"000000") + (reg_inp&"0000") +(reg_inp&"0") + reg_inp;
				reg_g5  	<= (reg_inp(15)&reg_inp(15)&reg_inp&"00000") + (reg_inp&"00");			
				dienb_sr 	<= dienb_sr(22 downto 0) & dienb;
				
			when STATE_7 =>
				reg_k3_trans2	<= reg_g2 + reg_g4;
				reg_k2	 	<= reg_g5 - reg_g3;
				dienb_sr 	<= dienb_sr(22 downto 0) & dienb;
				
			when Others =>		
					NULL;	
				
		
		end CASE;
	end if;
end process;


--logic process for next state and output
logic:process (current_state, reg_k0,reg_k1,reg_k2,reg_k3,reg_k3_trans2,dienb,count)
	BEGIN
		count_inp <= count;
		CASE current_state IS
		when START   => 
			m0_inp 		<=(others =>'0');
			if (dienb = '1') then
				next_state	<= STATE_0;	
			else
				next_state	<= START;	
			end if;
			

		when STATE_0 =>	--f3 is in reg_inp, at end of this state.  --start next transform (same as STATE 4)
							
			m0_inp 		<= reg_k0-reg_k3+64;			--output m3	(from previous group)
			next_state 	<= STATE_1;	
		
		when STATE_1 => --f1 is in reg_inp, f3 is in reg_inp2,  at end of this state
													
			m0_inp 		<= reg_k0+reg_k3_trans2+64;		--output m0
			next_state 	<= STATE_2;
		
		when STATE_2 => --f0 is in reg_inp, f1 is in reg_inp2,  at end of this state
									
			m0_inp 		<= reg_k1+reg_k2+64;			--output m1
			next_state 	<= STATE_3;

		when STATE_3 => -- f2 is in reg_inp, f0 is in reg_inp2, at end of this state
					
			m0_inp 		<= reg_k1-reg_k2+64;			--output m2
			next_state 	<= STATE_4;

		when STATE_4 =>
						
			m0_inp 		<= reg_k0-reg_k3_trans2+64;		--output m3
			next_state 	<= STATE_5;
		
		when STATE_5 =>	--start next transform (same as STATE 1)
					
			m0_inp 		<= reg_k0+reg_k3+64;			--output m0
			next_state 	<= STATE_6;
		
		when STATE_6 =>	--start next transform (same as STATE 2)
			
			m0_inp 		<= reg_k1+reg_k2+64;			--output m1	
			next_state 	<= STATE_7;
		
		when STATE_7 =>  --start next transform (same as STATE 3)
					
			m0_inp 		<= reg_k1-reg_k2+64;			--output m2	
			if (dienb = '1') then
				next_state	<= STATE_0;
				count_inp	<= "00";
			elsif	(count ="11" ) then 					
					next_state	<= START;
					count_inp	<= "00";
				else
					next_state	<= STATE_0;	
					count_inp	<= count + 1;	
			end if;
		
		when Others =>
			m0_inp		<= (others =>'0');
			next_state 	<= STATE_0;
		end CASE;
	end process;
end rtl;

--VHDL code ends here


