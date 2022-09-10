module fifomem
#(parameter WIDTH = 8, parameter DEPTH = 8)
(
    input   logic   clk,
    input   logic   reset,
    input   logic   wr_en,
    input   logic   [WIDTH-1:0] wr_data,
    output  logic   full,               // high when the fifo is full
    input   logic   rd_en,
    output  logic   [WIDTH-1:0] rd_data,
    output  logic   empty   
);

// Declare a 2-D memory block
// check whether the below declaration is packed or unpacked array!!
logic [WIDTH-1:0] mem [DEPTH-1:0]; // The first part is the width and the second part is depth

// The write and read pointer width is log base 2 of depth;
parameter ptr_wid = $clog2(DEPTH);

logic [ptr_wid:0] wr_ptr, rd_ptr; //extra bit is the wrapper bit

// logics for empty and full
// These are always evaluated
assign empty    = (wr_ptr == rd_ptr);
assign full     = (wr_ptr[ptr_wid] != rd_ptr[ptr_wid]) && (wr_ptr[ptr_wid-1:0] == rd_ptr[ptr_wid-1:0]);    

//logic for write pointer
always_ff@(posedge clk) begin
    if(reset == 0) begin
        wr_ptr <= 0;
    end
    else if (wr_en && !full) begin
        //first update the write pointer
        //check if the write pointer has reached the last entry -> toggle the
            //wrap bit
        if(wr_ptr[ptr_wid-1:0] == DEPTH-1) begin
            wr_ptr[ptr_wid-1:0] <= 0;
            wr_ptr[ptr_wid]     <= ~ wr_ptr[ptr_wid];
        end
        //what if wr_ptr is not at the last entry?
        else begin
            wr_ptr              <= wr_ptr + 1;
        end
        // Now that the ptr has been updated, put the data into the entry
        mem[wr_ptr[ptr_wid-1:0]] <= wr_data;
    end
end 

//logic for read pointer
always_ff@(posedge clk) begin
    if(reset == 0) begin
        rd_ptr <= 0;
    end
    else if (rd_en && !empty) begin
        if(rd_ptr[ptr_wid:0] == DEPTH-1) begin
            rd_ptr[ptr_wid-1:0] <= 0;
            rd_ptr[ptr_wid]     <= ~ rd_ptr[ptr_wid];
        end
        else begin
            rd_ptr <= rd_ptr + 1;
        end 
    end
end
//why do we read data combinationally?
assign rd_data = mem[rd_ptr[ptr_wid-1:0]];

endmodule

