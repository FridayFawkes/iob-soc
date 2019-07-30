//`timescale 1ns / 1ps

//module memory_cache(
//		    input 	      clk,
//		    input 	      reset,
//		    output 	      buffer_clear,
//		    input [31:0]      cache_write_data,
//		    input [3:0]       cache_wstrb,
//		    input [29:0]      cache_addr, // 2 MSB removed (0x80000000, since they are only to select the main memory (bit 30 and 31)
//		    output reg [31:0] cache_read_data,
//		    input 	      mem_ack,
//		    input 	      cpu_ack,
//		    output reg 	      cache_ack,
//		    /*output reg [31:0] mem_write_data,
//		     output reg [3:0]  mem_wstrb,
//		     input [31:0]      mem_read_data,
//		     output reg [31:0] mem_addr,
//		     output reg 	      mem_valid,
//		     input 	      mem__ready,*/
//		    ///// AXI signals
//		    /// Read		    
//		    output reg [31:0] AR_ADDR, 
//		    output reg [7:0]  AR_LEN,
//		    output reg [2:0]  AR_SIZE,
//		    output reg [1:0]  AR_BURST,
//		    output reg 	      AR_VALID, 
//		    input 	      AR_READY,
//		    input 	      R_VALID, 
//		    output reg 	      R_READY,
//		    input [31:0]      R_DATA,
//		    input 	      R_LAST, 
//		    /// Write
//		    output reg [31:0] AW_ADDR,
//		    output reg 	      AW_VALID,
//		    input 	      AW_READY, 
//		    output reg 	      W_VALID,
//		    output reg [3:0]  W_STRB, 
//		    input 	      W_READY,
//		    output reg [31:0] W_DATA,
//		    input 	      B_VALID,
//		    output reg 	      B_READY 	      
//		    );


//   parameter Addr_size = 30;
//   parameter Word_size = 32;
//   parameter N_bytes   = Word_size/8;
//   parameter Word_select_size = 1; //log2(Line_size/Word_size)
//   parameter Index_size = 10;
//   parameter Tag_size = Addr_size - (Index_size + Word_select_size + 2); //last 2 bits are always 00 (4 Bytes = 32 bits)

//   wire [Word_select_size-1:0] 	      Word_select;
   
//   assign Word_select = cache_addr [(Word_select_size + 1):2]; //last 2 bits are 0


//   wire [Index_size-1:0] 	      index;

//   wire [Word_size*(2**Word_select_size) - 1: 0] data_read;

//   reg 						 data_fetch, data_load;

//   wire 					 v;

//   wire [Tag_size-1:0] 				 tag;
   
//   wire 					 buffer_full, buffer_empty;
   

//   /// FSM states and register ////
//   parameter
//     stand_by     = 3'd0,
//     verification = 3'd1, 
//     write_fail   = 3'd2,
//     read_fail    = 3'd4,
//     delay        = 3'd5, 
//     read_fail_dummy = 3'd3,
//     hit = 3'd6;
//   reg [2:0] 					 state;
//   reg [2:0] 					 next_state;


   
//   //wire cache_hit;  = ((tag == cache_addr [Addr_size-1 -: Tag_size]) && v) & cpu_ack;
//   wire cache_hit = (state == hit);
   
//   /////////////////////////////

//   //reg 						 cache_write, cache_read;
   
//   /////////////////////////////////////////////////////////////////////////////////////////////////            

//   always @ (posedge clk, posedge reset)
//     begin
//	cache_ack <= 1'b0;
//	if (reset) state <= stand_by;
//	else 
//	  case (state)
	    
//            stand_by:
//	      begin
//		 if (~cpu_ack) state <= stand_by; //reset or no action 
//		 else          state <= verification;//cache verification	   
//	      end

//            verification:   
//	      begin
//		 if ((tag != cache_addr [Addr_size-1 -: Tag_size]) || ~v) //cache_miss
//		   begin
//		      if (|cache_wstrb) state <= write_fail;
//		      else              state <= read_fail_dummy;
//		   end
//		 else
//		   begin
//		      //cache_ack <= 1'b1;
//		      //state <= stand_by; //cache_hit
//		   state <= hit;//cache_hit
//		   end 	  
//	      end

//            write_fail:     
//	      begin
//		 if (buffer_full) //write to buffer. If full, wait.
//		   begin
//		      state <= write_fail;
//		      cache_ack <= 1'b0;
//		   end
//		 else
//		   begin
//		      //state <= stand_by;
//	  	      state <= delay;
//	  	      cache_ack <= 1'b1;
//		   end
//	      end


//	    read_fail_dummy: state <= read_fail;

//            read_fail:      
//	      begin
//		 if (data_load) //is data being loaded? wait to avoid collision
//		   begin
//		      state <= read_fail;
//		      cache_ack <= 1'b0;
//		   end	  
//		 else
//		   begin
//		      //state <= stand_by;
//		      state <= delay;
//		     // cache_ack <= 1'b1; //Commented so it doesn't acknowledge, before the Word_select is corretly updated (after a read fail, will send word_select instead since it only send Word_select during cache_hit, might need correcto to avoid waiting 2 more clk cycles.
		      
//		   end
//              end // case: read_fail
      	    
//      	    delay: state <= stand_by;
 
//       	    hit:
//	      begin
//		 state <= delay;   
//		 cache_ack <= 1'b1;  	    
//      	      end
	    
//            default:        
//	      begin
//		 state <= stand_by;
//              end
//	  endcase
//     end                        

//   /////////////////////////////////////////////////////////////////////////////////////////////////
   
//   //assign index = cache_addr [(Addr_size-Tag_size)-1 : (Addr_size-Tag_size)-1 - Index_size];
//    assign index = cache_addr [Index_size + Word_select_size + 1 : Word_select_size + 2];
    

////reg [Tag_size -1: 0] tag_data_in;

////always @ (posedge clk)
////    tag_data_in <= cache_addr[Addr_size-1:(Addr_size-Tag_size)];
    



//   tag_memory  #(
//		 .ADDR_W (Index_size), 
//		 .DATA_W (Tag_size) 
//		 ) tag_memory (
//			       .clk           (clk                                         ),
//			       .tag_write_data(cache_addr[Addr_size-1:(Addr_size-Tag_size)]),
//			       //.tag_write_data (tag_data_in),
//			       .tag_addr      (index                                       ),
//			       .tag_en        (data_load                                   ),
//			       .tag_read_data (tag                                         )                     
//			       );


//   valid_memory #(
//		  .ADDR_W (Index_size), 
//		  .DATA_W (1) 
//		  ) valid_memory (
//				  .clk         (clk       ),
//				  .reset       (reset     ),
//				  .v_write_data(data_load ),				        
//				  .v_addr      (index     ),
//				  .v_en        (data_load ),
//				  .v_read_data (v         )   
//				  );
   
   
//   wire [3:0] data_line_wstrb;      
//   reg [3:0]  loader_wstrb;
//   reg [Word_select_size :0] select_counter, select_counter_aux; //it will have 1 more bit, since it will count twice in each clk.
//   wire [Word_select_size - 1:0] word_select;
//   wire [Word_size -1 : 0] 	 write_data;
   

//      //assign data_line_wstrb = (data_load)? {N_bytes{R_READY}}  : cache_wstrb; // 28/7/19
//assign data_line_wstrb = (data_load)? {N_bytes{R_READY}}  :(cache_hit)? cache_wstrb : {N_bytes{1'b0}} ;
   
//      //assign word_select = (data_load)? select_counter  : Word_select; //select_counter is for read-fail, while Word_select is from the input address
////assign word_select = (data_load)? select_counter  :  (cache_ack & v)? Word_select :{ Word_select_size{1'b0}} ; //select_counter is for read-fail, while Word_select is from the input address
//    assign word_select = (data_load)? select_counter : (cache_hit)? Word_select : { Word_select_size{1'b0}} ;

//   assign write_data = (data_load)? R_DATA : cache_write_data; //when a read-fail, the data is read from the main memory, otherwise is the input write data
   
   
//   ///////////// Data Memory with 1 Memory with Index addresses, for each position of the Data Line ///////////////////////////////
   
//   genvar 			  i;
   
//   generate
//      for (i = 0; i < 2**Word_select_size; i=i+1)
//        begin
//           data_memory #(
//			 .ADDR_W (Index_size) 
//			 ) 
//	   data_memory 
//	       (
//		.clk           (clk       ),
//		.mem_write_data(write_data),
//		.mem_addr      (index     ),
//		.mem_en        ((i == word_select)? data_line_wstrb : 4'b0000), 
//		.mem_read_data (data_read [Word_size*(i+1)-1: Word_size*i])   
//		);      
//        end     
//   endgenerate


//   //Using shifts to select the correct Data memory from the cache's Data line, avoiding the use of generate. 
//   always @ (posedge clk)
//     cache_read_data [Word_size -1:0] <= data_read >> (word_select * Word_size);
   

//   //// read fail Auxiliary FSM states and register //// -> Loading Data (to Data line or to Buffer)
//   parameter
//     read_stand_by     = 2'd0,
//     data_loader_init  = 2'd1,
//     data_loader       = 2'd2,
//     data_loader_dummy = 2'd3;
   
   
//   reg [1:0] read_state;
//   reg [1:0] read_next_state;


//   wire [Addr_size-1-Word_select_size:0] address = {2'b0 , cache_addr[Addr_size-1:Word_select_size+2]};
   
//   always @ (posedge clk, posedge reset)
//     begin
	
//	AR_ADDR  <= {32'b0};
//	AR_VALID <= 1'b0;
//	AR_LEN   <= 8'd0;
//	AR_SIZE  <= 3'b000;
//	AR_BURST <= 2'b00;
//	R_READY  <= 1'b0;
	
//	if (reset)
//          begin
//	     read_state <= read_stand_by; //reset
//	     data_load <= 1'b0;
//	  end	  
//	else
	   
//	  case (read_state)
	    
//            read_stand_by://0
//	      begin
//		 select_counter     <= {Word_select_size{1'b0}};
//		 select_counter_aux <= {Word_select_size{1'b0}};
//		 if (state == read_fail_dummy)
//		   begin
//		      read_state <= data_loader_init; //read miss
//		      data_load <= 1'b1;	  
//		   end
//		 else 
//		   begin
//		      read_state <= read_stand_by; //idle
//		      data_load <= 1'b0;
//		   end
//	      end // case: read_stand_by
	    
	    
//            data_loader_init://1
	       
//	      begin
//		 AR_ADDR  <= {2'b00, cache_addr[Addr_size -1:Word_select_size + 2], {(Word_select_size+2){1'b0}} }  ; //addr = {00, tag,index,0...00,00} => word_select = 0...00
//		 AR_VALID <= 1'b1;
//		 AR_LEN   <= 2*(Word_select_size)-1;
//		 AR_SIZE  <= 3'b010;// 4 bytes
//		 AR_BURST <= 2'b01; //INCR
//		 data_load <= 1'b1;
//		 select_counter <= 1'b0;
//		 select_counter_aux <= 1'b0;
		 
//		 if (AR_READY) read_state  <= data_loader;
//		 else          read_state  <= data_loader_init;
//	      end // case: data_loader_init
	    
	    
//	    data_loader://2
//	      begin
//	         data_load <= 1'b1;
//	         if (R_VALID)
//	           begin
//	              if (R_LAST)
//	                begin
//	                   R_READY <= 1'b0;
//	                   read_state <= read_stand_by;
//			   select_counter <= select_counter;
//	                end else begin
//	                	                   R_READY <= 1'b1;
//			   select_counter <= select_counter + 1;                    
//			   read_state <= data_loader;
//                        end
                      
//                   end else begin 
//                   	                   R_READY <= 1'b1;   
//		      select_counter <= select_counter;
//                      read_state <= data_loader;  
//                   end
//              end  
//	    /*
//	     //	     data_loader_dummy://3
//	     //	     begin
//	     //	     R_READY <= 1'b0;
//	     //	     data_load <= 1'b1;
//	     //	     select_counter <= select_counter_aux + 1; //select_counter is the Data_line (selector) address
//	     //             select_counter_aux <= select_counter;
//	     //	     read_state <= data_loader;	 
//	     //	      end
//	     //	     */	    
//	    default:        
//	      begin
//		 read_state <= read_stand_by;
//              end
	    
//	  endcase // case (state)       
//     end                        



//   /////////////////////////////////////////////////////////////////////////////////////////////////
   
//   //// buffer FSM states and register ////
//   parameter
//     buffer_stand_by       = 2'd0,
//     buffer_write_validation = 2'd1,
//     buffer_write_to_mem   = 2'd2,
//     buffer_wait_reply     = 2'd3;  
   
   
//   reg [1:0] buffer_state;

//   reg 	     buffer_empty_delay;
   
//   wire [(N_bytes) + (Addr_size - 2) + (Word_size) -1 :0] buffer_data_out, buffer_data_in; // {wstrb, addr [29:2], word}

//   /////////////////////////////////////////////////////////////////////////////////////////////////      

   
//   always @ (posedge clk, posedge reset)
//     begin
//	AW_ADDR  <= {(Addr_size+2){1'b0}}; //because of the 2 MSB removed
//        AW_VALID <= 1'b0;
//	W_VALID  <= 1'b0;
//	W_STRB   <= {N_bytes{1'b0}};
//	B_READY  <= 1'b1;/////////////////////////???????????????????????????????????? (fixes the non getting to buffer_wait_reply problem)
	
//	if (reset) buffer_state <= buffer_stand_by;
//	else
//	  case (buffer_state)
	    
//	    buffer_stand_by:
//	      begin
//		 if (buffer_empty) buffer_state <= buffer_stand_by; //added buffer_state == buffer_stand_by? otherwise it would go immediatly to buffer_stand_by if buffer became empty before reaching buffer_wait_reply
//		 else              buffer_state <= buffer_write_validation;
//	      end // case: buffer_stand_by

//	    buffer_write_validation:
//              begin
//		 AW_ADDR  <= {2'b00, buffer_data_out [(Addr_size - 2 + Word_size) - 1 : Word_size], 2'b00};
//		 AW_VALID <= 1'b1;
//		 if (AW_READY) buffer_state <= buffer_write_to_mem; // the main memory 
//		 else         buffer_state <= buffer_write_validation;
//              end        
            
//	    buffer_write_to_mem:
//	      begin        //buffer_data_out = {wstrb (size 4), address (size of buffer's WORDSIZE - 4 - word_size), word_size (size of Word_size)}  
//		 W_VALID  <= 1'b1;
//		 W_STRB   <= buffer_data_out [(N_bytes + Addr_size -2 + Word_size) -1 : Addr_size -2 + Word_size];
//		 //W_STRB <= buffer_data_out [63:60];
//		 W_DATA  <= buffer_data_out [Word_size -1 : 0];
//		 if (W_READY) buffer_state <= buffer_stand_by;              //buffer_state <= buffer_wait_reply; // the main memory 
//		 else         buffer_state <= buffer_write_to_mem;
//	      end // case: buffer_write_to_mem
	    
//	    default:        
//	      begin
//		 buffer_state <= buffer_stand_by;
//              end
	    
//	  endcase // case (state)       
//     end         
   
//   /////////////////////////////////////////////////////////////////////////////////////////////////

   

//   assign buffer_data_in = {cache_wstrb, cache_addr[Addr_size -1: 2], cache_write_data};
//   assign buffer_clear = buffer_empty;
   
//   aFifo #(
//           .DATA_WIDTH (N_bytes+Addr_size-2+Word_size),
//           .ADDRESS_WIDTH (4)//Depth of FIFO
//           )
//   buffer (
//	   .Data_out (buffer_data_out), 
//	   .Empty_out (buffer_empty),
//	   .ReadEn_in (~buffer_empty), //buffer not empty
//	   .RClk (clk),    
//	   .Data_in (buffer_data_in), 
//	   .Full_out (buffer_full),
//	   .WriteEn_in ((state ==verification)? |cache_wstrb : 1'b0),
//	   .WClk (clk),
//	   .Clear_in (reset)
//	   );

//endmodule




`timescale 1ns / 1ps

module memory_cache(
		    input 	      clk,
		    input 	      reset,
		    output 	      buffer_clear,
		    input [31:0]      cache_write_data,
		    input [3:0]       cache_wstrb,
		    input [29:0]      cache_addr, // 2 MSB removed (0x80000000, since they are only to select the main memory (bit 30 and 31)
		    output reg [31:0] cache_read_data,
		    input 	      mem_ack,
		    input 	      cpu_ack,
		    output reg 	      cache_ack,
		    /// Cache Controller signals
		    input [1:0]       cache_controller_address,
		    output  [31:0] cache_controller_requested_data,
		    input 	      cache_controller_cpu_request,
		    output  	      cache_controller_acknowledge, 
		    ///// AXI signals
		    /// Read		    
		    output reg [31:0] AR_ADDR, 
		    output reg [7:0]  AR_LEN,
		    output reg [2:0]  AR_SIZE,
		    output reg [1:0]  AR_BURST,
		    output reg 	      AR_VALID, 
		    input 	      AR_READY,
		    input 	      R_VALID, 
		    output reg 	      R_READY,
		    input [31:0]      R_DATA,
		    input 	      R_LAST, 
		    /// Write
		    output reg [31:0] AW_ADDR,
		    output reg 	      AW_VALID,
		    input 	      AW_READY, 
		    output reg 	      W_VALID,
		    output reg [3:0]  W_STRB, 
		    input 	      W_READY,
		    output reg [31:0] W_DATA,
		    input 	      B_VALID,
		    output reg 	      B_READY 	      
		    );


   parameter Addr_size = 30;
   parameter Word_size = 32;
   parameter N_bytes   = Word_size/8;
   parameter Word_select_size = 1; //log2(Line_size/Word_size)
   parameter Index_size = 10;
   parameter Tag_size = Addr_size - (Index_size + Word_select_size + 2); //last 2 bits are always 00 (4 Bytes = 32 bits)
   parameter BUFFER_DEPTH = 4; //Depth of the buffer that writes to the main memory (2**BUFFER_DEPTH positions)
   
   wire [Word_select_size-1:0] 	      Word_select;
   
   assign Word_select = cache_addr [(Word_select_size + 1):2]; //last 2 bits are 0


   wire [Index_size-1:0] 	      index;

   wire [Word_size*(2**Word_select_size) - 1: 0] data_read;

   reg 						 data_fetch, data_load;

   wire 					 v;

   wire [Tag_size-1:0] 				 tag;
   
   wire 					 buffer_full, buffer_empty;
   

   /// FSM states and register ////
   parameter
     stand_by        = 3'd0,
     verification    = 3'd1, 
     write_fail      = 3'd2,
     read_fail_dummy = 3'd3,
     read_fail       = 3'd4, 
     read_val        = 3'd5,
     hit             = 3'd6,
     delay           = 3'd7;
   
   reg [2:0] 					 state;
   reg [2:0] 					 next_state;


   
   //wire cache_hit;  = ((tag == cache_addr [Addr_size-1 -: Tag_size]) && v) & cpu_ack;
   wire 					 cache_hit = (state == hit);
   
   wire cache_invalidate;
   
   /////////////////////////////

   reg 						 ctrl_hit, ctrl_write_miss, ctrl_read_miss;
   
   /////////////////////////////////////////////////////////////////////////////////////////////////            

   always @ (posedge clk, posedge reset)
     begin
	cache_ack <= 1'b0;
	ctrl_hit <= 1'b0;
	ctrl_read_miss <= 1'b0;
	ctrl_write_miss <= 1'b0;
	
       
	if (reset) state <= stand_by;
	else 
	  case (state)
	    
            stand_by:
	      begin
		 if (~cpu_ack) state <= stand_by; //reset or no action 
		 else          state <= verification;//cache verification	   
	      end

            verification:   
	      begin
		 if ((tag != cache_addr [Addr_size-1 -: Tag_size]) || ~v) //cache_miss
		   begin
		      if (|cache_wstrb) 
			begin
			   state <= write_fail;
			   ctrl_write_miss <= 1'b1;
			end
		      else 
			begin
			   state <= read_fail_dummy;
			   ctrl_read_miss <= 1'b1;
			end
		   end
		 else
		   begin
		      //cache_ack <= 1'b1;
		      //state <= stand_by; //cache_hit
		      state <= hit;//cache_hit
		      ctrl_hit <= 1'b1;
		   end 	  
	      end

            write_fail:     
	      begin
		 if (buffer_full) //write to buffer. If full, wait.
		   begin
		      state <= write_fail;
		      cache_ack <= 1'b0;
		   end
		 else
		   begin
		      //state <= stand_by;
	  	      state <= delay;
	  	      cache_ack <= 1'b1;
		   end
	      end


	    read_fail_dummy: state <= read_fail;

            read_fail:      
	      begin
		 if (data_load) //is data being loaded? wait to avoid collision
		   begin
		      state <= read_fail;
		      cache_ack <= 1'b0;
		   end	  
		 else
		   begin
		      //state <= stand_by;
		      state <= read_val;
		      // cache_ack <= 1'b1; //Commented so it doesn't acknowledge, before the Word_select is corretly updated (after a read fail, will send word_select instead since it only send Word_select during cache_hit, might need correction to avoid waiting 2 more clk cycles.
		      
		   end
              end // case: read_fail

	    read_val:
	      begin
		 state <= hit;
	      end
	    
      	    delay: state <= stand_by;
	    
       	    hit:
	      begin
		 state <= delay;   
		 cache_ack <= 1'b1;  	    
      	      end
	    
            default:        
	      begin
		 state <= stand_by;
              end
	  endcase
     end                        

   /////////////////////////////////////////////////////////////////////////////////////////////////
   
   //assign index = cache_addr [(Addr_size-Tag_size)-1 : (Addr_size-Tag_size)-1 - Index_size];
   assign index = cache_addr [Index_size + Word_select_size + 1 : Word_select_size + 2];
   

   //reg [Tag_size -1: 0] tag_data_in;

   //always @ (posedge clk)
   //    tag_data_in <= cache_addr[Addr_size-1:(Addr_size-Tag_size)];
   



   tag_memory  #(
		 .ADDR_W (Index_size), 
		 .DATA_W (Tag_size) 
		 ) tag_memory (
			       .clk           (clk                                         ),
			       .tag_write_data(cache_addr[Addr_size-1:(Addr_size-Tag_size)]),
			       //.tag_write_data (tag_data_in),
			       .tag_addr      (index                                       ),
			       .tag_en        (data_load                                   ),
			       .tag_read_data (tag                                         )                     
			       );


   valid_memory #(
		  .ADDR_W (Index_size), 
		  .DATA_W (1) 
		  ) valid_memory (
				  .clk         (clk       ),
				  .reset       (reset   || cache_invalidate  ),
				  .v_write_data(data_load ),				        
				  .v_addr      (index     ),
				  .v_en        (data_load ),
				  .v_read_data (v         )   
				  );
   
   
   wire [3:0] data_line_wstrb;      
   reg [3:0]  loader_wstrb;
   reg [Word_select_size :0] select_counter, select_counter_aux; //it will have 1 more bit, since it will count twice in each clk.
   wire [Word_select_size - 1:0] word_select;
   wire [Word_size -1 : 0] 	 write_data;
   

   //assign data_line_wstrb = (data_load)? {N_bytes{R_READY}}  : cache_wstrb; // 28/7/19
   assign data_line_wstrb = (data_load)? {N_bytes{R_READY}}  :(cache_hit)? cache_wstrb : {N_bytes{1'b0}} ;
   
   //assign word_select = (data_load)? select_counter  : Word_select; //select_counter is for read-fail, while Word_select is from the input address
   //assign word_select = (data_load)? select_counter  :  (cache_ack & v)? Word_select :{ Word_select_size{1'b0}} ; //select_counter is for read-fail, while Word_select is from the input address
   assign word_select = (data_load)? select_counter : (cache_hit)? Word_select : { Word_select_size{1'b0}} ;

   assign write_data = (data_load)? R_DATA : cache_write_data; //when a read-fail, the data is read from the main memory, otherwise is the input write data
   
   
   ///////////// Data Memory with 1 Memory with Index addresses, for each position of the Data Line ///////////////////////////////
   
   genvar 			 i;
   
   generate
      for (i = 0; i < 2**Word_select_size; i=i+1)
        begin
           data_memory #(
			 .ADDR_W (Index_size) 
			 ) 
	   data_memory 
	       (
		.clk           (clk       ),
		.mem_write_data(write_data),
		.mem_addr      (index     ),
		.mem_en        ((i == word_select)? data_line_wstrb : 4'b0000), 
		.mem_read_data (data_read [Word_size*(i+1)-1: Word_size*i])   
		);      
        end     
   endgenerate


   //Using shifts to select the correct Data memory from the cache's Data line, avoiding the use of generate. 
   always @ (posedge clk)
     cache_read_data [Word_size -1:0] <= data_read >> (word_select * Word_size);
   

   //// read fail Auxiliary FSM states and register //// -> Loading Data (to Data line or to Buffer)
   parameter
     read_stand_by     = 2'd0,
     data_loader_init  = 2'd1,
     data_loader       = 2'd2,
     data_loader_dummy = 2'd3;
   
   
   reg [1:0] read_state;
   reg [1:0] read_next_state;


   wire [Addr_size-1-Word_select_size:0] address = {2'b0 , cache_addr[Addr_size-1:Word_select_size+2]};
   
   always @ (posedge clk, posedge reset)
     begin
	
	AR_ADDR  <= {32'b0};
	AR_VALID <= 1'b0;
	AR_LEN   <= 8'd0;
	AR_SIZE  <= 3'b000;
	AR_BURST <= 2'b00;
	R_READY  <= 1'b0;
	
	if (reset)
          begin
	     read_state <= read_stand_by; //reset
	     data_load <= 1'b0;
	  end	  
	else
	   
	  case (read_state)
	    
            read_stand_by://0
	      begin
		 select_counter     <= {Word_select_size{1'b0}};
		 select_counter_aux <= {Word_select_size{1'b0}};
		 if (state == read_fail_dummy)
		   begin
		      read_state <= data_loader_init; //read miss
		      data_load <= 1'b1;	  
		   end
		 else 
		   begin
		      read_state <= read_stand_by; //idle
		      data_load <= 1'b0;
		   end
	      end // case: read_stand_by
	    
	    
            data_loader_init://1
	       
	      begin
		 AR_ADDR  <= {2'b00, cache_addr[Addr_size -1:Word_select_size + 2], {(Word_select_size+2){1'b0}} }  ; //addr = {00, tag,index,0...00,00} => word_select = 0...00
		 AR_VALID <= 1'b1;
		 AR_LEN   <= 2*(Word_select_size)-1;
		 AR_SIZE  <= 3'b010;// 4 bytes
		 AR_BURST <= 2'b01; //INCR
		 data_load <= 1'b1;
		 select_counter <= 1'b0;
		 select_counter_aux <= 1'b0;
		 
		 if (AR_READY) read_state  <= data_loader;
		 else          read_state  <= data_loader_init;
	      end // case: data_loader_init
	    
	    
	    data_loader://2
	      begin
	         data_load <= 1'b1;
	         if (R_VALID)
	           begin
	              if (R_LAST)
	                begin
	                   R_READY <= 1'b0;
	                   read_state <= read_stand_by;
			   select_counter <= select_counter;
	                end else begin
	                   R_READY <= 1'b1;
			   select_counter <= select_counter + 1;                    
			   read_state <= data_loader;
                        end
                      
                   end else begin 
                      R_READY <= 1'b1;   
		      select_counter <= select_counter;
                      read_state <= data_loader;  
                   end
              end  
	    
	    default:        
	      begin
		 read_state <= read_stand_by;
              end
	    
	  endcase // case (state)       
     end                        



   /////////////////////////////////////////////////////////////////////////////////////////////////
   
   //// buffer FSM states and register ////
   parameter
     buffer_stand_by       = 2'd0,
     buffer_write_validation = 2'd1,
     buffer_write_to_mem   = 2'd2,
     buffer_wait_reply     = 2'd3;  
   
   
   reg [1:0] buffer_state;

   reg 	     buffer_empty_delay;
   
   wire [(N_bytes) + (Addr_size - 2) + (Word_size) -1 :0] buffer_data_out, buffer_data_in; // {wstrb, addr [29:2], word}

   /////////////////////////////////////////////////////////////////////////////////////////////////      

   
   always @ (posedge clk, posedge reset)
     begin
	AW_ADDR  <= {(Addr_size+2){1'b0}}; //because of the 2 MSB removed
        AW_VALID <= 1'b0;
	W_VALID  <= 1'b0;
	W_STRB   <= {N_bytes{1'b0}};
	B_READY  <= 1'b1;
	
	if (reset) buffer_state <= buffer_stand_by;
	else
	  case (buffer_state)
	    
	    buffer_stand_by:
	      begin
		 if (buffer_empty) buffer_state <= buffer_stand_by; //added buffer_state == buffer_stand_by? otherwise it would go immediatly to buffer_stand_by if buffer became empty before reaching buffer_wait_reply
		 else              buffer_state <= buffer_write_validation;
	      end // case: buffer_stand_by

	    buffer_write_validation:
              begin
		 AW_ADDR  <= {2'b00, buffer_data_out [(Addr_size - 2 + Word_size) - 1 : Word_size], 2'b00};
		 AW_VALID <= 1'b1;
		 if (AW_READY) buffer_state <= buffer_write_to_mem; // the main memory 
		 else         buffer_state <= buffer_write_validation;
              end        
            
	    buffer_write_to_mem:
	      begin        //buffer_data_out = {wstrb (size 4), address (size of buffer's WORDSIZE - 4 - word_size), word_size (size of Word_size)}  
		 W_VALID  <= 1'b1;
		 W_STRB   <= buffer_data_out [(N_bytes + Addr_size -2 + Word_size) -1 : Addr_size -2 + Word_size];
		 //W_STRB <= buffer_data_out [63:60];
		 W_DATA  <= buffer_data_out [Word_size -1 : 0];
		 if (W_READY) buffer_state <= buffer_stand_by;              //buffer_state <= buffer_wait_reply; // the main memory 
		 else         buffer_state <= buffer_write_to_mem;
	      end // case: buffer_write_to_mem
	    
	    default:        
	      begin
		 buffer_state <= buffer_stand_by;
              end
	    
	  endcase // case (state)       
     end         
   
   /////////////////////////////////////////////////////////////////////////////////////////////////

   

   assign buffer_data_in = {cache_wstrb, cache_addr[Addr_size -1: 2], cache_write_data};
   assign buffer_clear = buffer_empty;
   
   aFifo #(
           .DATA_WIDTH (N_bytes+Addr_size-2+Word_size),
           .ADDRESS_WIDTH (BUFFER_DEPTH)//Depth of FIFO
           )
   buffer (
	   .Data_out (buffer_data_out), 
	   .Empty_out (buffer_empty),
	   .ReadEn_in (~buffer_empty), //buffer not empty
	   .RClk (clk),    
	   .Data_in (buffer_data_in), 
	   .Full_out (buffer_full),
	   .WriteEn_in ((state ==verification)? |cache_wstrb : 1'b0),
	   .WClk (clk),
	   .Clear_in (reset)
	   );






   cache_controller
     cache_ctrl (
         .clk (clk),   
		 .ctrl_hit           (ctrl_hit),
		 .ctrl_read_miss     (ctrl_read_miss),
		 .ctrl_write_miss    (ctrl_write_miss),
		 .ctrl_cache_invalid (cache_invalidate),
		 .ctrl_addr       (cache_controller_address),
		 .ctrl_req_data      (cache_controller_requested_data),
		 .ctrl_cpu_req       (cache_controller_cpu_request),
		 .ctrl_ack           (cache_controller_acknowledge),
		 .ctrl_reset         (reset)
		 );
			       

   
endmodule



module cache_controller(
            input clk,
			input 		  ctrl_hit,
			input 		  ctrl_read_miss,
			input 		  ctrl_write_miss,
			output reg 	  ctrl_cache_invalid,
			input [1:0] 	  ctrl_addr,
			output reg [31:0] ctrl_req_data,
			input 		  ctrl_cpu_req,
			output reg 	  ctrl_ack,
			input 		  ctrl_reset	   
			);

   reg [31:0] 			   hit_counter, read_miss_counter, write_miss_counter;


   //cache_hit
   always @ (posedge clk, posedge ctrl_reset)
     if (ctrl_reset)
       hit_counter <= {32{1'b0}};
     else
       if (ctrl_hit)
	 hit_counter <= hit_counter + 1;
       else
	 hit_counter <= hit_counter;
	 
	 
    //write_miss
     always @ (posedge clk, posedge ctrl_reset)
       if (ctrl_reset)
         write_miss_counter <= {32{1'b0}};
       else
         if (ctrl_write_miss)
       write_miss_counter <= write_miss_counter + 1;
         else
       write_miss_counter <= write_miss_counter;
  
     //read_miss
     always @ (posedge clk, posedge ctrl_reset)
       if (ctrl_reset)
         read_miss_counter <= {32{1'b0}};
       else
         if (ctrl_read_miss)
       read_miss_counter <= read_miss_counter + 1;
         else
       read_miss_counter <= read_miss_counter;


   //cache_controller_requested_data
   always @ (posedge clk)
     begin
	if (ctrl_addr == 2'b00)
	  begin
	     ctrl_req_data <= hit_counter;
	     ctrl_cache_invalid <= 1'b0;
	  end
	else if (ctrl_addr == 2'b01)
	  begin
	     ctrl_req_data <= read_miss_counter;
	     ctrl_cache_invalid <= 1'b0;
	  end
	else if (ctrl_addr == 2'b10)
	  begin
	     ctrl_req_data <= write_miss_counter;
	     ctrl_cache_invalid <= 1'b0;
	  end
	else
	  begin
	     ctrl_req_data <= {32{1'b0}};
	     ctrl_cache_invalid <= 1'b1;
	  end
     end


   always @ (posedge clk)
     ctrl_ack <= ctrl_cpu_req;
   
endmodule
