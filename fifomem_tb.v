module fifomem_tb();

parameter WIDTH = 4;
parameter DEPTH = 8;

logic clk;
logic reset;
logic wr_en;
logic [WIDTH-1:0] wr_data;
logic full;
logic rd_en;
logic [WIDTH-1:0] rd_data;
logic empty;

fifomem #(.WIDTH(WIDTH), .DEPTH(DEPTH)) FFM 
(
    .clk(clk),
    .reset(reset),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .full(full),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .empty(empty)
);

initial begin
    clk     = 1'b0;
    reset   = 1'b0;
    wr_en   = 1'b0;
    rd_en   = 1'b0;
    wr_data = 0;
    @(negedge clk) reset = 1'b1;

    write_task;
    #20;
    @(negedge clk);
    wr_en = 0'b0;

    read_task;
    #100;
    $finish;
end

always begin
        #25 clk = ~ clk;
end

//write both the task definitions
task    write_task;
begin
    @(negedge clk);
    wr_en = 1'b1;
    repeat(5)
    begin
        @(negedge clk);
        wr_data = $urandom($random)%16; 
        // $urandom returns a 32 bit unsigned #
        // $random returns a 32 bit signed #
        // divide by 16 because wr_data is 4 bit wide
        @(posedge clk);
    end
end
endtask

task    read_task;
begin
    @(negedge clk);
    rd_en = 1'b1;
    repeat(5)
    begin
        @(posedge clk);
    end
end
endtask

endmodule   


