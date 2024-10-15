module tb_hbm_controller;

    // Clock and reset signals
    reg clk;
    reg reset_n;

    // Input signals for HBM controller
    reg [31:0] addr;
    reg [511:0] data_in;
    reg wr_en;
    reg rd_en;

    // Outputs from HBM controller
    wire [511:0] data_out;
    wire hbm_ready;
    wire hbm_error;

    // PHY interface signals (for emulation)
    wire phy_cmd;
    wire [31:0] phy_addr;
    wire [511:0] phy_wr_data;
    reg [511:0] phy_rd_data;
    reg phy_ready;
    reg phy_error;

    // Instantiate the HBM controller
    hbm_controller uut (
        .clk(clk),
        .reset_n(reset_n),
        .addr(addr),
        .data_in(data_in),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_out(data_out),
        .hbm_ready(hbm_ready),
        .hbm_error(hbm_error),
        .phy_cmd(phy_cmd),
        .phy_addr(phy_addr),
        .phy_wr_data(phy_wr_data),
        .phy_rd_data(phy_rd_data),
        .phy_ready(phy_ready),
        .phy_error(phy_error)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock (period = 10ns)

    // Task to emulate a write operation
    task write_data(input [31:0] address, input [511:0] data);
        begin
            @(posedge clk);
            addr = address;
            data_in = data;
            wr_en = 1'b1;
            rd_en = 1'b0;
            phy_ready = 1'b1;   // PHY ready to accept command
            @(posedge clk);
            wr_en = 1'b0;
            phy_ready = 1'b0;   // Simulate PHY busy after accepting command
        end
    endtask

    // Task to emulate a read operation
    task read_data(input [31:0] address);
        begin
            @(posedge clk);
            addr = address;
            wr_en = 1'b0;
            rd_en = 1'b1;
            phy_ready = 1'b1;   // PHY ready to accept command
            @(posedge clk);
            rd_en = 1'b0;
            phy_ready = 1'b0;   // Simulate PHY busy after accepting command
        end
    endtask

    // Task to emulate PHY returning data for read operations
    task return_read_data(input [511:0] data);
        begin
            @(posedge clk);
            phy_rd_data = data;
            phy_ready = 1'b1;   // PHY ready to return read data
            @(posedge clk);
            phy_ready = 1'b0;
        end
    endtask

    // Initial block to initialize signals and simulate operations
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        addr = 0;
        data_in = 0;
        wr_en = 0;
        rd_en = 0;
        phy_ready = 0;
        phy_rd_data = 0;
        phy_error = 0;

        // Reset the controller
        @(posedge clk);
        reset_n = 1'b0;
        @(posedge clk);
        reset_n = 1'b1;

        // Wait for the reset
        repeat (10) @(posedge clk);

        // Write to memory address 0x00000010
        write_data(32'h00000010, 512'hDEADBEEF1234567890ABCDEF00000000FFFFFFFFABCDEF1234567890DEADBEEF);

        // Wait for some cycles
        repeat (10) @(posedge clk);

        // Read from the same address
        read_data(32'h00000010);

        // Emulate PHY returning data for the read operation
        return_read_data(512'hDEADBEEF1234567890ABCDEF00000000FFFFFFFFABCDEF1234567890DEADBEEF);

        // Wait for the controller to process the read data
        repeat (10) @(posedge clk);

        // Check the output data
       

        // Test complete
    end
initial 
begin
	$dumpfile("dump.vcd");
	$dumpvars();
	#700;
  $finish;	
end 

endmodule
