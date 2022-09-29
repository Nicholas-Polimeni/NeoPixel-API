-- WS2812 communication interface starting point for
-- ECE 2031 final project spring 2022.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity NeoPixelController is

	port(
		clk_10M   : in   std_logic ;
		resetn    : in   std_logic ;
		io_write  : in   std_logic ;
		cs_mode   : in   std_logic ;
		cs_set_all: in  std_logic ;
		cs_addr   : in   std_logic ;
		cs_data   : in   std_logic ;
		cs_set_grp: in   std_logic ;
		cs_refresh: in   std_logic ;
		data_in   : in   std_logic_vector(15 downto 0);
		sda       : out  std_logic
	); 

end entity;

architecture internals of NeoPixelController is
	
	-- Signals for the RAM read and write addresses
	signal ram_read_addr, ram_write_addr : std_logic_vector(7 downto 0);
	-- RAM write enable
	signal ram_we : std_logic;

	-- Signals for data coming out of memory
	signal ram_read_data : std_logic_vector(23 downto 0);
	-- Signal to store the current output pixel's color data
	signal pixel_buffer : std_logic_vector(23 downto 0);

	-- Signal SCOMP will write to before it gets stored into memory
	signal ram_write_buffer : std_logic_vector(23 downto 0);

		-- Hold previous data_in to use for 24-bit mode
	signal prev_data_in: std_logic_vector(15 downto 0);
	
	-- Count how many pixels we have received for 24-bit mode
	signal pixel24_count: std_logic;
	
	-- Contains address we will stop at for set group and set all functionality
	signal addr_count: std_logic_vector(7 downto 0);
	
	signal mode:       std_logic_vector(3 downto 0);

	-- Still set all
	signal is_set_all: std_logic;
	
	-- Used to signal to all processes that a pixel is done being drawn
	-- and ram_read_addr is being incremented
	signal pixel_done: std_logic;
	
	-- RAM interface state machine signals
	type write_states is (idle, storing);
	signal wstate: write_states;
	
	signal refresh_active:   std_logic;
	signal manual_refresh_mode:  std_logic;
	
	-- count how many rounds of pixels we have drawn
	signal count      :   std_logic_vector(1 downto 0);
	
	signal red        :   std_logic_vector(23 downto 0);
	
	signal green        :   std_logic_vector(23 downto 0);
	
	signal white        :   std_logic_vector(23 downto 0);
	
	signal mode7_en     :   std_logic;
	signal mode8_en     :   std_logic;

	
begin

	-- This is the RAM that will store the pixel data.
	-- It is dual-ported.  SCOMP will access port "A",
	-- and the NeoPixel controller will access port "B".
	pixelRAM : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		indata_reg_b => "CLOCK0",
		init_file => "pixeldata.mif",
		intended_device_family => "Cyclone V",
		lpm_type => "altsyncram",
		numwords_a => 256,
		numwords_b => 256,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
		widthad_a => 8,
		widthad_b => 8,
		width_a => 24,
		width_b => 24,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	PORT MAP (
		address_a => ram_write_addr,
		address_b => ram_read_addr,
		clock0 => clk_10M,
		data_a => ram_write_buffer,
		data_b => x"000000",
		wren_a => ram_we,
		wren_b => '0',
		q_b => ram_read_data
	);
	


	-- This process implements the NeoPixel protocol by
	-- using several counters to keep track of clock cycles,
	-- which pixel is being written to, and which bit within
	-- that data is being written.
	process (clk_10M, resetn)
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8; -- high time for '1'
		constant t0h : integer := 3; -- high time for '0'
		constant ttot : integer := 12; -- total bit time
		
		constant npix : integer := 256;

		-- which bit in the 24 bits is being sent
		variable bit_count   : integer range 0 to 31;
		-- counter to count through the bit encoding
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 10000000;
		-- Counter for the current pixel
		variable pixel_count : integer range 0 to 255;
		
		variable xmas_count  : integer range 0 to 2;
		
		variable refresh_count : integer range 0 to 1;
		
		
	begin
		
		if resetn = '0' then
			-- reset all counters
			bit_count := 23;
			enc_count := 0;
			reset_count := 1000;
			xmas_count := 0;
			-- set sda inactive
			sda <= '0';
			pixel_done <= '0'; -- start with first pixel being inactive
			count <= "00";
			red <= "111111110000000000000000";
			green <= "000000001111111100000000";
			white <= "111111111111111111111111";
			refresh_count := 0;
			refresh_active <= '1';
			mode7_en <= '0';
			mode8_en <= '0';

		elsif (rising_edge(clk_10M)) then
		
			-- Set manul refresh to on
			if (io_write = '1' and cs_refresh = '1' and refresh_count = 0) then
				refresh_active <= '0';
				refresh_count := 1;
			elsif(io_write = '1' and cs_refresh = '1' and refresh_count = 1) then
				refresh_active <= '1';
				refresh_count := 0;
			
			end if;

			
			-- This IF block controls the various counters
			if reset_count /= 0 then -- in reset/end-of-frame period
				-- during reset period, ensure other counters are reset
				pixel_count := 0;
				bit_count := 23;
				enc_count := 0;
				-- decrement the reset count
				if (refresh_active = '1') then
					reset_count := reset_count - 1;
				else
					reset_count := reset_count;
				end if;
				-- turn off refresh
--					refresh_active <= '0';
				-- load data from memory
				-- If christmas mode, here I can edit buffer
				if (mode = "0111") then
					mode7_en <= '1';
				else
					mode7_en <= '0';
				end if;
				
				if (mode = "1000") then
					mode8_en <= '1';
				else
					mode8_en <= '0';
				end if;
				
				if (mode7_en = '1' and xmas_count = 0) then
					pixel_buffer <= green;
				elsif (mode7_en = '1' and xmas_count = 1) then
					pixel_buffer <= red;
				elsif (mode7_en = '1' and xmas_count = 2) then
					pixel_buffer <= white;
				elsif (mode7_en /= '1') then
					pixel_buffer <= ram_read_data;
				end if;

				
			else -- not in reset period (i.e. currently sending data)
				-- handle reaching end of a bit
				if enc_count = (ttot-1) then -- is end of this bit?
					enc_count := 0;
					-- shift to next bit
					pixel_buffer <= pixel_buffer(22 downto 0) & '0';
					if bit_count = 0 then -- is end of this pixels's data?
						bit_count := 23; -- start a new pixel
						-- If christmas mode, here I can edit buffer
						if (mode7_en = '1' and xmas_count = 0) then
							pixel_buffer <= green;
						elsif (mode7_en = '1' and xmas_count = 1) then
							pixel_buffer <= red;
						elsif (mode7_en = '1' and xmas_count = 2) then
							pixel_buffer <= white;
						elsif (mode7_en /= '1') then
							pixel_buffer <= ram_read_data;
						end if;
						if pixel_count = npix-1 then -- is end of all pixels?
							-- begin the reset period
							if (mode8_en = '1') then
								reset_count := 1000000;
							elsif (mode7_en = '1') then
								reset_count := 10000000;
							else
								reset_count := 1000;
							end if;
						else
							pixel_count := pixel_count + 1;
						end if;
					else
						-- if not end of this pixel's data, decrement count
						bit_count := bit_count - 1;
					end if;
				else
					-- within a bit, count to achieve correct pulse widths
					enc_count := enc_count + 1;
				end if;
			end if;
			
			
			-- This IF block controls the RAM read address to step through pixels
			if reset_count /= 0 then
				ram_read_addr <= x"00";
				pixel_done <= '0';
			elsif (bit_count = 1) AND (enc_count = 0) then
				-- increment the RAM address as each pixel ends
				-- signal as each pixel is finished
				ram_read_addr <= ram_read_addr + 1;
				if (xmas_count = 2) then
					xmas_count := 0;
				else 
					xmas_count := xmas_count + 1;
				end if;
				pixel_done <= '0';
			elsif (bit_count = 1) AND (enc_count = (ttot - 2)) then -- if about to be done, let color fade know
				pixel_done <= '1';
			else
				pixel_done <= '0';
			end if;
			
			
			-- This IF block controls sda
			if reset_count > 0 then
				-- sda is 0 during reset/latch
				sda <= '0';
			elsif 
				-- sda is 1 in the first part of a bit.
				-- Length of first part depends on if bit is 1 or 0
				( (pixel_buffer(23) = '1') and (enc_count < t1h) )
				or
				( (pixel_buffer(23) = '0') and (enc_count < t0h) )
				then sda <= '1';
			else
				sda <= '0';
			end if;
		end if;
			
	end process;
	
	
	
	process(clk_10M, resetn, cs_addr)
		
	begin
	
	
		-- For this implementation, saving the memory address
		-- doesn't require anything special.  Just latch it when
		-- SCOMP sends it.
		if resetn = '0' then
			ram_write_addr <= x"00";
		elsif rising_edge(clk_10M) then
			-- If SCOMP is writing to the address register...
			if (io_write = '1') and (cs_addr = '1') then
				ram_write_addr <= data_in(7 downto 0);
			elsif wstate = storing and (mode = "0101" or is_set_all = '1') then 
				ram_write_addr <= ram_write_addr + 1;	
			elsif  mode8_en = '1' and pixel_done = '1' then  -- want to auto_inc when setting all, or in auto-inc or when doing fade
				ram_write_addr <= ram_read_addr;
			elsif (io_write='1') and (cs_set_all = '1') and (is_set_all = '0') then
				addr_count <= ram_write_addr + 255; -- want to stop 255 addresses from where we are
			elsif (io_write = '1') and (cs_set_grp = '1') and (is_set_all = '0') then
				addr_count <= data_in(7 downto 0) + ram_write_addr - 1; -- save number of pixels we want to set
			end if;
		end if;
	
	
		-- The sequnce of events needed to store data into memory will be
		-- implemented with a state machine.
		-- Although there are ways to more simply connect SCOMP's I/O system
		-- to an altsyncram module, it would only work with under specific 
		-- circumstances, and would be limited to just simple writes.  Since
		-- you will probably want to do more complicated things, this is an
		-- example of something that could be extended to do more complicated
		-- things.
		-- Note that 'ram_we' is *not* implemented as a Moore output of this state
		-- machine, because Moore outputs are susceptible to glitches, and
		-- that's a bad thing for memory control signals.
		if resetn = '0' then
			wstate <= idle;
			ram_we <= '0';
			ram_write_buffer <= x"000000";
			pixel24_count <= '0';
			is_set_all <= '0';
			-- Note that resetting this device does NOT clear the memory.
			-- Clearing memory would require cycling through each address
			-- and setting them all to 0.
		elsif rising_edge(clk_10M) then
			case wstate is
			when idle =>
				if (io_write = '1') and (cs_data = '1') and (is_set_all = '0') then -- make sure is_set_all is 0 so we can ignore normal mode when setting all
					if ((mode = "0001" or mode = "0101")) then -- 16-bit mode must store when in auto-increment or normal 16-bit mode

						-- latch the current data into the temporary storage register,
						-- because this is the only time it'll be available.
						-- Convert RGB565 to 24-bit color
						ram_write_buffer <= data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0) & "000";
						-- can raise ram_we on the upcoming transition, because data
						-- won't be stored until next clock cycle.
						ram_we <= '1';
						-- Change state
						wstate <= storing;
					elsif (mode = "0010") then -- if we are doing a 
						-- we are in 24-bit pixel mode, need to get two outs of data before we can write to mem
						if (pixel24_count = '0') then
							-- latch first chunk of data
							prev_data_in(15 downto 0) <= data_in(15 downto 0);
							-- "increment" pixel count
							pixel24_count <= '1';
						elsif (pixel24_count = '1') then
							-- grab second chunk of data and concatenate with previous data
							-- then store the 24-bit value to ram_write_buffer 
							ram_write_buffer <= prev_data_in(7 downto 0) & prev_data_in(15 downto 8) & data_in(7 downto 0);
							ram_we <= '1'; 
							wstate <= storing;
						end if;
						
					elsif (mode = "0100") then -- we are in group setting mode
						ram_write_buffer <= data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0) & "000"; -- copy data to buffer
						is_set_all <= '1'; -- move to is_set_all mode, this will stop at different point now			
					end if;
				elsif (io_write='1') and (cs_set_all = '1') and (is_set_all = '0') then -- setting all out for the first time
					is_set_all <= '1';
					ram_write_buffer <= data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0) & "000";
				elsif (is_set_all = '1') then
--					-- Stop writing when our address finally reaching address 255
					if (ram_write_addr = addr_count) then
						is_set_all <= '0';
					end if;
					wstate <= storing;
					ram_we <= '1';
				elsif (mode8_en = '1' and pixel_done = '1') then -- in color fade mode
					-- Need to account for current ram_read_data being one over
					ram_write_buffer <= ram_read_data(22 downto 0) & ram_read_data(23);
					wstate <= storing;
					ram_we <= '1';
				end if;
				
			when storing =>
				-- All that's needed here is to lower ram_we.  The RAM will be
				-- storing data on this clock edge, so ram_we can go low at the
				-- same time.
				-- when in fade, want to take whatever is being read and restore it with a slight shift
				-- For fade, also want to stay in the storing state so we keep storing
				
				ram_we <= '0';
				wstate <= idle;
				pixel24_count <= '0';
				
				
			when others =>
				wstate <= idle;
			end case;
		end if;
		
		
	end process;
	
	
	process(clk_10M, resetn, cs_mode)
	begin
	
		-- On reset, set the mode to 0
		if resetn = '0' then
			mode <= "0000";	
		-- Latch the mode when we get it, just use bottom 4 bits of data_in
		elsif rising_edge(clk_10M) then
			if (io_write = '1') and (cs_mode = '1') then
				mode <= data_in(3 downto 0);
			end if;
		end if;	
	end process;

	
	
end internals;
