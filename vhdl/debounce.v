module debounce (CLOCK_50, noisy, debounced);

parameter delay = 5000000; // so 10ms for a 50 MHz clock
input CLOCK_50, noisy;
output reg debounced;

reg [28:0] count; // 19 bits is enough to count to 500000
reg changed;

always @(posedge CLOCK_50)

    if (noisy != changed) begin
        changed <= noisy;
        count <= 0;
    end
    else if (count == delay) debounced <= changed;
    else count <= count + 1;

endmodule

