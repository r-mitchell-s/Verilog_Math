/* - - - - - CIRCUIT - - - - - */
module sine_gen(
    input logic clk,
    input out_en,
    output logic signed [9:0] out
);

    // 512-step sine wave wth values stored in an LUT, each value is 10-bit number
    reg signed [9:0] sine_lut [0:511]; 

    // initialize the LUT with corresponding values
    initial begin
        integer i;
        // generate the values
        for (i = 0; i < 512; i = i + 1) begin
            sine_lut[i] = (1023 / 2) * (1 + $sin(2 * 3.141592653589793 * i / 512));
        end
    end

    // register to store LUT index
    reg [9:0] index = 0;

    // state machine logic
    always @(posedge clk) begin
        
        // hold value if out_en is not asserted
        if (out_en) begin
            
            // Walk through the LUT indices, wrapping back to 0 when reaching 511
            if (index == 511) begin
                index <= 0; 
            end else begin
                index <= index + 1;
            end
        end
    end

    // set the output to the value currently indexed
    assign out = sine_lut[index]; 

endmodule

/* - - - - - TESTBENCH - - - - - */
module tb_sine_gen();

    // signal declarations
    logic clk;
    logic out_en;
    logic signed [9:0] out;
   
    // DUT instantition
    sine_gen dut(.clk(clk), .out_en(out_en), .out(out));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Generate clock with a period of 10 units
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;

        out_en = 1;  // Enable output
        #40000  // Run for some time
        
        $finish; 
    end
endmodule